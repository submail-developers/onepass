//
//  OclLogin.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "OclLogin.h"
#import <CommonCrypto/CommonHMAC.h>
#import "AuthPage.h"
#import "PolicyWebView.h"
#import <account_login_sdk_noui_core/account_login_sdk_noui_core.h>
#import <EAccountApiSDK/EAccountSDK.h>

#define AUTHCODE @"SUBMAIL2020"

@interface OclLogin()<UITextViewDelegate>

@property (nonatomic, strong) NSString * accessCode;//预取号凭证
@property (nonatomic, strong) NSString * securityPhone;//脱敏手机号
@property (nonatomic, strong) NSString * model;//通道
@property (nonatomic, assign) NSTimeInterval timeout;//超时时间
@property (nonatomic, assign) BOOL accessCodeState;
@property (nonatomic, assign) BOOL authpageState;
@property (nonatomic, weak) AuthPage * authpage;
@property (nonatomic,strong) UIImage *webNavReturnImg;
@property (nonatomic, strong)UIColor *webNavColor;

@end

@implementation OclLogin
#pragma mark - UITextViewDelegate ----设置请求超时时间
- (void) setTimeoutInterval:(NSTimeInterval)timeout{
    self.timeout = timeout;
    if([self.model isEqualToString:@"0"]){
        [[HYUniLoginSDK shareInstance] setTimeoutInterval:timeout];
    }else{
        [UASDKLogin.shareLogin setTimeoutInterval:timeout];
        //联通、电信超时请求时作为参数传入
    }
}

#pragma mark - UITextViewDelegate ----获取运营商类型
- (NSNumber *)getWorkType{
    return [[HYUniLoginSDK shareInstance] getOperatorType];
}

#pragma mark - UITextViewDelegate ----核心代码
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    /**
     协议web页面
     */
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityDynamic;
    config.allowsInlineMediaPlayback = YES;
    WKPreferences * preferences = [WKPreferences new];
    //是否支持javascript
    preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开页面
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    
    PolicyWebView * webView = [PolicyWebView new];
    webView.url = URL;
    
    NSString * webtitle = [textView.attributedText attributedSubstringFromRange:characterRange].string;
    webView.webtitle = [[NSAttributedString alloc] initWithString:webtitle attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    webView.webNavReturnImg = self.webNavReturnImg;
    webView.webNavColor = self.webNavColor;
    
    
    webView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.authpage presentViewController:webView animated:YES completion:nil];
    
    return NO;
}


