//
//  YSJNetworking.m
//  Pods
//
//  Created by lishuaibing on 16/7/22.
//
//

#import "YSJNetworking.h"
#import "URLDefined.h"
#import "AFNetworking.h"
#import "NSObject+GetDeviceInfo.h"
#define  DEFAULT_TIMEOUT 60
@interface YSJNetworking ()
@property(nonatomic,strong) AFHTTPSessionManager *httpSessionManager;
@property(nonatomic,strong) AFURLSessionManager *urlSessionManager;
@property(nonatomic,strong) NSURLSessionDataTask *task;
@property(nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property(nonatomic,strong) NSURLSessionDataTask *uploadTask;
@property(nonatomic,strong,nullable) NSString *token;//请求token
@property(nonatomic,strong,nonnull) NSDictionary *getTokenParamers;//缓存一份获取token的参数
@end
@implementation YSJNetworking
+(YSJNetworking * _Nullable )ShareYSJNetworking
{
    static dispatch_once_t onceToken;
    static YSJNetworking *ysjNetworking;
    dispatch_once(&onceToken, ^{
        ysjNetworking = [[YSJNetworking alloc] init];

    });
    return ysjNetworking;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reachabilityStatusChangeBlock:^(int status) {
            self.reachabilityStatus = status;
        }];
    }
    return self;
}
//更新请求头
-(void)updateHttpRequestHeaders
{
    if (_HTTPRequestHeaders != nil) {
        NSArray *keys = [_HTTPRequestHeaders allKeys];

        for (NSString *key in keys) {
            [self.httpSessionManager.requestSerializer setValue:_HTTPRequestHeaders[key] forHTTPHeaderField:key];
        }
    }
}
-(void)setHTTPRequestHeaders:(NSMutableDictionary *)HTTPRequestHeaders
{
    NSMutableDictionary *newDictioary = [_HTTPRequestHeaders mutableCopy];
    if (newDictioary == nil) {
        newDictioary = [[NSMutableDictionary alloc] init];
    }
    [newDictioary addEntriesFromDictionary:HTTPRequestHeaders];
    _HTTPRequestHeaders = newDictioary;
}
-(void)setTimeoutInterval:(double)TimeoutInterval
{
    _httpSessionManager.requestSerializer.timeoutInterval = TimeoutInterval ;
}
-(AFHTTPSessionManager *)httpSessionManager
{
    if (!_httpSessionManager) {
        _httpSessionManager = [AFHTTPSessionManager manager];
    }
    //设置响应类型
    _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _httpSessionManager;
}
-(AFURLSessionManager *)urlSessionManager
{
    if (!_urlSessionManager) {
        _urlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _urlSessionManager;
}
#pragma mark - 网络状态
-(void)reachabilityStatusChangeBlock:(ReachabilityStatusChangeBlock)reachabilityStatusChangeBlock
{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    //要监控网络状态，必须要调用单利的方法
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        reachabilityStatusChangeBlock(status);
    }];
}
#pragma mark - 得到token
-(void)getTokenWithURL:(NSString *)aURL  Paramers:(nonnull NSDictionary *)paramers
               success:(Success _Nonnull)aSuccess
               failure:(Failure _Nonnull)aFailure
{
    if (paramers) {
        self.getTokenParamers = paramers;
    }
    self.task = [self.httpSessionManager POST:aURL parameters:[self setGetTokenParamerWithInputParamer:_getTokenParamers] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSArray *keys = jsonDictionary.allKeys;
        if ([keys containsObject:@"result"]) {
            NSDictionary *result = jsonDictionary[@"result"];
            NSArray *result_keys = result.allKeys;
            if ([result_keys containsObject:@"token"]) {
                self.token = result[@"token"];
                aSuccess(_token);
            }
            else
            {
                NSError *error = [[NSError alloc] init];
                aFailure(error);
            }
        }
        else
        {
            NSError *error = [[NSError alloc] init];
            aFailure(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        aFailure(error);
    }];
    
}
/**
 *  整理获取token的参数 ，可选参数如果传入，覆盖默认值
 *
 *  @param paramers 传入参数
 *
 *  @return 传出参数
 */
-(NSMutableDictionary *)setGetTokenParamerWithInputParamer:(NSDictionary *)paramers
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[self getDeviceInfo]];
    [dictionary addEntriesFromDictionary:paramers];
    return dictionary;
}
//请求log
-(void)requestLogWith:(NSURLSessionDataTask * )task andParam:(id)params
{
#ifdef DEBUG
    NSString *url = task.currentRequest.URL.absoluteString;
    NSString *headers = task.currentRequest.allHTTPHeaderFields;
    NSLog(@"request url：%@  request all headfield：%@ request params：%@",url,headers,params);
#endif
}
//响应log
-(void)responeLogWithNSURLResponse:(NSURLResponse *)aResponse data:(NSDictionary *)aData
{
#ifdef DEBUG
    NSLog(@"response：%@ response data：%@",aResponse,aData);
#endif
}
//错误日志
-(void)errorLogWithError:(NSError *)aError
{
#ifdef DEBUG
//    NSLog(@"erro code:%@ error description:%@",aError.code,aError.description);
#endif
}
#pragma mark - GET
-(nullable id)GET:(NSString * )URLString
       parameters:(nullable id)parameters
          success:(Success )aSuccess
          failure:(Failure)aFailure
{
    //更新请求头
    [self updateHttpRequestHeaders];
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    if (_shareBody) {
        [allParams addEntriesFromDictionary:_shareBody];
    }
    //打印请求参数
    [self requestLogWith:_task andParam:allParams];
    return [self GET_DEFAULT:URLString parameters:allParams success:^(id  _Nonnull ysjResponseObject) {
        aSuccess(ysjResponseObject);
    } failure:^(NSError * _Nullable ysjError) {
        aFailure(ysjError);
    }];
    

    self.task =  [self.httpSessionManager GET:URLString parameters:allParams progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        aSuccess(jsonDictionary);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        aFailure(error);
    }];
    [self requestLogWith:_task andParam:allParams];
    return _task;
}
//开始请求
-(nullable id)GET_DEFAULT:(NSString * )URLString
               parameters:(nullable id)parameters
                  success:(Success )aSuccess
                  failure:(Failure)aFailure
{
    
    __weak typeof(self) weakself = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableString *newURLString = nil;
    if ([URLString containsString:@"?"]) {
        newURLString = [[NSMutableString alloc] initWithString:URLString];
        NSDictionary *params = (NSDictionary *)parameters;
        NSArray *keys = params.allKeys;
        for (NSString *key in keys) {
            [newURLString appendString:[NSString stringWithFormat:@"&%@=%@",key,params[key]]];
        }
    }else
    {
        newURLString = URLString;
    }
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self setGetRequestRequestWithURL:newURLString Header:self.HTTPRequestHeaders paramers:parameters    ]
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (data == nil) {
                                              //打印日志
                                              [weakself responeLogWithNSURLResponse:response data:nil];
                                              if (error) {
                                                  [weakself errorLogWithError:error];
                                                  aFailure(error);
                                              }else
                                              {
                                                  
                                                  aSuccess(nil);
                                              }
                                          }else
                                          {
                                              NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              //打印日志
                                              [weakself responeLogWithNSURLResponse:response data:jsonDictionary];
                                              if (error) {
                                                  [weakself errorLogWithError:error];
                                                  aFailure(error);
                                              }else
                                              {
                                                  
                                                  aSuccess(jsonDictionary);
                                              }
                                          }
                                          
                                      }];
    // 使用resume方法启动任务
    [dataTask resume];
    return dataTask;
}
-(NSMutableURLRequest *)setGetRequestRequestWithURL:(NSString *)url Header:(NSDictionary *)header paramers:(NSDictionary *)paramer
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:url];
    NSArray *paramArray = paramer.allKeys;
    for (NSString *tempString in paramer) {
        int index = (int)[paramArray indexOfObject:tempString];
        if (index == 0) {
            [urlString appendFormat:@"?%@=%@",tempString,paramer[tempString]];
        }else
        {
            [urlString appendFormat:@"&%@=%@",tempString,paramer[tempString]];
        }
    }
    NSString *encode = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //初始化请求
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:encode] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:DEFAULT_TIMEOUT];
    
    //设置请求方式
    [urlRequest setHTTPMethod:@"GET"];
    //设置请求头
    if (header != nil) {
        NSArray *keys = [header allKeys];
        for (NSString *key in keys) {
            [urlRequest setValue:header[key] forHTTPHeaderField:key];
        }
    }
    return urlRequest;
}

