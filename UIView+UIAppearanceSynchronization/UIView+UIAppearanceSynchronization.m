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

@property (nonatomic, strong, readonly) NSHashTable *mutableInstances;

- (void)registerAppreanceInstance:(__weak id)instance;

@end

@protocol _UIAppearanceProtocol <UIAppearanceProtocol>

@optional
@property (nonatomic, strong, readonly) NSArray *_appearanceInvocations;

@property (nonatomic, strong, readonly) id<_UIAppearanceCustomizableClassInfoProtocol> _customizableClassInfo;

@end

// UIView-UIAppearance
@protocol UIAppearanceViewInstanceProtocol <NSObject>

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
        NSPointerArray *instances = [[self mutableInstances] copy];
        for (id instance in instances) {
            if ([instance respondsToSelector:[anInvocation selector]]) {
                [anInvocation invokeWithTarget:instance];
            }
        }
    }
}

- (NSMethodSignature *)swizzle_methodSignatureForSelector:(SEL)aSelector{
    return [self swizzle_methodSignatureForSelector:aSelector];
}

#pragma mark - accessor

- (NSHashTable *)mutableInstances{
    NSHashTable *instances = objc_getAssociatedObject(self, @selector(mutableInstances));
    if (!instances) {
        instances = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, @selector(mutableInstances), instances, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instances;
}

- (void)registerAppreanceInstance:(id<UIAppearanceViewInstanceProtocol>)instance;{
    NSParameterAssert(instance);
    NSParameterAssert([self class] == NSClassFromString(@"_UIAppearance"));
    NSParameterAssert([[instance class] conformsToProtocol:@protocol(UIAppearance)]);
    NSParameterAssert([instance class] == [[self _customizableClassInfo] _customizableViewClass]);
    
    [[self mutableInstances] addObject:instance];
}

@end