static id _instance;
#pragma mark ======================拉起联通授权页===================
- (void)makeCUAuthPageWithModel:(OclModel *)model withController:(UIViewController *) controller complate:(LoginBlock)complatetion{
    AuthPage * atpage = [AuthPage new];
    self.authpage = atpage;
    CGFloat height = controller.view.frame.size.height;
    CGFloat width  = controller.view.frame.size.width;
    
    self.authpage.view.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:0.0];
    
    self.authpage.authVC = [[UIView alloc] init];
    [self.authpage.view addSubview:self.authpage.authVC];
    
    
    
    if(model.authBackgroundImage){
        self.authpage.authVC.backgroundColor = [UIColor colorWithPatternImage:model.authBackgroundImage];
    }else{
        self.authpage.authVC.backgroundColor = UIColor.whiteColor;
    }
    self.authpage.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    
    if([model.windowStyle intValue] == 1){
        self.authpage.authVC.frame = CGRectMake(0, height, width, height);
        self.authpage.rect = CGRectMake(0, 0, width, height);
    }else if([model.windowStyle intValue] == 2){
        if(!model.windowScaleH){
            model.windowScaleH = 0.4;
        }
        self.authpage.authVC.frame = CGRectMake(0, height, width, height*model.windowScaleH);
        self.authpage.rect = CGRectMake(0, height*(1 - model.windowScaleH), width, height*model.windowScaleH);
    }else if([model.windowStyle intValue] == 3){
        if(!model.windowScaleH){
            model.windowScaleH = 0.5;
        }
        if(!model.windowScaleW){
            model.windowScaleW = 0.8;
        }
        self.authpage.authVC.frame = CGRectMake(width*(1-model.windowScaleW)/2, height, width*model.windowScaleW, height*model.windowScaleH);
        self.authpage.rect = CGRectMake(width*(1-model.windowScaleW)/2, height*(1 - model.windowScaleH)/2, width*model.windowScaleW, height*model.windowScaleH);
    }
    
    //窗口corner
    if(!model.windowCornerRadius){
        model.windowCornerRadius = 10;
    }
    self.authpage.authVC.layer.cornerRadius = model.windowCornerRadius;
    
    
    /**
     登录按钮
     */
    UIButton * loginBt = [[UIButton alloc] init];
    [loginBt setAttributedTitle:model.loginBtnText forState:UIControlStateNormal];
    CGFloat bty = 0.0;
    CGFloat btx = (self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2;
    if(!model.loginBtnOffsetY){
        bty = (self.authpage.authVC.frame.size.height - model.loginBtnHeight)/2;
    }else{
        bty = [model.loginBtnOffsetY floatValue];
    }
    loginBt.frame = CGRectMake(btx, bty, model.loginBtnWidth, model.loginBtnHeight);
    [loginBt setBackgroundImage:model.loginBtnImgs[0] forState:UIControlStateNormal];
    [loginBt setBackgroundImage:model.loginBtnImgs[1] forState:UIControlStateDisabled];
    [loginBt setBackgroundImage:model.loginBtnImgs[2] forState:UIControlStateHighlighted];
    if(model.privacyState){
        loginBt.enabled = YES;
    }else{
        loginBt.enabled = NO;
    }
    
    
    
    
    /**
     号码Label
     */
    UILabel * numberLabel = [[UILabel alloc] init];
    NSMutableAttributedString * numberText = [[NSMutableAttributedString alloc] initWithAttributedString:model.numberText];
    NSRange range = {0,model.numberText.length};
    [numberText replaceCharactersInRange:range withString:self.securityPhone];
    [numberLabel setAttributedText:numberText];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    if(model.numberOffsetY){
        numberLabel.frame = CGRectMake(0, [model.numberOffsetY intValue], self.authpage.authVC.frame.size.width, 48);
    }else{
        numberLabel.frame = CGRectMake(0, (bty - 24)/2, self.authpage.authVC.frame.size.width, 48);
    }
    [self.authpage.authVC addSubview:numberLabel];
    
    /**
     协议栏
     */
    NSString * operator = @"联通统一认证服务条款";
    NSMutableAttributedString * mas = [NSMutableAttributedString alloc];
    if(!model.privacyText){
        mas =  [mas initWithString:@"同意联通统一认证服务条款并支持一键登录" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        NSRange operatorRange = [mas.mutableString rangeOfString:operator];
        [mas addAttributes:@{NSForegroundColorAttributeName:model.privacyColor} range:operatorRange];
        [mas addAttribute:NSLinkAttributeName value:@"https://opencloud.wostore.cn/authz/resource/html/disclaimer.html?fromsdk=true" range:operatorRange];
    }else{
        mas = [mas initWithAttributedString:model.privacyText];
        NSRange operatorRange = [mas.mutableString rangeOfString:@"&&默认&&"];
        NSAttributedString * operragePrivacy = [[NSAttributedString alloc]initWithString:operator attributes:@{NSLinkAttributeName:@"https://opencloud.wostore.cn/authz/resource/html/disclaimer.html?fromsdk=true",NSForegroundColorAttributeName:model.privacyColor}];
        [mas replaceCharactersInRange:operatorRange withAttributedString:operragePrivacy];
        if(model.privacy.count > 0){
            for (int i = 0; i < model.privacy.count; i++) {
                NSRange range = [mas.mutableString rangeOfString:[model.privacy objectAtIndex:i].string];
                [mas addAttributes:@{NSForegroundColorAttributeName:model.privacyColor} range:operatorRange];
                [mas replaceCharactersInRange:range withAttributedString:[model.privacy objectAtIndex:i]];
            }
        }
    }
    NSAttributedString * privacy = [[NSAttributedString alloc] initWithAttributedString:mas];
    UITextView * privaryLabel = [[UITextView alloc] init];
    CGFloat py = model.privacyOffsetY?[model.privacyOffsetY floatValue]:self.authpage.authVC.frame.size.height-55;
    privaryLabel.frame = CGRectMake( (self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2 - 20, py, model.loginBtnWidth + 40, 40);
    privaryLabel.attributedText = privacy;
    privaryLabel.textAlignment = NSTextAlignmentCenter;
    privaryLabel.delegate = self;
    privaryLabel.editable = NO;
    [self.authpage.authVC addSubview:privaryLabel];
    
    //协议checkbox
    if(model.checkboxDisplay){
        if(!model.checkboxSize){
            model.checkboxSize = @12;
        }
        UIButton * ckBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2 - 20 - [model.checkboxSize floatValue], py+10, [model.checkboxSize floatValue], [model.checkboxSize floatValue])];
        [ckBtn setBackgroundImage:model.uncheckedImg forState:UIControlStateNormal];
        [ckBtn setBackgroundImage:model.checkedImg forState:UIControlStateSelected];
        if(model.privacyState){
            ckBtn.selected = YES;
            loginBt.enabled = YES;
        }else{
            ckBtn.selected = NO;
            loginBt.enabled = NO;
        }
        [self.authpage initCheckButton:ckBtn];
    }
    
    //协议页面
    if(model.webNavColor){
        self.webNavColor = model.webNavColor;
    }else{
        self.webNavColor = [UIColor colorWithRed:0/255.f green:108/255.f blue:255/255.f alpha:1];
    }
    if(model.webNavReturnImg){
        self.webNavReturnImg = model.webNavReturnImg;
    }else{
        NSURL * deleteIcon = [[NSURL alloc] initWithString:@"https://www.mysubmail.com/libraries/zh_cn/images/mail_box_close_off.png"];
        self.webNavReturnImg = [UIImage imageWithData: [NSData dataWithContentsOfURL:deleteIcon]];
    }
    
    
    
    __weak OclModel * weakSelf = model;
    if(model.authViewBlock){
        __strong OclModel * stongSelf = weakSelf;
        stongSelf.authViewBlock(self.authpage.authVC);
    }
    
    
    
    //最后添加按钮，保证按钮在最上层
    [self.authpage initLoginButton:loginBt];
    [controller presentViewController:self.authpage animated:NO completion:nil];
    
    
    self.authpage.loginblock = ^(AuthPage * _Nullable authVC) {
        if(model.authLoadingViewBlock){
            __strong OclModel * stongSelf = weakSelf;
            stongSelf.authLoadingViewBlock(self.authpage.authVC);
        }
        [self getAccessToken:controller WithModel:model complete:^(NSDictionary * _Nullable response) {
            complatetion(response);
        }];
    };
}


