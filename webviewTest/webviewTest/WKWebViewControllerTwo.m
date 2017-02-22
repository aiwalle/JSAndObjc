//
//  WKWebViewControllerTwo.m
//  webviewTest
//
//  Created by liang on 17/2/20.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "WKWebViewControllerTwo.h"
#import <WebKit/WebKit.h>
@interface WKWebViewControllerTwo ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;

@end
// MessageHandler---------------->注意看这里对应的html文件
/*
    使用MessageHandler 的好处
    1.在JS中写起来简单，不用再用创建URL的方式那么麻烦了
    2.JS传递参数更方便。使用拦截URL的方式传递参数，只能把参数拼接在后面，如果遇到要传递的参数中有特殊字符，如&、=、？等，必须得转换，否则参数解析肯定会出错。
    http://blog.csdn.net/u011619283/article/details/52135988
 */
@implementation WKWebViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    // 创建WKWebViewConfiguration对象，配置各个API对应的MessageHandler
    [configuration.userContentController addScriptMessageHandler:self name:@"ScanAction"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Location"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Share"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Color"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Pay"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Shake"];
    [configuration.userContentController addScriptMessageHandler:self name:@"GoBack"];
    [configuration.userContentController addScriptMessageHandler:self name:@"PlaySound"];
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index2.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
}

// WKUIDelegate是因为我在JS中弹出了alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// WKScriptMessageHandler是因为我们要处理JS调用OC方法的请求
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"ScanAction"]) {
        NSLog(@"扫一扫");
    }else if ([message.name isEqualToString:@"Location"]) {
        [self getLocation];
    }else if ([message.name isEqualToString:@"Share"]) {
        [self shareWithParams:message.body];
    }else if ([message.name isEqualToString:@"Color"]) {
        
    }else if ([message.name isEqualToString:@"Pay"]) {
        
    }else if ([message.name isEqualToString:@"Shake"]) {
        
    }else if ([message.name isEqualToString:@"GoBack"]) {
        
    }else if ([message.name isEqualToString:@"PlaySound"]) {
        
    }
}

- (void)getLocation {
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')", @"上海市徐汇区虹漕路88号"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@-----%@", result, error);
    }];
}

/*
 调用顺序
 1.调用了JS中的shareClick方法
 2.JS中的shareClick方法发送消息，调用了OC中的userContentController:
 3.接着调用了- (void)shareWithParams:方法，来解析message，然后在这个方法里又调用了JS中的shareResult方法⚠️重点
 4.JS中的shareResult方法又调用了alert，调用了OC中的runJavaScriptAlertPanelWithMessage:方法来实现弹窗
 */


// 解析JS 调用OC 实现分享的参数
- (void)shareWithParams:(NSDictionary *)tempDic {
    if (![tempDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *content = [tempDic objectForKey:@"content"];
    NSString *url = [tempDic objectForKey:@"url"];
    
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}



@end
