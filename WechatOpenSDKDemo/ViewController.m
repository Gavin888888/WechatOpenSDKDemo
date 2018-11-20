//
//  ViewController.m
//  WechatOpenSDKDemo
//
//  Created by 李秋 on 2018/5/23.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <WechatOpenSDK/WXApi.h>
#import <YSJNetWorking/YSJNetworkingHeader.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [btn setTitle:@"确认支付" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(weixinPay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)weixinPay1{
    PayReq *req = [[PayReq alloc] init];
    //实际项目中这些参数都是通过网络请求后台得到的，详情见以下注释，测试的时候可以让后台将价格改为1分钱
//    wx1369f1ceefea6b5c
    req.openID = @"wx1369f1ceefea6b5c";//微信开放平台审核通过的AppID
    req.partnerId = @"1517519921";//微信支付分配的商户ID
    req.prepayId = @"wx201631398409308c082dc0c10112965935";// 预支付交易会话ID
    req.nonceStr =@"VmzQFAPZZhxp4R6J";//随机字符串
//    req.timeStamp = @"1542702434";//当前时间
    req.package = @"Sign=WXPay";//固定值
    req.sign =@"83E7B19653EDEC4089D6FDE939D1B98E";//签名，除了sign，剩下6个组合的再次签名字符串
    
    if ([WXApi isWXAppInstalled] == YES) {
        //此处会调用微信支付界面
        BOOL sss =   [WXApi sendReq:req];
        if (!sss ) {
           // [MBManager showMessage:@"微信sdk错误" inView:weakself.view afterDelayTime:2];
        }
    }else {
        //微信未安装
       // [MBManager showMessage:@"您没有安装微信" inView:weakself.view afterDelayTime:2];
    }
}


#pragma mark --微信支付--
- (void)weixinPay{
    NSString *url = @"http://service5.99melove.cn/taole-pay-service/service/rest/taole-pay.WechatPayApi/collection/wxUnifiedOrder";
    NSDictionary *headers = @{};
    NSDictionary *params = @{
                             @"accountId": @"123",
                             @"channelCode": @"miai_wechat_app_001",
                             @"description": @"ios支付测试",
                             @"detail": @"string",
                             @"openid":@"wx1369f1ceefea6b5c",
                             @"orderId": [NSString stringWithFormat:@"%d",arc4random()],
                             @"productId": @"1122112211221122",
                             @"totalFee": @"0.01",
                             @"tradeType": @"APP"
                             };
    [[YSJNetworking ShareYSJNetworking] post_header:headers url:url body:params success:^(id  _Nonnull ysjResponseObject) {
        
        NSDictionary *result = [ysjResponseObject objectForKey:@"result"];
       
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            

            PayReq *req = [[PayReq alloc] init];
            //实际项目中这些参数都是通过网络请求后台得到的，详情见以下注释，测试的时候可以让后台将价格改为1分钱
            //    wx1369f1ceefea6b5c
            req.openID = @"wx1369f1ceefea6b5c";//微信开放平台审核通过的AppID
            req.partnerId = @"1517519921";//微信支付分配的商户ID
            req.prepayId = result[@"prepayId"];// 预支付交易会话ID
            req.nonceStr = result[@"noncestr"];//随机字符串
            req.timeStamp = [result[@"time_stamp"] intValue];//当前时间
            req.package = @"Sign=WXPay";//固定值
            req.sign = result[@"sign"];//签名，除了sign，剩下6个组合的再次签名字符串
            
            if ([WXApi isWXAppInstalled] == YES) {
                //此处会调用微信支付界面
                BOOL sss =   [WXApi sendReq:req];
                if (!sss ) {
                    // [MBManager showMessage:@"微信sdk错误" inView:weakself.view afterDelayTime:2];
                }
            }else {
                //微信未安装
                // [MBManager showMessage:@"您没有安装微信" inView:weakself.view afterDelayTime:2];
            }
        }];

    } failure:^(NSError * _Nullable ysjError) {
        
    }];
}
@end