#pragma mark ======================拉起电信授权页===================
- (void)makeCTAuthPageWithModel:(OclModel *)model withController:(UIViewController *) controller complate:(LoginBlock)complatetion{
    
    
    AuthPage * atpage = [AuthPage new];
    self.authpage = atpage;
    CGFloat height = controller.view.frame.size.height;
    CGFloat width  = controller.view.frame.size.width;
    
    self.authpage.view.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:0.0];
    
    self.authpage.authVC = [[UIView alloc] init];
    [self.authpage.view addSubview:self.authpage.authVC];
    
    
    
    if(model.authBackgroundImage){
        self.authpage.authVC.backgroundColor = [UIColor colorWithPatternImage:model.authBackgroundImage];
    }else{
        self.authpage.authVC.backgroundColor = UIColor.whiteColor;
    }
    self.authpage.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    
    if([model.windowStyle intValue] == 1){
        self.authpage.authVC.frame = CGRectMake(0, height, width, height);
        self.authpage.rect = CGRectMake(0, 0, width, height);
    }else if([model.windowStyle intValue] == 2){
        if(!model.windowScaleH){
            model.windowScaleH = 0.4;
        }
        self.authpage.authVC.frame = CGRectMake(0, height, width, height*model.windowScaleH);
        self.authpage.rect = CGRectMake(0, height*(1 - model.windowScaleH), width, height*model.windowScaleH);
    }else if([model.windowStyle intValue] == 3){
        if(!model.windowScaleH){
            model.windowScaleH = 0.5;
        }
        if(!model.windowScaleW){
            model.windowScaleW = 0.8;
        }
        self.authpage.authVC.frame = CGRectMake(width*(1-model.windowScaleW)/2, height, width*model.windowScaleW, height*model.windowScaleH);
        self.authpage.rect = CGRectMake(width*(1-model.windowScaleW)/2, height*(1 - model.windowScaleH)/2, width*model.windowScaleW, height*model.windowScaleH);
    }
    
    //窗口corner
    if(!model.windowCornerRadius){
        model.windowCornerRadius = 10;
    }
    self.authpage.authVC.layer.cornerRadius = model.windowCornerRadius;
    
    
    /**
     登录按钮
     */
    UIButton * loginBt = [[UIButton alloc] init];
    [loginBt setAttributedTitle:model.loginBtnText forState:UIControlStateNormal];
    CGFloat bty = 0.0;
    CGFloat btx = (self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2;
    if(!model.loginBtnOffsetY){
        bty = (self.authpage.authVC.frame.size.height - model.loginBtnHeight)/2;
    }else{
        bty = [model.loginBtnOffsetY floatValue];
    }
    loginBt.frame = CGRectMake(btx, bty, model.loginBtnWidth, model.loginBtnHeight);
    [loginBt setBackgroundImage:model.loginBtnImgs[0] forState:UIControlStateNormal];
    [loginBt setBackgroundImage:model.loginBtnImgs[1] forState:UIControlStateDisabled];
    [loginBt setBackgroundImage:model.loginBtnImgs[2] forState:UIControlStateHighlighted];
    if(model.privacyState){
        loginBt.enabled = YES;
    }else{
        loginBt.enabled = NO;
    }
    
    /**
     号码Label
     */
    UILabel * numberLabel = [[UILabel alloc] init];
    NSMutableAttributedString * numberText = [[NSMutableAttributedString alloc] initWithAttributedString:model.numberText];
    NSRange range = {0,model.numberText.length};
    [numberText replaceCharactersInRange:range withString:self.securityPhone];
    [numberLabel setAttributedText:numberText];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    if(model.numberOffsetY){
        numberLabel.frame = CGRectMake(0, [model.numberOffsetY intValue], self.authpage.authVC.frame.size.width, 48);
    }else{
        numberLabel.frame = CGRectMake(0, (bty - 24)/2, self.authpage.authVC.frame.size.width, 48);
    }
    [self.authpage.authVC addSubview:numberLabel];
    
    /**
     协议栏
     */
    NSString * operator = @"天翼账号服务与隐私协议";
    NSMutableAttributedString * mas = [NSMutableAttributedString alloc];
    if(!model.privacyText){
        mas =  [mas initWithString:@"同意天翼账号服务与隐私协议并支持一键登录" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        NSRange operatorRange = [mas.mutableString rangeOfString:operator];
        [mas addAttributes:@{NSForegroundColorAttributeName:model.privacyColor} range:operatorRange];
        [mas addAttribute:NSLinkAttributeName value:@"https://e.189.cn/sdk/agreement/detail.do?hidetop=true" range:operatorRange];
    }else{
        mas = [mas initWithAttributedString:model.privacyText];
        NSRange operatorRange = [mas.mutableString rangeOfString:@"&&默认&&"];
        NSAttributedString * operragePrivacy = [[NSAttributedString alloc]initWithString:operator attributes:@{NSLinkAttributeName:@"https://e.189.cn/sdk/agreement/detail.do?hidetop=true",NSForegroundColorAttributeName:model.privacyColor}];
        [mas replaceCharactersInRange:operatorRange withAttributedString:operragePrivacy];
        if(model.privacy.count > 0){
            for (int i = 0; i < model.privacy.count; i++) {
                NSRange range = [mas.mutableString rangeOfString:[model.privacy objectAtIndex:i].string];
                [mas addAttributes:@{NSForegroundColorAttributeName:model.privacyColor} range:operatorRange];
                [mas replaceCharactersInRange:range withAttributedString:[model.privacy objectAtIndex:i]];
            }
        }
    }
    NSAttributedString * privacy = [[NSAttributedString alloc] initWithAttributedString:mas];
    UITextView * privaryLabel = [[UITextView alloc] init];
    CGFloat py = model.privacyOffsetY?[model.privacyOffsetY floatValue]:self.authpage.authVC.frame.size.height-55;
    privaryLabel.frame = CGRectMake( (self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2 - 20, py, model.loginBtnWidth + 40, 40);
    privaryLabel.attributedText = privacy;
    privaryLabel.textAlignment = NSTextAlignmentCenter;
    privaryLabel.delegate = self;
    privaryLabel.editable = NO;
    [self.authpage.authVC addSubview:privaryLabel];
    
    //协议checkbox
    if(model.checkboxDisplay){
        if(!model.checkboxSize){
            model.checkboxSize = @12;
        }
        UIButton * ckBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.authpage.authVC.frame.size.width - model.loginBtnWidth)/2 - 20 - [model.checkboxSize floatValue], py+10, [model.checkboxSize floatValue], [model.checkboxSize floatValue])];
        [ckBtn setBackgroundImage:model.uncheckedImg forState:UIControlStateNormal];
        [ckBtn setBackgroundImage:model.checkedImg forState:UIControlStateSelected];
        if(model.privacyState){
            ckBtn.selected = YES;
            loginBt.enabled = YES;
        }else{
            ckBtn.selected = NO;
            loginBt.enabled = NO;
        }
        [self.authpage initCheckButton:ckBtn];
    }
    
    //协议页面
    if(model.webNavColor){
        self.webNavColor = model.webNavColor;
    }else{
        self.webNavColor = [UIColor colorWithRed:0/255.f green:108/255.f blue:255/255.f alpha:1];
    }
    if(model.webNavReturnImg){
        self.webNavReturnImg = model.webNavReturnImg;
    }else{
        NSURL * deleteIcon = [[NSURL alloc] initWithString:@"https://www.mysubmail.com/libraries/zh_cn/images/mail_box_close_off.png"];
        self.webNavReturnImg = [UIImage imageWithData: [NSData dataWithContentsOfURL:deleteIcon]];
    }
    
    
    
    __weak OclModel * weakSelf = model;
    if(model.authViewBlock){
        __strong OclModel * stongSelf = weakSelf;
        stongSelf.authViewBlock(self.authpage.authVC);
    }
    
    //最后添加按钮，保证按钮在最上层
    [self.authpage initLoginButton:loginBt];
    [controller presentViewController:self.authpage animated:NO completion:nil];
    
    
    self.authpage.loginblock = ^(AuthPage * _Nullable authVC) {
        if(model.authLoadingViewBlock){
            __strong OclModel * stongSelf = weakSelf;
            stongSelf.authLoadingViewBlock(self.authpage.authVC);
        }
        [self getAccessToken:controller WithModel:model complete:^(NSDictionary * _Nullable response) {
            complatetion(response);
        }];
    };
    
    
}