#pragma mark - POST
-(nullable id)POST:(NSString * _Nonnull)URLString
        parameters:(nullable id)parameters
           success:(Success _Nonnull)aSuccess
           failure:(Failure _Nonnull)aFailure
{
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    if (_shareBody) {
        [allParams addEntriesFromDictionary:_shareBody];
    }
    //请求的序列化
    self.httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self updateHttpRequestHeaders];
    //回复的序列化
    self.httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    __weak typeof(self) weakself = self;
    self.task = [self.httpSessionManager POST:URLString parameters:allParams progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            aSuccess(nil);
            //打印日志
            [weakself responeLogWithNSURLResponse:task.response data:nil];
        }else
        {
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            aSuccess(jsonDictionary);
            //打印日志
            [weakself responeLogWithNSURLResponse:task.response data:jsonDictionary];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakself errorLogWithError:error];
        aFailure(error);
    }];
    [self requestLogWith:_task andParam:allParams];
    return  _task;
}
-(id)post_header:(NSDictionary *)aHeader url:(NSString *)aURL body:(NSDictionary *)aBody           success:(Success _Nonnull)aSuccess
         failure:(Failure _Nonnull)aFailure
{
    //更新请求头
    [self updateHttpRequestHeaders];
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:aBody];
    if (_shareBody) {
        [allParams addEntriesFromDictionary:_shareBody];
    }
    if (aHeader == nil) {
        aHeader = _HTTPRequestHeaders;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self setPostRequestWithURL:aURL Header:aHeader paramers:allParams]
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSDictionary *responseObject = [self dataToObject:data];
                                          aSuccess(responseObject);
                                      }];
    // 使用resume方法启动任务
    [dataTask resume];
    return dataTask;
}
-(NSMutableURLRequest *)setPostRequestWithURL:(NSString *)url Header:(NSDictionary *)header paramers:(NSDictionary *)paramer
{
    //初始化请求
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:DEFAULT_TIMEOUT];
    if (paramer) {
        //设置body
        [urlRequest setHTTPBody:[[self DataTOjsonString:paramer] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //设置请求方式
    [urlRequest setHTTPMethod:@"POST"];
    //设置请求类型
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //设置请求头
    if (header != nil) {
        NSArray *keys = [header allKeys];
        for (NSString *key in keys) {
            [urlRequest setValue:header[key] forHTTPHeaderField:key];
        }
    }
    return urlRequest;
}
//NSDictionary to json
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
//data to NSDictionary
-(nullable NSDictionary *)dataToObject:(id)data
{
    NSDictionary *dictionary = nil;
    if (data) {
        dictionary  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return dictionary;
}
#pragma mark - 下载
-(nullable id)downloadTaskWithURLString:(nonnull NSString *)URLString
                               progress:(nullable DownloadProgress)downloadProgressBlock
                            destination:(nullable NSString *)destination
                      completionHandler:(nullable CompletionHandler)completionHandlerBlock
{
    //设置请求
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    self.downloadTask = [self.urlSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        float download = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        downloadProgressBlock(download);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //这里要返回一个NSURL，其实就是文件的位置路径
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        if (destination) {
            path = destination;
        }else
        {
            //使用建议的路径
            path = [path stringByAppendingPathComponent:response.suggestedFilename];
        }
        
        return [NSURL fileURLWithPath:path];//转化为文件路径
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载成功
        if (error == nil) {
            NSData *fileData = [NSData dataWithContentsOfURL:filePath];
            completionHandlerBlock(filePath,error,fileData);
        }else{//下载失败的时候，只列举判断了两种错误状态码
            completionHandlerBlock(nil,error,nil);
        }
    }];
    //开始下载
    [_downloadTask resume];
    return _downloadTask;
}
#pragma mark - 上传
-(nullable id) uploadTastWithURLString:(nonnull NSString *)URLString
                           parameters:(nullable NSMutableDictionary *)patameters
                                 file:(nonnull NSData *)uploadFile
                                 mime:(nonnull NSString *)mime
                             progress:(nullable UploadloadProgress)uploadloadProgressBlock
                              success:(Success _Nonnull)aSuccess
                              failure:(Failure _Nonnull)aFailure
{
    //更新请求头
    [self updateHttpRequestHeaders];
    self.uploadTask = [self.httpSessionManager POST:URLString parameters:patameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (uploadFile) {
            [formData appendPartWithFileData:uploadFile name:@"file" fileName:@"ios" mimeType:mime];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        float download = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        uploadloadProgressBlock(download);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        aSuccess(jsonDictionary);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        aFailure(error);
    }];
    return  _uploadTask;
}
#pragma mark - 取消请求
-(void)cancleAllRequest
{
    [self.httpSessionManager.operationQueue cancelAllOperations];
    [self.urlSessionManager.operationQueue cancelAllOperations];
}

@end
