//
//  NSObject+GetDeviceInfo.m
//  Pods
//
//  Created by lishuaibing on 16/8/2.
//
//

#import "NSObject+GetDeviceInfo.h"

@implementation NSObject (GetDeviceInfo)
-(nonnull NSDictionary*)getDeviceInfo
{
    UIDevice *device = [[UIDevice alloc] init];
    NSString *name = device.name;       //获取设备所有者的名称
    NSString *model = device.name;      //获取设备的类别
    NSString *type = device.localizedModel; //获取本地化版本
    NSString *systemName = device.systemName;   //获取当前运行的系统
    NSString *systemVersion = device.systemVersion;//获取当前系统的版本
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//这个值还是会改变，如果重新安装
    return @{@"deviceUUID":identifier,@"deviceModel":model,@"deviceType":@"1",@"sysVersion":systemVersion};
}
@end