#pragma mark ======================请求取号token===================
- (void)getAccessToken:(UIViewController *)controller WithModel:(OclModel *)model complete:(LoginBlock)completion{
    NSNumber * type = [[HYUniLoginSDK shareInstance] getOperatorType];
    if([type intValue] == 1){
    //移动端配置
        UACustomModel * cmccModel = [[UACustomModel alloc] init];
        cmccModel.currentVC = controller;
        cmccModel = [OclLogin makeCMAuthPage:cmccModel withModel:model withController:controller];
        [HYUniLoginSDK shareInstance].cmccModel = cmccModel;
        if(self.accessCodeState){
            if([self.model isEqualToString:@"0"]){
                [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                    NSDictionary * data = [[NSDictionary alloc] init];
                    if([resultDic[@"code"] intValue] == 200087){
                        data = @{
                            @"code" : @1,
                            @"msg" : @"授权界面成功弹起",
                            @"accessToken" : @"",
                        };
                    }else if([resultDic[@"code"] intValue] == 0){
                        data = @{
                            @"code" : @0,
                            @"msg" : @"获取token成功",
                            @"accessToken" : resultDic[@"accessToken"],
                        };
                    }else{
                        data = @{
                            @"code" : resultDic[@"code"],
                            @"msg" : @"获取token失败",
                            @"accessToken" : @"",
                        };
                    }
                    completion(data);
                }];
            }else{
                [UASDKLogin.shareLogin getAuthorizationWithModel:cmccModel complete:^(id  _Nonnull sender) {
                    NSDictionary * data = [[NSDictionary alloc] init];
                    if([sender[@"resultCode"] intValue] == 200087){
                        data = @{
                            @"code" : @1,
                            @"msg" : @"授权界面成功弹起",
                            @"accessToken" : @"",
                        };
                    }else if([sender[@"resultCode"] intValue] == 103000){
                        data = @{
                            @"code" : @0,
                            @"msg" : @"获取token成功",
                            @"accessToken" : sender[@"token"],
                        };
                    }else{
                        data = @{
                            @"code" : sender[@"resultCode"],
                            @"msg" : @"获取token失败",
                            @"accessToken" : @"",
                        };
                    }
                    completion(data);
                }];
            }
        }else{
            [self getAccessCodeFinishBlock:^(NSDictionary * _Nullable respnse) {
                if([self.model isEqualToString:@"0"]){
                    [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                        NSDictionary * data = [[NSDictionary alloc] init];
                        if([resultDic[@"code"] intValue] == 200087){
                            data = @{
                                @"code" : @1,
                                @"msg" : @"授权界面成功弹起",
                                @"accessToken" : @"",
                            };
                        }else if([resultDic[@"code"] intValue] == 0){
                            data = @{
                                @"code" : @0,
                                @"msg" : @"获取token成功",
                                @"accessToken" : resultDic[@"accessToken"],
                            };
                        }else{
                            data = @{
                                @"code" : resultDic[@"code"],
                                @"msg" : @"获取token失败",
                                @"accessToken" : @"",
                            };
                        }
                        completion(data);
                    }];
                }else{
                    [UASDKLogin.shareLogin getAuthorizationWithModel:cmccModel complete:^(id  _Nonnull sender) {
                        NSDictionary * data = [[NSDictionary alloc] init];
                        if([sender[@"resultCode"] intValue] == 200087){
                            data = @{
                                @"code" : @1,
                                @"msg" : @"授权界面成功弹起",
                                @"accessToken" : @"",
                            };
                        }else if([sender[@"resultCode"] intValue] == 103000){
                            data = @{
                                @"code" : @0,
                                @"msg" : @"获取token成功",
                                @"accessToken" : sender[@"token"],
                            };
                        }else{
                            data = @{
                                @"code" : sender[@"resultCode"],
                                @"msg" : @"获取token失败",
                                @"accessToken" : @"",
                            };
                        }
                        completion(data);
                    }];
                }
            }];
        }
    
    }else if([type intValue] == 2){
    //联通授权业拉起
        if(self.accessCodeState){
            if(!self.authpageState){
                [self makeCUAuthPageWithModel:model withController:controller complate:completion];
                self.authpageState = YES;
                NSDictionary * data = [[NSDictionary alloc] init];
                data = @{
                    @"code" : @1,
                    @"msg" : @"授权界面成功弹起",
                    @"accessToken" : @"",
                };
                completion(data);
            }else{
                if([self.model isEqualToString:@"0"]){
                    [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                         NSDictionary * data = [[NSDictionary alloc] init];
                         if([resultDic[@"code"] intValue] == 0){
                            data = @{
                                @"code" : @0,
                                @"msg" : @"获取token成功",
                                @"accessToken" : resultDic[@"accessToken"],
                            };
                        }else{
                            data = @{
                                @"code" : resultDic[@"code"],
                                @"msg" : @"获取token失败",
                                @"accessToken" : @"",
                            };
                        }
                        self.accessCodeState = NO;
                        completion(data);
                    }];
                }else{
                    [[UniAuthHelper getInstance] getAccessToken:self.timeout accessCode:self.accessCode listener:^(NSDictionary *resultDic) {
                        NSDictionary * data = [[NSDictionary alloc] init];
                         if([resultDic[@"resultCode"] intValue] == 0){
                            data = @{
                                @"code" : @0,
                                @"msg" : @"获取token成功",
                                @"accessToken" : resultDic[@"resultData"][@"access_token"],
                            };
                        }else{
                            data = @{
                                @"code" : resultDic[@"resultCode"],
                                @"msg" : @"获取token失败",
                                @"accessToken" : @"",
                            };
                        }
                        self.accessCodeState = NO;
                        completion(data);
                    }];
                }
                
            }
            
        }else{
            [self getAccessCodeFinishBlock:^(NSDictionary * _Nullable respnse) {
                if(!self.authpageState){
                    [self makeCUAuthPageWithModel:model withController:controller complate:completion];
                    self.authpageState = YES;
                    NSDictionary * data = [[NSDictionary alloc] init];
                    data = @{
                        @"code" : @1,
                        @"msg" : @"授权界面成功弹起",
                        @"accessToken" : @"",
                    };
                    completion(data);
                }else{
                    if([self.model isEqualToString:@"0"]){
                        [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                             NSDictionary * data = [[NSDictionary alloc] init];
                             if([resultDic[@"code"] intValue] == 0){
                                data = @{
                                    @"code" : @0,
                                    @"msg" : @"获取token成功",
                                    @"accessToken" : resultDic[@"accessToken"],
                                };
                            }else{
                                data = @{
                                    @"code" : resultDic[@"code"],
                                    @"msg" : @"获取token失败",
                                    @"accessToken" : @"",
                                };
                            }
                            self.accessCodeState = NO;
                            completion(data);
                        }];
                    }else{
                        [[UniAuthHelper getInstance] getAccessToken:self.timeout accessCode:self.accessCode listener:^(NSDictionary *resultDic) {
                            NSDictionary * data = [[NSDictionary alloc] init];
                             if([resultDic[@"resultCode"] intValue] == 0){
                                data = @{
                                    @"code" : @0,
                                    @"msg" : @"获取token成功",
                                    @"accessToken" : resultDic[@"resultData"][@"access_token"],
                                };
                            }else{
                                data = @{
                                    @"code" : resultDic[@"resultCode"],
                                    @"msg" : @"获取token失败",
                                    @"accessToken" : @"",
                                };
                            }
                            self.accessCodeState = NO;
                            completion(data);
                        }];
                    }
                }
            }];
        }
    }else if([type intValue] == 3){
    //电信授权业拉起
        if(self.accessCodeState){
            if(!self.authpageState){
                [self makeCTAuthPageWithModel:model withController:controller complate:completion];
                self.authpageState = YES;
                NSDictionary * data = [[NSDictionary alloc] init];
                data = @{
                    @"code" : @1,
                    @"msg" : @"授权界面成功弹起",
                    @"accessToken" : @"",
                };
                completion(data);
            }else{
                [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                     NSDictionary * data = [[NSDictionary alloc] init];
                     if([resultDic[@"code"] intValue] == 0){
                        data = @{
                            @"code" : @0,
                            @"msg" : @"获取token成功",
                            @"accessToken" : resultDic[@"accessToken"],
                            @"authCode" : resultDic[@"authCode"],
                        };
                    }else{
                        data = @{
                            @"code" : @-1,
                            @"msg" : @"获取token失败",
                            @"accessToken" : @"",
                        };
                    }
                    self.accessCodeState = NO;
                    completion(data);
                }];
            }
            
        }else{
            [self getAccessCodeFinishBlock:^(NSDictionary * _Nullable respnse) {
                if(!self.authpageState){
                    [self makeCTAuthPageWithModel:model withController:controller complate:completion];
                    self.authpageState = YES;
                    NSDictionary * data = [[NSDictionary alloc] init];
                    data = @{
                        @"code" : @1,
                        @"msg" : @"授权界面成功弹起",
                        @"accessToken" : @"",
                    };
                    completion(data);
                }else{
                    [[HYUniLoginSDK shareInstance] uniGetAccessTokenWithAccessCode:self.accessCode finishBlock:^(NSDictionary * _Nullable resultDic) {
                         NSDictionary * data = [[NSDictionary alloc] init];
                         if([resultDic[@"code"] intValue] == 0){
                            data = @{
                                @"code" : @0,
                                @"msg" : @"获取token成功",
                                @"accessToken" : resultDic[@"accessToken"],
                                @"authCode" : resultDic[@"authCode"],
                            };
                        }else{
                            data = @{
                                @"code" : @-1,
                                @"msg" : @"获取token失败",
                                @"accessToken" : resultDic[@"msg"],
                            };
                        }
                        self.accessCodeState = NO;
                        completion(data);
                    }];
                }
            }];
        }
    }
}
#pragma mark ======================关闭授权页==========================
- (void)closeAuthViewController{
    self.authpageState = NO;
}

