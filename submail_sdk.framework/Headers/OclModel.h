//
//  OclModel.h
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OclModel : NSObject


#pragma mark ======================授权页=========================

@property (nonatomic, weak) UIViewController * authVC;

@property (nonatomic, strong) UIImage * authBackgroundImage;

#pragma mark ======================登录按钮=======================
//登录按钮文本、大小、颜色
@property (nonatomic, strong) NSAttributedString *loginBtnText;
//登录按钮高度
@property (nonatomic, assign) CGFloat loginBtnHeight;
//登录按钮宽度
@property (nonatomic, assign) CGFloat loginBtnWidth;
//登录按钮距离控件顶部距离
@property (nonatomic, strong) NSNumber * loginBtnOffsetY;
//登录按钮背景图片
@property (nonatomic, strong) NSArray * loginBtnImgs;

#pragma mark ======================脱敏手机号展示===================
//号码文本、大小、颜色
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey,id> * numberTextAttributes;
//号码框距离顶部距离
@property (nonatomic, strong) NSNumber * numberOffsetY;
//号码框距离底部距离
@property (nonatomic, strong) NSNumber * numberOffsetY_B;

#pragma mark ========================隐私条款======================
/*
 *  默认不显示复选框
 *  协议默认选中
 */
//是否显示复选框
@property (nonatomic, assign) BOOL checkboxDisplay;
//复选框未选中时图片
@property (nonatomic, strong) UIImage *uncheckedImg;
//复选框选中时的图片
@property (nonatomic, strong) UIImage *checkedImg;
//复选框大小
@property (nonatomic, strong) NSNumber *checkboxSize;
//
//协议状态
@property (nonatomic, assign) BOOL privacyState;

//协议文本
@property (nonatomic, copy) NSAttributedString * privacyText;
//额外协议
@property (nonatomic, strong) NSArray <NSAttributedString *> * privacy;
//协议颜色统一设置
@property (nonatomic, strong) UIColor * privacyColor;
//协议Y轴偏移
@property (nonatomic, strong) NSNumber * privacyOffsetY;
//协议x轴偏移
@property (nonatomic, strong) NSArray <NSNumber *> *privacyMarginLR;

/**未勾选隐私条款提示的自定义提示文案，提示功能默认关闭，该属性设置有效时打开提示功能。*/
@property (nonatomic, strong) NSString *checkTipText;


#pragma mark ========================协议页面======================
//返回按钮颜色
@property (nonatomic, strong)UIImage *webNavReturnImg;
//标题栏颜色
@property (nonatomic, strong)UIColor *webNavColor;
//标题文字属性
@property (nonatomic,strong) NSDictionary<NSAttributedStringKey, id> *webNavTitleAttrs;


#pragma mark ========================窗口模式======================
//1=全屏模式  2=边缘弹窗  3=浮动弹窗
@property (nonatomic, strong)NSNumber * windowStyle;
//窗口圆角
@property (nonatomic, assign)CGFloat windowCornerRadius;
//弹窗模式下，窗口大小
@property (nonatomic, assign)CGFloat windowScaleH;
@property (nonatomic, assign)CGFloat windowScaleW;


#pragma mark ======================自定义控件======================
@property (nonatomic, copy) void(^authViewBlock)(UIView *customView);

@property (nonatomic, copy) void(^authLoadingViewBlock)(UIView *loadingView);

@end

NS_ASSUME_NONNULL_END
