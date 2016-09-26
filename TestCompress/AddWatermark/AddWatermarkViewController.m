//
//  AddWatermarkViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/26.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "AddWatermarkViewController.h"
#import "VideoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AddWatermarkViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic)AVPlayerLayer *playerLayer;

@property (assign, nonatomic) BOOL isPlay;

@end

@implementation AddWatermarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.player = [[AVPlayer alloc] init];
}

- (IBAction)selecteVideoClicked:(id)sender {
    VideoPickerViewController *videoVc = [VideoPickerViewController new];
    videoVc.selectBlock = ^(ALAsset *asset){
        [self displayVideoWithAsset:asset];
    };
    [self.navigationController pushViewController:videoVc animated:YES];
}

- (IBAction)addWatermarkClicked:(id)sender {
    
    
}

- (IBAction)exportVideoAndSave:(id)sender {
}

#pragma mark- private meathods
- (void)displayVideoWithAsset:(ALAsset *)asset
{
    AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[self player]];
    [newPlayerLayer setFrame:[[[self playerView] layer] bounds]];
    [newPlayerLayer setHidden:NO];
    [[[self playerView] layer] addSublayer:newPlayerLayer];
    [self setPlayerLayer:newPlayerLayer];
    
    AVAsset *newasset = [[AVURLAsset alloc] initWithURL:[[asset defaultRepresentation] url] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:newasset];
    [[self player] replaceCurrentItemWithPlayerItem:playerItem];
}
- (IBAction)playPauseClicked:(UIBarButtonItem *)sender {
    self.isPlay = !self.isPlay;

    if (self.isPlay) {
        sender.style = UIBarButtonSystemItemPause;
        [[self player] seekToTime:CMTimeMakeWithSeconds(0, 1)];
        [self.player play];
    }
    else{
        sender.style = UIBarButtonSystemItemPlay;
        [self.player pause];
    }
}

@end
