//
//  UIView+UIAppearanceSynchronization.m
//  test
//
//  Created by Jave on 2017/7/19.
//  Copyright © 2017年 Marike Jave. All rights reserved.
//
#import <objc/runtime.h>
#import <JRSwizzle/JRSwizzle.h>
#import "UIView+UIAppearanceSynchronization.h"

@interface UIAppearanceInstanceProxy : NSObject
@property (nonatomic, assign, readonly) id target;
@end

@implementation UIAppearanceInstanceProxy

- (instancetype)initWithTarget:(id)target{
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    return [[self target] isEqual:object];
}

- (NSUInteger)hash{
    return [[self target] hash];
}

@end

// _UIAppearanceCustomizableClassInfo
@protocol _UIAppearanceCustomizableClassInfoProtocol <NSObject>

@optional
@property (nonatomic, strong, readonly) NSString *_classReferenceKey;

@property (nonatomic, strong, readonly) Class _customizableViewClass;

@property (nonatomic, strong, readonly) Class _guideClass;

@property (nonatomic, strong, readonly) id _superClassInfo;

@end

// _UIAppearance
@protocol UIAppearanceProtocol <NSObject>

@property (nonatomic, strong, readonly) NSMutableArray<UIAppearanceInstanceProxy *> *mutableInstanceProxys;

- (void)registerAppreanceInstance:(__weak id)instance;
- (void)unregisterAppreanceInstance:(__weak id)instance;

@end

@protocol _UIAppearanceProtocol <UIAppearanceProtocol>

@optional
@property (nonatomic, strong, readonly) NSArray *_appearanceInvocations;

@property (nonatomic, strong, readonly) id<_UIAppearanceCustomizableClassInfoProtocol> _customizableClassInfo;

@end

// UIAppearanceViewInstanceSetter
@interface UIAppearanceViewInstanceSetter : NSObject

@property (nonatomic, assign) id instance;
@property (nonatomic, weak) id<_UIAppearanceProtocol> apearance;

@end

@implementation UIAppearanceViewInstanceSetter

- (void)dealloc{
    [[self apearance] unregisterAppreanceInstance:[self instance]];
}

@end

// UIView-UIAppearance
@protocol UIAppearanceViewInstanceProtocol <NSObject>

@property (nonatomic, strong, readonly) UIAppearanceViewInstanceSetter *appearanceViewInstanceSetter;

@end

@interface UIView (UIAppearanceSynchronization_Private)<UIAppearanceViewInstanceProtocol>
@end

@implementation UIView (UIAppearanceSynchronization)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jr_swizzleClassMethod:@selector(allocWithZone:) withClassMethod:@selector(swizzle_allocWithZone:) error:nil];
    });
}

+ (instancetype)swizzle_allocWithZone:(struct _NSZone *)zone{
    id object = [self swizzle_allocWithZone:zone];
    if ([object allowSynchronizeAppreance]) {
        id<_UIAppearanceProtocol> appreance = [self appearance];
        [appreance registerAppreanceInstance:object];
    }
    return object;
}

- (UIAppearanceViewInstanceSetter *)appearanceViewInstanceSetter{
    UIAppearanceViewInstanceSetter *setter = objc_getAssociatedObject(self, @selector(appearanceViewInstanceSetter));
    if (!setter) {
        setter = [UIAppearanceViewInstanceSetter new];
        objc_setAssociatedObject(self, @selector(appearanceViewInstanceSetter), setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return setter;
}

- (BOOL)allowSynchronizeAppreance{
    return NO;
}

@end

@interface NSObject (UIAppearance)<_UIAppearanceProtocol>
@end

@implementation NSObject (UIAppearance)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class _UIAppearanceClass = NSClassFromString(@"_UIAppearance");
        [_UIAppearanceClass jr_swizzleMethod:@selector(forwardInvocation:) withMethod:@selector(swizzle_forwardInvocation:) error:nil];
        [_UIAppearanceClass jr_swizzleMethod:@selector(methodSignatureForSelector:) withMethod:@selector(swizzle_methodSignatureForSelector:) error:nil];
    });
}

- (void)swizzle_forwardInvocation:(NSInvocation *)anInvocation{
    [self swizzle_forwardInvocation:anInvocation];
    
    if ([[self _appearanceInvocations] containsObject:anInvocation]) {
        NSArray *proxys = [[self mutableInstanceProxys] copy];
        [proxys enumerateObjectsUsingBlock:^(UIAppearanceInstanceProxy *proxy, NSUInteger idx, BOOL *stop) {
            if ([[proxy target] respondsToSelector:[anInvocation selector]]) {
                [anInvocation invokeWithTarget:[proxy target]];
            }
        }];
    }
}

- (NSMethodSignature *)swizzle_methodSignatureForSelector:(SEL)aSelector{
    return [self swizzle_methodSignatureForSelector:aSelector];
}

#pragma mark - accessor

- (NSMutableArray<UIAppearanceInstanceProxy *> *)mutableInstanceProxys{
    NSMutableArray *instances = objc_getAssociatedObject(self, @selector(mutableInstanceProxys));
    if (!instances) {
        instances = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(mutableInstanceProxys), instances, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instances;
}

- (id)proxyInstancesWithInstance:(id)instance{
    for (UIAppearanceInstanceProxy *proxyInstance in [[self mutableInstanceProxys] copy]) {
        if ([proxyInstance target] == instance) {
            return proxyInstance;
        }
    }
    return nil;
}

- (void)registerAppreanceInstance:(id<UIAppearanceViewInstanceProtocol>)instance;{
    NSParameterAssert(instance);
    NSParameterAssert([self class] == NSClassFromString(@"_UIAppearance"));
    NSParameterAssert([[instance class] conformsToProtocol:@protocol(UIAppearance)]);
    NSParameterAssert([instance class] == [[self _customizableClassInfo] _customizableViewClass]);
    instance.appearanceViewInstanceSetter.apearance = self;
    instance.appearanceViewInstanceSetter.instance = instance;
    
    id proxy = [[UIAppearanceInstanceProxy alloc] initWithTarget:instance];
    
    [[self mutableInstanceProxys] addObject:proxy];
}

- (void)unregisterAppreanceInstance:(id<UIAppearanceViewInstanceProtocol>)instance;{
    NSParameterAssert(instance);
    NSParameterAssert([self class] == NSClassFromString(@"_UIAppearance"));
    NSParameterAssert([[instance class] conformsToProtocol:@protocol(UIAppearance)]);
    NSParameterAssert([instance class] == [[self _customizableClassInfo] _customizableViewClass]);
    
    id proxy = [self proxyInstancesWithInstance:instance];
    if (proxy) {
        [[self mutableInstanceProxys] removeObject:proxy];
    }
}

@end