#pragma mark ======================预取号==========================

-(void)getAccessCodeFinishBlock:(LoginBlock)completion{
    int type = [[self getWorkType] intValue];
    if([self.model isEqualToString:@"0"]){
        [[HYUniLoginSDK shareInstance] uniGetAccessCodeFinishBlock:^(NSDictionary * _Nullable resultDic) {
            NSDictionary * data = [[NSDictionary alloc] init];
            if([resultDic[@"code"]  isEqual: @0]){
                self.accessCode = resultDic[@"accessCode"];
                self.securityPhone = resultDic[@"securityPhone"];
                self.accessCodeState = YES;
                data = @{
                    @"status":@"success"
                };
            }else{
                data = @{
                    @"status":@"error"
                };
            }
            completion(data);
        }];
    }else{
        if(type == 1){
            [UASDKLogin.shareLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull result) {
                NSDictionary * data = [[NSDictionary alloc] init];
                if([result[@"desc"]  isEqualToString: @"success"]){
                    self.accessCode = result[@"traceId"];
                    self.securityPhone = @"";
                    self.accessCodeState = YES;
                    data = @{
                        @"status":@"success"
                    };
                }else{
                    data = @{
                        @"status":@"error"
                    };
                }
                completion(data);
            }];
        }else if(type == 2){
            [[UniAuthHelper getInstance] getAccessCode:self.timeout  listener:^(NSDictionary *data) {
                NSNumber * status = data[@"resultCode"];
                NSDictionary * resultData = [[NSDictionary alloc] init];
                if([status intValue] == 0){
                    self.accessCode = data[@"resultData"][@"accessCode"];
                    self.securityPhone = data[@"resultData"][@"mobile"];
                    self.accessCodeState = YES;
                    resultData = @{
                        @"status":@"success"
                    };
                }else{
                    resultData = @{
                        @"status":@"error"
                    };
                }
                completion(resultData);
            }];
        }else if(type == 3){
            [[HYUniLoginSDK shareInstance] uniGetAccessCodeFinishBlock:^(NSDictionary * _Nullable resultDic) {
                NSDictionary * data = [[NSDictionary alloc] init];
                if([resultDic[@"code"]  isEqual: @0]){
                    self.accessCode = resultDic[@"accessCode"];
                    self.securityPhone = resultDic[@"securityPhone"];
                    self.accessCodeState = YES;
                    data = @{
                        @"status":@"success"
                    };
                }else{
                    data = @{
                        @"status":@"error"
                    };
                }
                completion(data);
            }];
            
              //电信不完整版，缺少脱敏手机号
//            NSDictionary * data = [[NSDictionary alloc] init];
//            self.accessCode = @"";
//            self.securityPhone = @"";
//            self.accessCodeState = YES;
//            data = @{
//                @"status":@"success"
//            };
//            completion(data);
        }
    }
    
}

