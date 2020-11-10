//
//  PolicyWebView.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/30.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "PolicyWebView.h"

@interface PolicyWebView ()<UIWebViewDelegate>

@property (nonatomic,weak) IBOutlet WKWebView *webView;

@end

@implementation PolicyWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.webView.UIDelegate = self;
    
    //设置导航
    NSURL * deleteIcon = [[NSURL alloc] initWithString:@"https://www.mysubmail.com/libraries/zh_cn/images/mail_box_close_on.png"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithData: [NSData dataWithContentsOfURL:deleteIcon]] style:UIBarButtonItemStyleDone target:self action:@selector(closePage)];
    self.navigationItem.leftBarButtonItem = leftItem;
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"服务协议";
    
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityDynamic;
    config.allowsInlineMediaPlayback = YES;
    WKPreferences * preferences = [WKPreferences new];
    //是否支持javascript
    preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开页面
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 92, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height-92) configuration:config];
    self.webView = webview;
    [self.view addSubview:self.webView];
    
    UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 92)];
    navView.backgroundColor = self.webNavColor;
    
    CGFloat rw = self.webNavReturnImg.size.width;
    CGFloat rh = self.webNavReturnImg.size.height;
    UIButton * rbtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 72-rh, rh, rw)];
    [rbtn setImage:self.webNavReturnImg forState:UIControlStateNormal];
    [rbtn addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:rbtn];
    
    UILabel * rtitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 72-rh, self.view.frame.size.width-120, 20)];
    [rtitle setAttributedText:self.webtitle];
    rtitle.textAlignment = NSTextAlignmentCenter;
    [rtitle setFont:[UIFont systemFontOfSize:16]];
    [navView addSubview:rtitle];
    
    
    [self.view addSubview:navView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    //
}

- (void) closePage{
    [self dismissViewControllerAnimated:YES completion:nil];
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
