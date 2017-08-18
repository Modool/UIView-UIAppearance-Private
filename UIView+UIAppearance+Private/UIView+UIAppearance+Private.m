// Copyright (c) 2017 Modool. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <objc/runtime.h>
#import "UIView+UIAppearance+Private.h"

void UIView_UIAppearanceMethodSwizzle(Class class, SEL origSel, SEL altSel){
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method altMethod = class_getInstanceMethod(class, altSel);
    
    class_addMethod(class, origSel, class_getMethodImplementation(class, origSel), method_getTypeEncoding(origMethod));
    class_addMethod(class, altSel, class_getMethodImplementation(class, altSel), method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(class, origSel), class_getInstanceMethod(class, altSel));
}

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

@interface UIView (UIAppearance_Private)<UIAppearanceViewInstanceProtocol>
@end

@implementation UIView (UIAppearance_Private)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView_UIAppearanceMethodSwizzle(object_getClass((id)self), @selector(allocWithZone:), @selector(swizzle_allocWithZone:));
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
        UIView_UIAppearanceMethodSwizzle(_UIAppearanceClass, @selector(forwardInvocation:), @selector(swizzle_forwardInvocation:));
        UIView_UIAppearanceMethodSwizzle(_UIAppearanceClass, @selector(methodSignatureForSelector:), @selector(swizzle_methodSignatureForSelector:));
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
