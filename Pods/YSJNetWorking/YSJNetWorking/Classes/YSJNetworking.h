//
//  YSJNetworking.h
//  Pods
//
//  Created by lishuaibing on 16/7/22.
//
// 网络库 李帅兵

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, YSJNetworkReachabilityStatus) {
    YSJNetworkReachabilityStatusUnknown          = -1,
    YSJNetworkReachabilityStatusNotReachable     = 0,
    YSJNetworkReachabilityStatusReachableViaWWAN = 1,
    YSJNetworkReachabilityStatusReachableViaWiFi = 2,
};

typedef void (^ReachabilityStatusChangeBlock)(int status);
typedef void (^Success)( id _Nonnull ysjResponseObject);
typedef void (^Failure)( NSError * _Nullable ysjError );
typedef  void(^DownloadProgress)(float downloadProgress);
typedef  void(^UploadloadProgress)(float uploadProgress);
typedef  void(^CompletionHandler)(NSURL * _Nullable filePath,NSError * _Nullable error,NSData * _Nullable fileData);
@interface YSJNetworking : NSObject
@property(nonatomic,assign) YSJNetworkReachabilityStatus reachabilityStatus;//网络状态
/**
 *  请求头参数
 
 必须配置
 1.ApplicationConfiguration 中的token 
 2.UserAccount 中的UserToken
 */
@property(nullable,nonatomic,strong) NSMutableDictionary *HTTPRequestHeaders;
//公共的参数 如业务线
@property(nullable,nonatomic,strong) NSMutableDictionary *shareBody;
/**
 *  请求超时时间
 */
@property(nonatomic,assign) double TimeoutInterval;
/**
 *  创建一生佳网络管理器
 *
 *  @return 网络管理器对象
 */
+(YSJNetworking * _Nullable )ShareYSJNetworking;
/**
 *  网络状态
 *
 *  @param reachabilityStatusChangeBlock 网络状态
 */
-(void)reachabilityStatusChangeBlock:(nullable ReachabilityStatusChangeBlock)reachabilityStatusChangeBlock;
/**
 *  获取token
 *  @param aURL     url
 *  @param paramers 参数
 *  @param aSuccess 成功
 *  @param aFailure 失败
 
 appId          :客户端在服务端注册的ID       _Nonnull
 secret         :客户端在服务端注册时生成的密匙 _Nonnull
 grantType      :token类型，默认为clien      nullable
 deviceUUID     :设备UUID                   nullable
 deviceModel    :设备型号                    nullable
 deviceType     :设备类型                   nullable
 sysVersion     :系统版本                   nullable
 imei           :国际物理地址                nullable
 imisi          :手机SIM标识                nullable
 mac            :设备的MAC地址              nullable
 */
-(void)getTokenWithURL:(NSString *)aURL  Paramers:(nonnull NSDictionary *)paramers
                    success:(Success _Nonnull)aSuccess
                    failure:(Failure _Nonnull)aFailure;
/**
 *  HTTP GET 请求
 *
 *  @param URLString  接口地址
 *  @param parameters 参数
 *  @param aSuccess   成功
 *  @param aFailure   失败
 *
 *  @return session对象
 */
-(nullable id)GET:(NSString * _Nonnull)URLString
       parameters:(nullable id)parameters
          success:(Success _Nonnull)aSuccess
          failure:(Failure _Nonnull)aFailure;

/**
 *  HTTP POST 请求 AFNetworking
 *
 *  @param URLString  接口地址
 *  @param parameters 参数
 *  @param aSuccess   成功
 *  @param aFailure   失败
 *
 *  @return session对象
 */
-(nullable id)POST:(NSString * _Nonnull)URLString
       parameters:(nullable id)parameters
          success:(Success _Nonnull)aSuccess
          failure:(Failure _Nonnull)aFailure;

/**
 系统自带的post请求

 @param aHeader  请求头
 @param aURL     请求url
 @param aBody    请求body
 @param aSuccess
 @param aFailure

 @return
 */
-(id)post_header:(NSDictionary *)aHeader url:(NSString *)aURL body:(NSDictionary *)aBody           success:(Success _Nonnull)aSuccess
         failure:(Failure _Nonnull)aFailure;
/**
 *  下载文件
 *
 *  @param URLString              文件地址
 *  @param downloadProgressBlock  进度
 *  @param destination            文件存储的本地地址
 *  @param completionHandlerBlock 完成后的操作
 *
 *  @return session
 */
-(nullable id)downloadTaskWithURLString:(nonnull NSString *)URLString
                               progress:(nullable DownloadProgress)downloadProgressBlock
                            destination:(nullable NSString *)destination
                      completionHandler:(nullable CompletionHandler)completionHandlerBlock;
/**
 *  表单上传数据
 *
 *  @param URLString               上传url
 *  @param patameters              参数
 *  @param uploadFile              待上传的文件
 *  @param mime                    mime上传文件的类型
 *  @param uploadloadProgressBlock 上传进度
 *  @param aSuccess                上传成功
 *  @param aFailure                上传失败
 *
 *  @return session
 */
-(nullable id)uploadTastWithURLString:(nonnull NSString *)URLString
                           parameters:(nullable NSMutableDictionary *)patameters
                                 file:(nonnull NSData *)uploadFile
                                 mime:(nonnull NSString *)mime
                             progress:(nullable UploadloadProgress)uploadloadProgressBlock
                              success:(Success _Nonnull)aSuccess
                              failure:(Failure _Nonnull)aFailure;

/**
 *  取消所有请求
 */
-(void)cancleAllRequest;

@end
