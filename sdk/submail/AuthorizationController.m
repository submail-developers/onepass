//
//  AuthorizationController.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "AuthorizationController.h"
#import <submail_sdk/OclModel.h>
#import <CommonCrypto/CommonHMAC.h>
#import <submail_sdk/OclLogin.h>
#import "MBProgressHUD.h"

#define APPID @""
#define APPKEY @""



@interface UIImage (Color)
//创建纯色图片
+(UIImage *) js_createImageWithColor:(UIColor *)color withSize:(CGSize)imageSize;
//创建圆角图片
+(UIImage *) js_imageWithOriginalImage:(UIImage *)originalImage;
//创建圆角纯色图片
+(UIImage *) js_createRoundedImageWithColor:(UIColor *) color withSize:(CGSize) imageSize;
//带圆环的圆角图片
+(UIImage *) js_imageWithOriginalImage:(UIImage *)originalImage withBorderColor:(UIColor *) borderColor withBorderWidth:(CGFloat) borderWith;
@end

@implementation UIImage (Color)

//生成纯色图片
+(UIImage *) js_createImageWithColor:(UIColor *)color withSize:(CGSize)imageSize{
    CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
//生成圆角图片
+(UIImage *) js_imageWithOriginalImage:(UIImage *)originalImage{
    CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
    CGFloat cornerRadius = MIN(originalImage.size.width, originalImage.size.height) * 0.5;
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    [originalImage drawInRect:rect];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//生成纯色图片
+(UIImage *) js_createRoundedImageWithColor:(UIColor *)color withSize:(CGSize)imageSize{
    UIImage * originalImage = [self js_createRoundedImageWithColor:color withSize:imageSize];
    return [self js_imageWithOriginalImage:originalImage];
}
//生成带圆环的圆角图片
+(UIImage *) js_imageWithOriginalImage:(UIImage *)originalImage withBorderColor:(UIColor *)borderColor withBorderWidth:(CGFloat)borderWith{
    CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
    CGFloat cornerRadius = MIN(originalImage.size.width, originalImage.size.height) * 0.5;
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    [originalImage drawInRect:rect];
    CGPoint center = CGPointMake(originalImage.size.width * 0.5, originalImage.size.height * 0.5);
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:cornerRadius - borderWith*0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    circlePath.lineWidth = borderWith;
    [borderColor setStroke];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//生成带圆环的圆角图片
+(UIImage *) js_imageWithOriginalImage:(UIImage *)originalImage withBorderColor:(UIColor *)borderColor withBorderWidth:(CGFloat)borderWith withBorderRadius:(CGFloat)cornerRadius{
    CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    [originalImage drawInRect:rect];
    CGPoint center = CGPointMake(originalImage.size.width * 0.5, originalImage.size.height * 0.5);
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:cornerRadius - borderWith*0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    circlePath.lineWidth = borderWith;
    [borderColor setStroke];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end



#pragma mark =============AuthorizationController===============

@interface AuthorizationController ()

@property (nonatomic) UITextView * textview;
@property (nonatomic, strong) NSString * accessCode;//预取号凭证
@property (nonatomic, strong) NSString * securityPhone;//脱敏手机号

@end

@implementation AuthorizationController

- (void)viewDidAppear:(BOOL)animated{
    //[self pressInit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///
    self.view.backgroundColor = [UIColor whiteColor];
    
    float WIDTH = self.view.frame.size.width;
    int commBtnH = 44;
    int commBtnW = 240;

    UILabel * authTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, WIDTH, 40)];
    authTipsLabel.textAlignment = NSTextAlignmentCenter;
    authTipsLabel.textColor = UIColor.blackColor;
    authTipsLabel.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
    [authTipsLabel setText:@"SUBMAIL 一键登录 demo v1.0"];
    [self.view addSubview:authTipsLabel];


    UIButton * initButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [initButton setFrame:CGRectMake((WIDTH-commBtnW)/2, 240, commBtnW, commBtnH)];
    [initButton setBackgroundColor:[UIColor blueColor]];
    [initButton setTitle:@"初始化" forState:UIControlStateNormal];
    [initButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [initButton addTarget:self action:@selector(pressInit) forControlEvents:UIControlEventTouchUpInside];
    [initButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    initButton.layer.cornerRadius = 4;
    [self.view addSubview:initButton];

    UIButton * accessCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [accessCodeButton setFrame:CGRectMake((WIDTH-commBtnW)/2, 304, commBtnW, commBtnH)];
    [accessCodeButton setBackgroundColor:[UIColor blueColor]];
    [accessCodeButton setTitle:@"预取号" forState:UIControlStateNormal];
    [accessCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accessCodeButton addTarget:self action:@selector(prepareGetAccessCode) forControlEvents:UIControlEventTouchUpInside];
    [accessCodeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    accessCodeButton.layer.cornerRadius = 4;
    [self.view addSubview:accessCodeButton];

    UIButton * loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [loginButton setFrame:CGRectMake((WIDTH-commBtnW)/2, 368, commBtnW, commBtnH)];
    [loginButton setBackgroundColor:[UIColor blueColor]];
    [loginButton setTitle:@"一键登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    loginButton.layer.cornerRadius = 4;
    [self.view addSubview:loginButton];
}

- (void)closeVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pressInit{
    
    OclLogin *ocl = [OclLogin sharedInstance];
    [ocl initWithAppId:APPID AppKey:APPKEY];
}

-(void)prepareGetAccessCode{
    OclLogin *ocl = [OclLogin sharedInstance];
    [ocl getAccessCodeFinishBlock:^(NSDictionary * _Nullable respnse) {
        NSLog(@"accessCode:%@",respnse);
    }];
}

-(void)login{
    OclLogin *ocl = [OclLogin sharedInstance];
    OclModel *om = [[OclModel alloc] init];
    om.privacyText = [[NSAttributedString alloc]initWithString:@"同意&&默认&&登录即代表您同意服务协议和使用协议" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:@"服务协议" attributes:@{NSLinkAttributeName:@"https://www.mysubmail.com/documents/QBVE31"}];
    NSAttributedString *str2 = [[NSAttributedString alloc]initWithString:@"使用协议" attributes:@{NSLinkAttributeName:@"https://www.mysubmail.com/documents/ibW2A2"}];
    om.privacy = @[str1,str2];
    
    om.webNavColor = UIColor.grayColor;
    
    UIColor * bgColor = [UIColor colorWithRed:255/255.f green:248/255.f blue:208/255.f alpha:1];
    UIImage * bgImg = [UIImage js_createImageWithColor:bgColor withSize:CGSizeMake(20, 20)];
    bgImg = [UIImage js_imageWithOriginalImage:bgImg withBorderColor:UIColor.redColor withBorderWidth:1.0f withBorderRadius:0.0f];
    om.webNavReturnImg = bgImg;
     
    om.authViewBlock = ^(UIView * _Nonnull customView) {
        NSURL * deleteIcon = [[NSURL alloc] initWithString:@"https://www.mysubmail.com/libraries/zh_cn/images/mail_box_close_off.png"];
        UIImage * image = [UIImage imageWithData: [NSData dataWithContentsOfURL:deleteIcon]];
         
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(customView.frame.size.width-30, 10, 20, 20)];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(closeVC) forControlEvents:(UIControlEventTouchUpInside)];
        [customView addSubview:btn];
        
//        UIButton *switchBtn = [[UIButton alloc]initWithFrame:CGRectMake(customView.frame.size.width/2 - 100, 250, 200, 40)];
//        [switchBtn setTitle:@"切换登录" forState:UIControlStateNormal];
//        [switchBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [switchBtn addTarget:self action:@selector(closeVC) forControlEvents:(UIControlEventTouchUpInside)];
//        [customView addSubview:switchBtn];
    };
     
    om.authLoadingViewBlock = ^(UIView * _Nonnull loadingView) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:loadingView animated:YES];
        hud.dimBackground = YES;
    };
     
    om.windowStyle = @2;
    om.windowCornerRadius = 10;
    

    [ocl getAccessToken:self WithModel:om complete:^(NSDictionary * _Nullable response) {
        NSLog(@"执行登录。。。。%@",response);
        NSNumber * type = [[OclLogin sharedInstance] getWorkType];
        NSNumber * code = response[@"code"];
        if([code intValue] == 0){
            if([type intValue] == 3){
                //电信号码
                [self getMobileWithAppid:APPID WithToken:response[@"accessToken"] withAuth:response[@"auth"] completion:^(NSDictionary * _Nullable response) {
                    //do something
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self closeVC];
                        NSString * params = [[NSString alloc] initWithFormat:@"你的号码是：%@",response[@"mobile"]];
                        __block MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:hud];
                        hud.dimBackground = YES;
                        hud.labelText = params;
                        hud.mode = MBProgressHUDModeText;
                        [hud showAnimated:YES whileExecutingBlock:^{
                                            sleep(6);
                                        } completionBlock:^{
                                            [hud removeFromSuperview];
                                            hud = nil;
                                        }];
                    });
                }];
            }else{
                //移动，联通号码
                [self getMobileWithAppid:APPID WithToken:response[@"accessToken"] withAuth:nil completion:^(NSDictionary * _Nullable response) {
                    //do something
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self closeVC];
                        NSString * params = [[NSString alloc] initWithFormat:@"你的号码是：%@",response[@"mobile"]];
                        __block MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:hud];
                        hud.dimBackground = YES;
                        hud.labelText = params;
                        hud.mode = MBProgressHUDModeText;
                        [hud showAnimated:YES whileExecutingBlock:^{
                                            sleep(6);
                                        } completionBlock:^{
                                            [hud removeFromSuperview];
                                            hud = nil;
                                        }];
                    });
                    
                }];
            }
        }
    }];
}



