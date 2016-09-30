//
//  ViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoDetailViewController.h"
#import "VideoPickerViewController.h"

#import "EditVideoViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
   
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew2;


@property (strong, nonatomic) NSArray *videoArr;
@property (strong, nonatomic) NSArray *videoArr2;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{

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


- (IBAction)selecteVideoButtonClicked:(id)sender
{
    VideoPickerViewController *videoPickerVC = [VideoPickerViewController new];
    [self.navigationController pushViewController:videoPickerVC animated:YES];
    
//    [self showImagePickerVC];
}
- (IBAction)addWatermarkClicked:(id)sender {
    EditVideoViewController *addWaterVC = [EditVideoViewController new];
    [self.navigationController pushViewController:addWaterVC animated:YES];
}



#pragma mark- private methods
- (void)showImagePickerVC
{
    /*注：使用，需要实现以下协议：UIImagePickerControllerDelegate,
     UINavigationControllerDelegate
     */
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //设置图片源(相簿)
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    // 只显示视频 mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //设置代理
    picker.delegate = self;
    //设置可以编辑
    picker.allowsEditing = YES;
    //打开拾取器界面
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mrak- imagepicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{      
    
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}

#pragma mark- helper
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
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
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
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return path;
}

@end
