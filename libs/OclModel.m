//
//  OclModel.m
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import "OclModel.h"

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

//typedef void (^AuthViewBlock)(void);

@interface OclModel ()


@end

@implementation OclModel

/**
 生成协议
 @return NSAttributedString
 */

//重写初始化方法
- (instancetype)init {
    self = [super init];
    
    if(self){
        /**
        按钮样式初始化
         */
        self.loginBtnText = [[NSAttributedString alloc]initWithString:@"本机号码一键登录" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//        self.loginBtnOffsetY = @400;
        self.loginBtnHeight = 48.f;
        self.loginBtnWidth = 240.f;
        UIColor * color1 = [UIColor colorWithRed:0/255.f green:108/255.f blue:255/255.f alpha:1];
        UIColor * color2 = [UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1];
        UIColor * color3 = [UIColor colorWithRed:41/255.f green:137/255.f blue:255/255.f alpha:1];
        UIImage * btnActive1 = [UIImage js_createImageWithColor:color1 withSize:CGSizeMake(self.loginBtnWidth, self.loginBtnHeight)];
        UIImage * btnActive2 = [UIImage js_createImageWithColor:color2 withSize:CGSizeMake(self.loginBtnWidth, self.loginBtnHeight)];
        UIImage * btnActive3 = [UIImage js_createImageWithColor:color3 withSize:CGSizeMake(self.loginBtnWidth, self.loginBtnHeight)];
        btnActive1 = [UIImage js_imageWithOriginalImage:btnActive1 withBorderColor:UIColor.redColor withBorderWidth:4.0f withBorderRadius:4.0f];
        btnActive2 = [UIImage js_imageWithOriginalImage:btnActive2 withBorderColor:UIColor.redColor withBorderWidth:4.0f withBorderRadius:4.0f];
        btnActive3 = [UIImage js_imageWithOriginalImage:btnActive2 withBorderColor:UIColor.redColor withBorderWidth:4.0f withBorderRadius:4.0f];
        self.loginBtnImgs = @[btnActive1,btnActive2,btnActive3];
        
        /**
         号码样式初始化
         */
        self.numberText = [[NSAttributedString alloc] initWithString:@"hidden text" attributes:@{NSForegroundColorAttributeName:UIColor.blackColor,NSFontAttributeName:[UIFont systemFontOfSize:24]}];
        
        /**
         条款
         */
        self.privacyState = YES;
        self.checkboxDisplay = NO;
        self.privacyColor = [UIColor colorWithRed:0/255.f green:108/255.f blue:255/255.f alpha:1];
        
        /**
        协议页面
         */
        self.webNavColor = [UIColor colorWithRed:0/255.f green:108/255.f blue:255/255.f alpha:1];
        NSURL * deleteIcon = [[NSURL alloc] initWithString:@"https://www.mysubmail.com/libraries/zh_cn/images/mail_box_close_on.png"];
        self.webNavReturnImg = [UIImage imageWithData: [NSData dataWithContentsOfURL:deleteIcon]];
        
        /**
        窗口模式
         */
        self.windowStyle = @2;
        self.windowCornerRadius = 10;
        
    }
    //__weak typeof (self)weakSelf = self;
    
    return self;
}



@end
