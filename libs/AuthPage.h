//
//  AuthPage.h
//  sdk
//
//  Created by 段晓杰 on 2020/7/27.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AuthPage;

typedef void (^loginBlock)(AuthPage * _Nullable authVC);

@interface AuthPage : UIViewController

@property (nonatomic) IBOutlet UIView * authVC;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, copy) loginBlock loginblock;
@property (nonatomic, assign) BOOL authpageState;


- (void)initLoginButton:(UIButton *)button;
- (void)initCheckButton:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
