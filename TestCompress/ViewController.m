//
//  ViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoDetailViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew2;


@property (strong, nonatomic) NSArray *videoArr;
@property (strong, nonatomic) NSArray *videoArr2;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.videoArr = [fileManager contentsOfDirectoryAtPath:[self origVideoPath] error:nil];
        self.videoArr2 = [fileManager contentsOfDirectoryAtPath:[self savaUserPath] error:nil];
    
    [self.tableView reloadData];
    [self.tableVIew2 reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self origVideoPath];
    [self savaUserPath];
    
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.videoArr.count;
    }
    else{
         return self.videoArr2.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *path = [[self origVideoPath] stringByAppendingPathComponent:self.videoArr[indexPath.row]];
    cell.textLabel.text =[[NSString alloc] initWithFormat:@"name:%@,  size:%.2fMB", self.videoArr[indexPath.row], [self getfileSize:path]];
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    
    return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
        }
        
        NSString *path = [[self savaUserPath] stringByAppendingPathComponent:self.videoArr2[indexPath.row]];
        cell.textLabel.text =[[NSString alloc] initWithFormat:@"name:%@,  size:%.2fMB", self.videoArr2[indexPath.row], [self getfileSize:path]];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        VideoDetailViewController *vc = [VideoDetailViewController new];
        vc.videourl = [[self origVideoPath] stringByAppendingPathComponent:self.videoArr[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else{
        VideoDetailViewController *vc = [VideoDetailViewController new];
        vc.videourl = [[self origVideoPath] stringByAppendingPathComponent:self.videoArr2[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (IBAction)selecteVideoButtonClicked:(id)sender {
    /*注：使用，需要实现以下协议：UIImagePickerControllerDelegate,
     UINavigationControllerDelegate
     */
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //设置图片源(相簿)
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
     picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    //设置代理
    picker.delegate = self;
    //设置可以编辑
    picker.allowsEditing = YES;
    //打开拾取器界面
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
//        [self videoCompressionWithUrl:videoUrl];
        
        
        NSLog(@"压缩前大小 %f MB",[self getfileSize: videoUrl.path]);
        
        NSString *destFilePath = [[self origVideoPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",[[[NSUUID UUID]UUIDString]substringToIndex:8]]];
        NSURL *destUrl = [NSURL fileURLWithPath:destFilePath];
        
        //将视频文件copy到沙盒目录中
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        [manager copyItemAtURL:videoUrl toURL:destUrl error:&error];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)getfileSize:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
    return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}

-(void)videoCompressionWithUrl:(NSURL *)url{
    

    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:url];
    //创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视频的URL
    NSString *resultPath = [[self savaUserPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",[[[NSUUID UUID]UUIDString]substringToIndex:8]]];
    session.outputURL = [NSURL fileURLWithPath:resultPath];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"压缩后的视频地址为 %@",resultPath);
          NSLog(@"压缩完毕,压缩后大小 %f MB",[self getfileSize:resultPath]);
        //删除沙盒中的高质量视频文件
        
        [self saveVideo:resultPath];
        
//        [self dismissViewControllerAnimated:YES completion:nil];
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
                                    } else {
                                        NSLog(@"Save video succeed.");
                                    }
                                }];
}

@end