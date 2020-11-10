//
//  HYUniLoginSDK.h
//  UniLoginSDK
//
//  Created by doulai on 2019/5/15.
//  Copyright © 2019年 cmcc. All rights reserved.
//

/*
 版本号：1.0.7
 升级：适配依赖包，移动SDK(quick_login_iOS_5.7.1)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TYRZSDK/TYRZSDK.h>
//@class UACustomModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^HYUniLoginBlock)(NSDictionary *_Nullable resultDic);

@interface HYUniLoginSDK : NSObject

/**
 单例

 @return 实例
 */
+(instancetype)shareInstance;

@property (nonatomic, strong) UACustomModel *cmccModel;

/**
 自定义的主机地址，必须在init之前设置
 */
@property (strong,nonatomic) NSString* server_url;
/**
 运营商类型

 @return 运营商类型 1移动，2联通，3电信
 */
-(NSNumber*)getOperatorType;
/**
 设置超时
 
 @param timeout 超时
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeout;
/**
 控制台日志输出控制（默认关闭）
 @param enable 开关参数
 */
- (void)printConsoleEnable:(BOOL)enable;

/**
 接口用于初始化sdk

 @param apikey apikey description
 @param secret secret description
 */
-(void)initWithApiKey:(NSString*)apikey Appsecrect:(NSString*)secret;

/**
 接口用于预取号，获取accessCode，如果失败，则应选择其它取号登录方式

 @param complete 获得accessCode
 */
- (void)uniGetAccessCodeFinishBlock:(HYUniLoginBlock)complete;
/**
 接口用于获取当前手机的accessToken

 @param accesscode 预取号拿到的访问码
 @param complete 获得accessToken
 */
- (void)uniGetAccessTokenWithAccessCode:(NSString*)accesscode finishBlock:(HYUniLoginBlock)complete;


/**
 接口用于预判断本机号，获取checkToken，如果失败，则应选择其它判断方式

 @param complete 获得checkToken
 */
- (void)uniGetCheckCodeFinishBlock:(HYUniLoginBlock)complete;


@end

NS_ASSUME_NONNULL_END
