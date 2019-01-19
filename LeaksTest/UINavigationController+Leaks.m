//
//  UINavigationController+Leaks.m
//  LeaksTest
//
//  Created by myxc on 2019/1/19.
//  Copyright © 2019 myxc. All rights reserved.
//

#import "UINavigationController+Leaks.h"
#import <objc/runtime.h>

@implementation UINavigationController (Leaks)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self xc_swizzleOriginSEL:@selector(popViewControllerAnimated:)
                      swizzledSEL:@selector(xc_popViewControllerAnimated:)];
    });
}

+ (void)xc_swizzleOriginSEL:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL{
    Method originMethod  = class_getInstanceMethod([self class], originSEL);
    Method currentMethod  = class_getInstanceMethod([self class], swizzledSEL);
    method_exchangeImplementations(originMethod, currentMethod);
}

- (UIViewController *)xc_popViewControllerAnimated:(BOOL)animated{
    extern const char *XC_LEAKS_CHECK;
    UIViewController *popViewController = [self xc_popViewControllerAnimated:animated];
    objc_setAssociatedObject(popViewController, XC_LEAKS_CHECK, @(YES), OBJC_ASSOCIATION_ASSIGN);
    return popViewController;
}


@end
