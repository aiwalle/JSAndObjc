//
//  WebViewController.m
//  webviewTest
//
//  Created by liang on 17/2/20.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation WebViewController
// webview拦截URL
- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"haleyaction"]) {
        [self handleCustomAction:URL];
        return NO;
    }
    return YES;
}

- (void)handleCustomAction:(NSURL *)URL {
    NSString *host = [URL host];
    if ([host isEqualToString:@"scanClick"]) {
        NSLog(@"扫一扫");
    }else if ([host isEqualToString:@"shareClick"]) {
        [self share:URL];
    }else if ([host isEqualToString:@"getLocation"]) {
        [self getLocation];
    }else if ([host isEqualToString:@"setColor"]) {
        
    }else if ([host isEqualToString:@"payAction"]) {
        
    }else if ([host isEqualToString:@"shake"]) {
        
    }else if ([host isEqualToString:@"goBack"]) {
        
    }
}

// 获取当前地址
- (void)getLocation {
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')", @"上海市徐汇区虹漕路88号"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

// 分享
- (void)share:(NSURL *)URL {
    NSArray *params = [URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByRemovingPercentEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *content = [tempDic objectForKey:@"content"];
    NSString *url = [tempDic objectForKey:@"url"];
    
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@', '%@', '%@')", title, content, url];
    
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}


@end
