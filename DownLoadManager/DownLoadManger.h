//
//  DownLoadManger.h
//  DownLoadManager
//
//  Created by iCount on 16/9/4.
//  Copyright © 2016年 iCount. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^progressBlock)(float progress);
typedef void (^CompleteBlock)(NSError *error, NSInteger fileLength);

@interface DownLoadManger : NSObject

/** 下载到本地的路径 */
@property (nonatomic, strong) NSString *downLoadFilePath;

+ (instancetype)sharedManager;
/** 开始下载 */
- (void)start;
/** 停止下载 */
- (void)stop;
/** 下载方法 */
- (void)downloadWithURL:(NSString *)url progress:(progressBlock)progress complete:(CompleteBlock)complete;


@end
