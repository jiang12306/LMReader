//
//  LMAboutUsViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMAboutUsViewController.h"
#import <WebKit/WebKit.h>
#import "LMTool.h"

@interface LMAboutUsViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView* webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation LMAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于我们";
    
    NSString* versionStr = [LMTool applicationCurrentVersion];
    NSString* tempStr = [NSString stringWithFormat:@"%@?ver=%@", aboutUsHost, versionStr];
    NSString* encodeStr = [tempStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
    
    CGFloat naviHeight = 44 + 20;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight)];
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//添加进度监听
    
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    self.progressView.tintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:encodeUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];//15s时间
    [self.webView loadRequest:theRequest];
    
}

#pragma mark -WKNavigationDelegate
- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler{
    
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    
    NSURL* url = navigationAction.request.URL;
    NSString* hostStr = [url absoluteString];
    if ([hostStr rangeOfString:@"itunes.apple.com"].location != NSNotFound && [[UIApplication sharedApplication] canOpenURL:url]) {
        
        policy =WKNavigationActionPolicyCancel;
    }
    
    decisionHandler(policy);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    [self showReloadButton];
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self.webView reload];
}

-(void)dealloc {
    [self.webView stopLoading];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];//取消监听
    self.webView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
