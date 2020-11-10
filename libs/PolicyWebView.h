//
//  PolicyWebView.h
//  sdk
//
//  Created by 段晓杰 on 2020/7/30.
//  Copyright © 2020 段晓杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PolicyWebView : UIViewController

@property (strong, nonatomic) NSURL *url;
@property (nonatomic, strong) NSAttributedString * webtitle;
@property (nonatomic,strong) UIImage *webNavReturnImg;
@property (nonatomic, strong)UIColor *webNavColor;

@end

NS_ASSUME_NONNULL_END