#pragma mark ======================初始化==========================
-(void)initWithAppId:(nonnull NSString *)appId AppKey:(nonnull NSString *)appKey{
    
    //判断运营商类型
    NSNumber * worktype = [self getWorkType];
    NSURL * url_post = [NSURL URLWithString:@"https://api.wayincloud.com/ocl/getConfigs"];
    NSMutableURLRequest * request_post = [NSMutableURLRequest requestWithURL:url_post];
    request_post.HTTPMethod = @"POST";
    NSString * timestamp = [OclLogin getCurrentTimer];
    
    NSString * authstr = [[NSString alloc] initWithFormat:@"%@%@%@",appId,timestamp,AUTHCODE];
    authstr = [OclLogin getSHA256:authstr];
    
    NSString * params = [[NSString alloc] initWithFormat:@"appid=%@&appkey=%@&sign=%@&platform=IOS&timestamp=%@&type=%@",appId,appKey,authstr,timestamp,worktype];
    
    request_post.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession * session_post = [NSURLSession sharedSession];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *task_post = [session_post dataTaskWithRequest:request_post completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == NULL){
            NSError * err;
            NSDictionary * conf = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
            if(err == NULL){
                NSNumber * code = [conf objectForKey:@"code"];
                if([code intValue] == 0){
                    NSString * appid = [conf objectForKey:@"appid"];
                    NSString * appkey = [conf objectForKey:@"appkey"];
                    
                    self.model = [conf objectForKey:@"model"];
                    if([self.model isEqualToString:@"0"]){
                        [[HYUniLoginSDK shareInstance] initWithApiKey:appid Appsecrect:appkey];
                    }else{
                        if([worktype intValue] == 1){
                            [UASDKLogin.shareLogin registerAppId:appid AppKey:appkey];
                        }else if([worktype intValue] == 2){
                            [[UniAuthHelper getInstance] initWithAppId:appid appSecret:appkey];
                        }else if([worktype intValue] == 3){
                            [[HYUniLoginSDK shareInstance] initWithApiKey:appid Appsecrect:appkey];
                            //[EAccountSDK initWithSelfKey:appid appSecret:appkey];
                        }
                    }
                }else{
                    NSLog(@"初始化失败！错误代码：%@", conf);
                }
                
                dispatch_semaphore_signal(sem);
            }else{
                NSLog(@"服务器数据异常！%@", conf);
            }
        }else{
            NSLog(@"服务器错误，请联系管理员！%@",error);
        }
    }];
    [task_post resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}


