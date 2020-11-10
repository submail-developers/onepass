//
//  OclLogin.h
//  sdk
//
//  Created by 段晓杰 on 2020/7/23.
//  Copyright © 2020 段晓杰. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HYUniLoginSDK.h"
#import <TYRZSDK/TYRZSDK.h>
#import "OclModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LoginBlock)(NSDictionary *_Nullable response);

@interface OclLogin : NSObject

/**
 *获取单例对象
 *
 *@return 单例类对象
 */
+ (instancetype) sharedInstance;


/**
 网络类型

 @return 1移动，2联通，3电信
 */
- (NSNumber*)getWorkType;


/**
 初始化SDK参数
 @param appId SUBMAIL申请成功后获取的appId
 @param appKey SUBMAIL申请成功后获取的appKey
 */
- (void)initWithAppId:(NSString *)appId AppKey:(NSString *)appKey;


/**
 设置超时
 
 @param timeout 超时
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeout;

/**
 本接口用于预取号，获取取号accessCode，如果失败，应选择其他登录方式
 
 @param completion 获得accessCode
 */
- (void)getAccessCodeFinishBlock:(LoginBlock)completion;


/**
 接口用于获取取号token，如获取token失败，应选择其他登录方式
 
 @param model 授权页
 @param completion 获得取号token
 */
- (void)getAccessToken:(UIViewController *)controller WithModel:(OclModel *)model complete:(LoginBlock)completion;


/**
 关闭授权界面
 */
- (void)closeAuthViewController;

@end

NS_ASSUME_NONNULL_END
