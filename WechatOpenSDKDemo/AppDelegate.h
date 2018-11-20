//
//  AppDelegate.h
//  WechatOpenSDKDemo
//
//  Created by 李秋 on 2018/5/23.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WechatOpenSDK/WXApi.h>//微信支付

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

