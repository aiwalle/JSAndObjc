//
//  ViewController.m
//  webviewTest
//
//  Created by liang on 17/2/20.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "WKWebViewController.h"
#import "WKWebViewControllerTwo.h"
#import "JavaScriptCoreViewController.h"
#import "UIWebViewBridgeController.h"
#import "WKWebViewBridgeController.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)UIWebViewControllerClick:(id)sender {
    [self.navigationController pushViewController:[WebViewController new] animated:YES];
}

- (IBAction)WKWebViewControllerClick:(id)sender {
    [self.navigationController pushViewController:[WKWebViewController new] animated:YES];
}

- (IBAction)WKWebViewMessageHandler:(id)sender {
    [self.navigationController pushViewController:[WKWebViewControllerTwo new] animated:YES];
}

- (IBAction)JavaScriptCoreViewController:(id)sender {
    [self.navigationController pushViewController:[JavaScriptCoreViewController new] animated:YES];
}

- (IBAction)UIWebViewBridgeController:(id)sender {
    [self.navigationController pushViewController:[UIWebViewBridgeController new] animated:YES];
}

- (IBAction)WKWebViewBridgeController:(id)sender {
    [self.navigationController pushViewController:[WKWebViewBridgeController new] animated:YES];
}

@end
