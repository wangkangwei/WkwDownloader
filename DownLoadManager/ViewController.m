//
//  ViewController.m
//  DownLoadManager
//
//  Created by iCount on 16/9/4.
//  Copyright © 2016年 iCount. All rights reserved.
//

#import "ViewController.h"
#import "DownLoadManger.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [DownLoadManger sharedManager].downLoadFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@", [DownLoadManger sharedManager].downLoadFilePath);
    
}
- (IBAction)start:(id)sender {
    
    [[DownLoadManger sharedManager] downloadWithURL:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4" progress:^(float progress) {
        NSLog(@"%f", progress);
    } complete:^(NSError *error, NSInteger fileLength) {
        NSLog(@"%ld", (long)fileLength);
    }];
    [[DownLoadManger sharedManager] start];
}
- (IBAction)stop:(id)sender {
    [[DownLoadManger sharedManager] stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
