//
//  VideoDetailViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "VideoDetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *compButtonClicked;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)compButtonClicked:(id)sender {
    
    self.maskView.hidden = NO;
    
    [self videoCompressionWithUrl:[NSURL fileURLWithPath:self.videourl]];
}
- (IBAction)playdsljf:(id)sender {
    
    AVPlayerViewController * filePlayerViewController = [AVPlayerViewController alloc];
    //Show the controls
    filePlayerViewController.showsPlaybackControls = true;
    AVPlayer * filePlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videourl]];
    filePlayerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filePlayerViewController.player = filePlayer;
    [self presentViewController:filePlayerViewController animated:YES completion:nil];
}

-(void)videoCompressionWithUrl:(NSURL *)url{
    
    
    
    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:url];
    //创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视频的URL
    NSString *resultPath = [[self savaUserPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[self.videourl lastPathComponent]]];
    session.outputURL = [NSURL fileURLWithPath:resultPath];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"压缩后的视频地址为 %@",resultPath);
        NSLog(@"压缩完毕,压缩后大小 %f MB",[self getfileSize:resultPath]);
        //删除沙盒中的高质量视频文件
        
        [self saveVideo:resultPath];

    }];
    
    
}
- (void)saveVideo:(NSString *)videoPath
{
    //    videoPath是你视频文件的路径，我这里是加载工程中的
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                                        [alert show];
                                    } else {
                                        NSLog(@"Save video succeed.");
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.navigationController popViewControllerAnimated:YES];
                                        });
                                        
                                    }
                                }];
}
- (NSString *)savaUserPath{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"compVideo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:nil attributes:nil error:nil];
    }
    
    return path;
}

- (NSString *)origVideoPath{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"origVideo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:nil attributes:nil error:nil];
    }
    
    return path;
}

- (CGFloat)getfileSize:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
    return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
}
@end
