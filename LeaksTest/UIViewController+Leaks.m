//
//  UIViewController+Leaks.m
//  LeaksTest
//
//  Created by myxc on 2019/1/19.
//  Copyright © 2019 myxc. All rights reserved.
//

#import "UIViewController+Leaks.h"
#import <objc/runtime.h>


/**
 
 自定义leaks 检测工具
 
 原理：利用swizzle了NavigationController的Push和Pop相关方法来管理viewController和view的生命周期
 
 思路：
  向一个已经被销毁的对象发送消息是不会崩溃的,假如一个VC存在内存泄露,那么它就不会被释放掉,我们可以想向它发送消息,如果它收到了消息,那么这个VC的代码就一定存在问题.
 
 实现思路：
  在VC中设置一个属性,viewWillAppear的时候设置为NO,pop返回出栈的时候(暂时只考虑pop情况)设置为YES,我们在viewDidDisappear中,延迟访问这个这个属性,如果他为YES,那么就代表存在内存问题.
 
 */

const char *XC_LEAKS_CHECK;


@implementation UIViewController (Leaks)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self xc_swizzledOriginSEL:@selector(viewWillAppear:) swizzledSEL:@selector(xc_viewWillAppear:)];
        [self xc_swizzledOriginSEL:@selector(viewDidDisappear:) swizzledSEL:@selector(xc_viewDidDisappear:)];

    });
}

+ (void)xc_swizzledOriginSEL:(SEL)originSEL
                 swizzledSEL:(SEL)swizzledSEL {
    
    Method originMethod = class_getInstanceMethod([self class], originSEL);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSEL);
    method_exchangeImplementations(originMethod, swizzledMethod);
    
}

- (void)xc_viewWillAppear:(BOOL)animated {
    [self xc_viewWillAppear:animated];
    objc_setAssociatedObject(self, XC_LEAKS_CHECK, @(NO), OBJC_ASSOCIATION_RETAIN);

}

- (void)xc_viewDidDisappear:(BOOL)animated {
    [self xc_viewDidDisappear:animated];
    if ([objc_getAssociatedObject(self, XC_LEAKS_CHECK) boolValue]) {
        //发送消息
        [self willDelloc];
    }
}

- (void)willDelloc {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf isNotDelloc];
    });
}

- (void)isNotDelloc {
    NSLog(@"%s", __func__);
}

@end
