//
//  ViewController.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "ViewController.h"
#import "AuthorizationController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * alertBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    alertBtn.frame = CGRectMake(self.view.frame.size.width/2-120, self.view.frame.size.height/2-25, 240, 50);
    alertBtn.backgroundColor = [UIColor blueColor];
    alertBtn.titleLabel.font = [UIFont systemFontOfSize:20.f];
    alertBtn.layer.cornerRadius = 4;
    alertBtn.tintColor = [UIColor whiteColor];
    [alertBtn setTitle:@"一键登陆DEMO" forState:UIControlStateNormal];
    [alertBtn addTarget:self action:@selector(alertAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alertBtn];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.progress = 0.4;
    hud.dimBackground = YES;
    [self.view addSubview:hud];
    
    hud.hidden = YES;
}


- (void) alertAction{
    AuthorizationController * vc = [AuthorizationController new];
    
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
}

@end