-(void)getMobileWithAppid:(NSString *) appid WithToken:(NSString *) token withAuth:(NSString *) auth completion:(ResBlock)completion{
    
    NSNumber * type = [[OclLogin sharedInstance] getWorkType];
    NSString * timestamp = [self getCurrentTimer];
    NSURL * url_post = [NSURL URLWithString:@"https://tpa.mysubmail.com/ocl/getMobile"];
    NSMutableURLRequest * request_post = [NSMutableURLRequest requestWithURL:url_post];
    request_post.HTTPMethod = @"POST";
    NSString * signature = APPKEY;
    signature = [[NSString alloc] initWithFormat:@"%@%@%@",signature,timestamp,token];
    signature = [AuthorizationController getSHA256:signature];
    
    NSString * params = [[NSString alloc] initWithFormat:@"appid=%@&token=%@&auth=%@&type=%@&os=IOS&timestamp=%@&signature=%@",appid,token,auth,type,timestamp,signature];
    request_post.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession * session_post = [NSURLSession sharedSession];
    NSURLSessionDataTask *task_post = [session_post dataTaskWithRequest:request_post completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == NULL){
            NSError * err;
            NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
            if(!err){
                NSLog(@"服务器响应数据：%@",result);
                completion(result);
                
            }else{
                NSLog(@"服务器数据异常！%@",result);
            }
        }else{
            NSLog(@"服务器错误====%@",error);
        }
        
    }];
    [task_post resume];
}
-(NSString *) getCurrentTimer{
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
