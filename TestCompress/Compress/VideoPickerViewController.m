//
//  VideoPickerViewController.m
//  TestCompress
//
//  Created by Shane on 16/9/21.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "VideoPickerViewController.h"
#import "VideoDetailViewController.h"

@interface VideoPickerViewController ()
{
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *assetsGroup;
    NSMutableArray *assetsArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation VideoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    assetsLibrary = [[ALAssetsLibrary alloc] init];
     assetsGroup = [[NSMutableArray alloc] initWithCapacity:1];
    assetsArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self fetchALbum];
    
    self.title = @"视频列表";
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return assetsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    ALAsset *asset =  assetsArray[assetsArray.count - indexPath.row -1];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    UIImage *iamge =[UIImage imageWithCGImage:[asset thumbnail]];
    cell.imageView.image = iamge;
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"名称:%@ \n视频时长：%d秒，大小:%.2fMB",[representation filename],[[asset valueForProperty:ALAssetPropertyDuration] intValue],([representation size]/1024.0)/1024.0];

    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset =  assetsArray[assetsArray.count - indexPath.row -1];
    
    if (self.selectBlock) {
        self.selectBlock(asset);
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    VideoDetailViewController *vc = [VideoDetailViewController new];
    vc.videourl = [[representation url] absoluteString];
    vc.asset = asset;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fetchALbum
{
    __weak typeof(self) weakSelf = self;
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//         [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (!result) {
                        [weakSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }else{
                        [assetsArray addObject:result];
                    }
                }];
            NSLog(@"%@",group);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Group not found!\n");
    }];
}

#pragma mark- 
- (CGFloat)getfileSize:(NSURL *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path.absoluteString error:nil];
    NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
    return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
}

@end
