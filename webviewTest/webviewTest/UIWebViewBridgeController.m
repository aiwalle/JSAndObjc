//
//  UIWebViewBridgeController.m
//  webviewTest
//
//  Created by liang on 17/2/21.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "UIWebViewBridgeController.h"
#import "WebViewJavascriptBridge.h"
@interface UIWebViewBridgeController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *webViewBridge;
@end

@implementation UIWebViewBridgeController
/*
 利用WebViewJavascriptBridge来实现JS与OC的交互的优点：
 1、获取参数时，更方便一些，如果参数中有一些特殊符号或者url带参数，能够很好的解析。
 也有一些缺点：
 1、做一次交互，需要执行的js 与原生的交互步骤较多，至少有两次。
 2、需要花较多的时间，理解WebViewJavascriptBridge的原理和使用步骤。
 */
- (void)dealloc {
    NSLog(@"dealloc-webViewBridge");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index4.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
 
    self.webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.webViewBridge setWebViewDelegate:self];
    
    // 添加JS 要调用的Native 功能
    [self registerNativeFunctions];
}

// Native 调用功能的别名handlerName
// 这里的handler别名在js中被注册过了
- (void)rightBtnClick {
    [self.webViewBridge callHandler:@"testJSFunction" data:@"一个字符串" responseCallback:^(id responseData) {
        NSLog(@"调用完JS后的回调：%@", responseData);
    }];
}

// js 注册Native 要调用的功能
- (void)registerNativeFunctions {
    [self registShareFunction];
}

- (void)registShareFunction {
    [self.webViewBridge registerHandler:@"shareClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *tempDic = data;
        NSString *title = [tempDic objectForKey:@"title"];
        NSString *content = [tempDic objectForKey:@"content"];
        NSString *url = [tempDic objectForKey:@"url"];
        
        NSString *result = [NSString stringWithFormat:@"分享成功:%@, %@, %@", title, content, url];
        responseCallback(result);
    }];
}



@end
