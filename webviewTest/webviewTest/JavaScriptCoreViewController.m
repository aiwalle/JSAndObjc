//
//  JavaScriptCoreViewController.m
//  webviewTest
//
//  Created by liang on 17/2/21.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "JavaScriptCoreViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface JavaScriptCoreViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation JavaScriptCoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index3.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}
#pragma mark - **************** JS----->OC
// 1.JS要调用的原生OC方法，可以在viewDidLoad webView被创建后就添加好，但最好是在网址加载成功后再添加，以避免无法预料的乱入Bug
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    
    [self addCustomActions];
}

- (void)addCustomActions {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context evaluateScript:@"var arr = [3, 4, 'abc'];"];
    
    [self addShareWithContext:context];
    [self addPayActionWithContext:context];
}

// 2.block 中的执行环境是在子线程中。奇怪的是竟然可以更新部分UI，例如给view设置背景色，调用webView执行js等，但是弹出原生alertView就会在控制台报子线程操作UI的错误信息
// 3.避免循环引用，因为block 会持有外部变量，而JSContext也会强引用它所有的变量，因此在block中调用self时，要用__weak 转一下。而且在block内不要使用外部的context 以及JSValue，都会导致循环引用。如果要使用context 可以使用[JSContext currentContext]。当然我们可以将JSContext 和JSValue当做block的参数传进去，这样就可以使用啦。
- (void)addShareWithContext:(JSContext *)context {
    __weak typeof(self) weakSelf = self;
    context[@"share"] = ^() {
        NSArray *args = [JSContext currentArguments];
        if (args.count < 3) {
            return;
        }
        
        NSString *title = [args[0] toString];
        NSString *content = [args[1] toString];
        NSString *url = [args[2] toString];
        
        NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@', '%@', '%@')", title, content, url];
        [[JSContext currentContext] evaluateScript:jsStr];
    };
}

#pragma mark - **************** OC------>JS
- (void)addPayActionWithContext:(JSContext *)context {
    __weak typeof(self) weakSelf = self;
    context[@"payAction"] = ^() {
        // 方式1 使用JSContext的方法-evaluateScript，可以实现OC调用JS方法
//        NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')", @"支付成功"];
//        [[JSContext currentContext] evaluateScript:jsStr];
        
        
        // 方式2 使用JSValue的方法-callWithArguments，也可以实现OC调用JS方法
//        NSArray *args = [JSContext currentArguments];
//        if (args.count < 4) {
//            return;
//        }
//        
//        NSString *orderNo = [args[0] toString];
//        NSString *channel = [args[1] toString];
//        long long amount = [[args[2] toNumber] longLongValue];
//        NSString *subject = [args[3] toString];
//        
//        NSLog(@"orderNo:%@---channel:%@---amount:%lld---subject:%@",orderNo,channel,amount,subject);
//        [[JSContext currentContext][@"payResult"] callWithArguments:@[@"支付成功"]];
        
        // 方式3 利用UIWebView的API
        NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')", @"支付成功"];
        [weakSelf.webView stringByEvaluatingJavaScriptFromString:jsStr];
    };
}


@end
