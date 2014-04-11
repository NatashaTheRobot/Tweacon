//
//  NTRTwitterWebViewController.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/10/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRTwitterWebViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString * const twitterURL = @"https://twitter.com";

@interface NTRTwitterWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NTRTwitterWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.title = [NSString stringWithFormat:@"@%@", _screenName];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", twitterURL, _screenName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

@end
