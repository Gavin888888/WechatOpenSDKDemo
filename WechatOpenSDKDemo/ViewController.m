//
//  ViewController.m
//  WechatOpenSDKDemo
//
//  Created by 李秋 on 2018/5/23.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <WechatOpenSDK/WXApi.h>
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

- (void)weixinPay{
    PayReq *req = [[PayReq alloc] init];
    //实际项目中这些参数都是通过网络请求后台得到的，详情见以下注释，测试的时候可以让后台将价格改为1分钱
    req.openID = @"appid";//微信开放平台审核通过的AppID
    req.partnerId = @"partnerid";//微信支付分配的商户ID
    req.prepayId = @"prepayid";// 预支付交易会话ID
    req.nonceStr =@"noncestr";//随机字符串
   // req.timeStamp = @"timestamp";//当前时间
    req.package = @"package";//固定值
    req.sign =@"sign";//签名，除了sign，剩下6个组合的再次签名字符串
    
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

/**
#pragma mark --微信支付--
- (void)weixinPay{
    __weak typeof (self) weakself = self;
    if (![AFNetWorkingManager isNetworking]) {
        [MBManager showMessage:@"网络不可用" inView:self.view afterDelayTime:2];
        return;
    }
    //--->实际项目代码
    NSString *url =[NSString stringWithFormat:@"%@%@", pBaseURL,WxPrepayURL];
    NSLog(@"微信支付___URL=== %@,%@", url,self.orderId);
    
    [AFNetWorkingManager postDataWithUrl:url parameters:@{@"orderID":self.orderId} success:^(id responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        switch (code) {
            case 0:{
                PayReq *req = [[PayReq alloc] init];
                id dic = [responseObject objectForKey:@"data"];
                if ([dic isKindOfClass:[NSString class]]) {
                    NSString *str = [NSString stringWithFormat:@"%@",dic];
                    if ([str isEqualToString:@"PAY_SUCCESS"]) {
                        [weakself goToOrderDetailVC];
                        return ;
                    }
                    return ;
                }
                req.openID = [dic objectForKey:@"appid"];//AppID
                req.partnerId = [dic objectForKey:@"partnerid"];
                req.prepayId = [dic objectForKey:@"prepayid"];
                req.nonceStr = [dic objectForKey:@"noncestr"];
                req.timeStamp = [[dic objectForKey:@"timestamp"] intValue];
                req.package = [dic objectForKey:@"package_"];
                req.sign = [dic objectForKey:@"sign"];
                if ([WXApi isWXAppInstalled] == YES) {
                    BOOL sss =   [WXApi sendReq:req];
                    if (!sss ) {
                        [MBManager showMessage:@"微信sdk错误" inView:weakself.view afterDelayTime:2];
                    }
                } else {
                    //微信未安装
                    [MBManager showMessage:@"您没有安装微信" inView:weakself.view afterDelayTime:2];
                }
            }
                break;
            case 403:
                [weakself exitLogin];
                break;
            case 400:
                [MBManager showMessage:[responseObject objectForKey:@"desc"]inView:weakself.view afterDelayTime:2];
                break;
            default:
                [MBManager showMessage:@"服务器未知错误"inView:weakself.view afterDelayTime:2];
                break;
        }
        
    } failure:^(NSError *error) {
        [MBManager showMessage:@"服务器出错啦" inView:weakself.view afterDelayTime:2];
    }];
}
*/
@end
