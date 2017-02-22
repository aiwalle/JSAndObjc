//
//  WKWebViewBridgeController.m
//  webviewTest
//
//  Created by liang on 17/2/22.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "WKWebViewBridgeController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
@interface WKWebViewBridgeController ()<WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewJavascriptBridge *webViewBridge;
@end

@implementation WKWebViewBridgeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 30.0;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index4.html" ofType:nil];
    NSString *localHtml = [NSString stringWithContentsOfFile:urlStr encoding:NSUTF8StringEncoding error:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadHTMLString:localHtml baseURL:fileURL];
    
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    self.webViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    // 如果控制器里需要监听WKWebView 的`navigationDelegate`方法，就需要添加下面这行
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

// 我们可以这样理解，后面的block 参数是js 要调用的Native 实现，前面的handlerName 是这个Native 实现的别名。然后js 里调用handlerName 这个别名，WebViewJavascriptBridge最终会执行block 里的Native 实现
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

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