#pragma mark ======================生成移动model======================
+ (UACustomModel *)makeCMAuthPage:(UACustomModel *)cmccModel withModel:(OclModel *) model withController:(UIViewController *)controller{
    CGFloat height = controller.view.frame.size.height;
    CGFloat width  = controller.view.frame.size.width;
    
    //窗口模式
    if([model.windowStyle intValue] == 2){
        if(model.windowScaleW && model.windowScaleH){
            cmccModel.controllerSize = CGSizeMake(width, height*model.windowScaleH);
        }else{
            model.windowScaleH = 0.4;
            cmccModel.controllerSize = CGSizeMake(width, height*model.windowScaleH);
        }
    }
    
    if([model.windowStyle intValue] == 3){
        cmccModel.authWindow = YES;
        cmccModel.cornerRadius = model.windowCornerRadius;
        if(model.windowScaleW){
            cmccModel.scaleW = model.windowScaleW;
        }else{
            cmccModel.scaleW = 0.8;
        }
        if(model.windowScaleH){
            cmccModel.scaleH = model.windowScaleH;
        }else{
            cmccModel.scaleH = 0.5;
        }
    }
    if(model.authBackgroundImage){
        cmccModel.authPageBackgroundImage = model.authBackgroundImage;
    }
    cmccModel.presentType = 0;
    cmccModel.modalTransitionStyle = 1;
    
    
    
    //按钮设置
    cmccModel.logBtnText = model.loginBtnText;
    cmccModel.logBtnHeight = model.loginBtnHeight;
    CGFloat btnLR = (width - model.loginBtnWidth)/2;
    if([model.windowStyle intValue] == 3){
        btnLR = (width*cmccModel.scaleW - model.loginBtnWidth)/2;
    }
    NSNumber * btnlr = [[NSNumber alloc] initWithFloat:btnLR];
    cmccModel.logBtnOriginLR = @[btnlr,btnlr];
    if(model.loginBtnOffsetY){
        cmccModel.logBtnOffsetY = model.loginBtnOffsetY;
    }else{
        if([model.windowStyle intValue] == 1){
            cmccModel.logBtnOffsetY = [NSNumber numberWithFloat:(height-model.loginBtnHeight)/2];
        }else if([model.windowStyle intValue] == 2){
            cmccModel.logBtnOffsetY = [NSNumber numberWithFloat:(height*model.windowScaleH-model.loginBtnHeight)/2];
        }else if([model.windowStyle intValue] == 3){
            cmccModel.logBtnOffsetY = [NSNumber numberWithFloat:(height*cmccModel.scaleH-model.loginBtnHeight)/2];
        }
        
    }
    
    cmccModel.logBtnImgs = model.loginBtnImgs;
    
    //号码样式
    cmccModel.numberText = model.numberText;
    if(model.numberOffsetY){
        cmccModel.numberOffsetY = model.numberOffsetY;
    }else{
        model.numberOffsetY = [NSNumber numberWithInt:([cmccModel.logBtnOffsetY intValue] - 24)/2];
        cmccModel.numberOffsetY = model.numberOffsetY;
    }
    
    
    //条款
    cmccModel.privacyState = model.privacyState;
    if(model.checkboxDisplay){
        cmccModel.uncheckedImg = model.uncheckedImg;
        cmccModel.checkedImg = model.checkedImg;
        cmccModel.checkboxWH = model.checkboxSize;
    }else{
        cmccModel.checkboxWH = @1;
        cmccModel.privacyState = YES;
    }
    if(model.privacyText){
        cmccModel.appPrivacyDemo = model.privacyText;
    }
    if(model.privacyColor){
        cmccModel.privacyColor = model.privacyColor;
    }
    if(model.privacy){
        cmccModel.appPrivacy = model.privacy;
    }
    if(model.privacyOffsetY){
        cmccModel.privacyOffsetY = model.privacyOffsetY;
    }
    cmccModel.appPrivacyAlignment = NSTextAlignmentCenter;
    
    if(model.webNavColor){
        cmccModel.webNavColor = model.webNavColor;
    }
    if(model.webNavReturnImg){
        cmccModel.webNavReturnImg = model.webNavReturnImg;
    }
    
    //自定义控件
    
    cmccModel.authViewBlock = ^(UIView *customView, CGRect numberFrame, CGRect loginBtnFrame, CGRect checkBoxFrame, CGRect privacyFrame) {
        model.authViewBlock(customView);
    };
    
    cmccModel.authLoadingViewBlock = ^(UIView *loadingView) {
        model.authLoadingViewBlock(loadingView);
    };
    
    return cmccModel;
}



#pragma mark ======================获取当前时间戳==========================
+(NSString *) getCurrentTimer{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

/**
 sha256加密
 
 @return 加密后的字符串
 */
+(NSString *) getSHA256:(NSString *) string {
    const char * str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:str length:strlen(str)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    const unsigned *hashBytes = [out bytes];
    NSString * hash = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",ntohl(hashBytes[0]),ntohl(hashBytes[1]),ntohl(hashBytes[2]),ntohl(hashBytes[3]),ntohl(hashBytes[4]),ntohl(hashBytes[5]),ntohl(hashBytes[6]),ntohl(hashBytes[7])];
    return hash;
}


#pragma mark ======================单例==========================
+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
-(nonnull id)copyWithZone:(nonnull NSZone *)zone{
    return _instance;
}

-(nonnull id)mutableCopyWithZone:(nullable NSZone *)zone{
    return _instance;
}
@end
