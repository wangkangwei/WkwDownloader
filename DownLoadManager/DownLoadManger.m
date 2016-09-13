//
//  DownLoadManger.m
//  DownLoadManager
//
//  Created by iCount on 16/9/4.
//  Copyright © 2016年 iCount. All rights reserved.
//

// 下载的文件名
#define downLoadFileName _downLoadUrl.md5String
// 下载的本地全路径
#define downLoadFileFullPath [_downLoadFilePath stringByAppendingPathComponent:downLoadFileName]
// 已经下载的文件长度
#define downLoadLength [[[NSFileManager defaultManager] attributesOfItemAtPath:downLoadFileFullPath error:nil][NSFileSize] integerValue]
// 存储下载文件的大小的文件
#define saveFile [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"save.data"]

#import "DownLoadManger.h"
#import "NSString+Hash.h"

@interface DownLoadManger ()<NSURLSessionDataDelegate,NSCopying>

/** 下载网址 */
@property (nonatomic, strong) NSString *downLoadUrl;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, assign) NSInteger totalLength;

@property (nonatomic, copy) progressBlock progressBlock;

@end

static DownLoadManger *_manager;

@implementation DownLoadManger

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _manager;
}

- (void)downloadWithURL:(NSString *)url progress:(progressBlock)progress complete:(CompleteBlock)complete
{
    self.downLoadUrl = url;
    self.progressBlock = progress;
    complete(nil,self.totalLength/1000/1000);
}

- (void)start
{
    [self.task resume];
}
- (void)stop
{
    [self.task suspend];
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:downLoadFileFullPath append:YES];
    }
    return _stream;
}

- (NSURLSessionDataTask *)task
{
    
    if (!_task) {
        if (downLoadLength && self.totalLength == downLoadLength) {
            NSLog(@"文件已经下载过了");
            return nil;
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_downLoadUrl]];
        // 设置请求头
        // Range : bytes=***-***
        NSString *ran = [NSString stringWithFormat:@"bytes=%zd-", downLoadLength];
        [request setValue:ran forHTTPHeaderField:@"Range"];
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", downLoadLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}

#pragma mark -<NSURLSessionDataDelegate>
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.stream open];
    // 取得下载文件的总大小
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + downLoadLength;
    // 把文件总大小写入本地文件
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:saveFile];
    if (!dict) dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.totalLength) forKey:downLoadFileName];
    [dict writeToFile:saveFile atomically:YES];
    
    // 接收这个请求，允许接收服务器数据
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.stream write:data.bytes maxLength:data.length];
    if (self.progressBlock) {
        self.progressBlock(1.0 * downLoadLength / self.totalLength);
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.stream close];
    self.stream = nil;
    self.task = nil;
}

@end









