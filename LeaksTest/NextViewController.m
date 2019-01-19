//
//  NextViewController.h
//  LeaksTest
//
//  Created by myxc on 2019/1/19.
//  Copyright © 2019 myxc. All rights reserved.
//

/**
 iOS内存泄漏检测方法
 
 内存泄漏
 定义：通俗来说就是有一块内存区域被你占用了，但你又不使用这块区域也不让别人用，造成内存浪费，这就是内存泄漏，泄漏严重会造成内存吃紧，严重的会使程序崩溃
 
 1、造成泄漏的点
 （1）引用循环（Retain Cycle），Block强引用
 （2）NSTimer释放不当
 （3）第三方提供方法造成的内存泄漏
 （4）CoreFoundation方式申请的内存，忘记释放
 
 2、监测方法
 （1）逻辑错误：访问空指针或未初始化的变量等；
 （2）内存管理错误：如内存泄漏等；
 （3）声明错误：从未使用过的变量；
 （4）Api调用错误：未包含使用的库和框架。
 
 3、内存分类
  （1）、Leaked memory（内存未被应用程序引用，不能再次使用或释放）
  （2）、Abandoned memory（内存仍然被应用程序引用，但没有任何有用的用途）
  （3）、Cached memory（内存仍然被应用程序引用，可能会再次用于提高性能）
 
 4、检测工具
    （1）Instruments Leaks
    （2）MLeaksFinder
 注意：
  Leaked memory 和 Abandoned memory 都属于应该释放而没释放的内存，都是内存泄露，其中Leaks工具只负责检测 Leaked memory，而不管 Abandoned memory，因此Leaks并不能检测出所有的内存泄漏。而MLeaksFinder 可以检测出循环引用导致的内存泄漏，使用时可以二者结合解决问题！thanks
 
 5、MLeaksFinder
     原理:在捕获到这个界面销毁依然存在的对象之后,让它响应一个方法,这个方法会触发断言,断言会提示出到底是哪里出现了内存泄漏.有兴趣的可以去看看上面那篇文章深入了解一下MLeaksFinder的实现原理.

 */


#import "NeXtViewController.h"

@interface NextViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void(^block)(void);

@end

@implementation NextViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace, (CGFloat[]){1, 0, 0, 0.8});//内存泄漏
    UIColor *color = [UIColor colorWithCGColor: colorRef];
    self.view.backgroundColor = color;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.block = ^{
        [self testBlock];
    };
    

    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(testBlock) userInfo:nil repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)testBlock {
    NSLog(@"%s", __func__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//
//    [self.timer invalidate];
//    self.timer = nil;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
