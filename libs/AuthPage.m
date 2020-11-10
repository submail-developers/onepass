//
//  AuthPage.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/27.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "AuthPage.h"
#import "OclLogin.h"

@interface AuthPage ()<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton * loginButton;
@property (nonatomic, weak) IBOutlet UIButton * checkButton;


@end

@implementation AuthPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    self.authpageState = YES;
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.authVC.frame = self.rect;
    } completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    self.authpageState = NO;
    [[OclLogin sharedInstance] closeAuthViewController];
}

/**
 登录点击
 */
- (void)loginRequst:(UIButton *)button{
    if(self.loginblock){
        self.loginblock(self);
    }
}

/**
 协议按钮点击
 */
- (void)checkPolicy:(UIButton *)button{
    button.selected = !button.selected;
    self.loginButton.enabled = self.checkButton.isSelected;
}

/**
 初始化按钮
 */
- (void)initLoginButton:(UIButton *)button{
    self.loginButton = button;
    [self.loginButton addTarget:self action:@selector(loginRequst:) forControlEvents:UIControlEventTouchUpInside];
    [self.authVC addSubview:self.loginButton];
}

/**
 初始化复选框
 */
- (void)initCheckButton:(UIButton *)button{
    self.checkButton = button;
    [self.checkButton addTarget:self action:@selector(checkPolicy:) forControlEvents:UIControlEventTouchUpInside];
    [self.authVC addSubview:self.checkButton];
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
