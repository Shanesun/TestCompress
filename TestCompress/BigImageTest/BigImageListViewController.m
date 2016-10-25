//
//  BigImageListViewController.m
//  TestCompress
//
//  Created by Shane on 2016/10/19.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "BigImageListViewController.h"
#import "SSImageViewerViewController.h"

@interface BigImageListViewController ()

@property (strong, nonatomic) NSArray *bigImageArray;

@end

@implementation BigImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bigImageArray = @[@"view1.9mb.jpg",
                           @"dog2.4mb.jpg",
                           @"view5mb.jpg",
                           @"7.3mb.jpg",
                           @"9.5mb.jpg",
                           @"12.5mb.jpg",
                           @"14.9mb.jpg"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.bigImageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.bigImageArray[indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"load start --- ");
    NSString *path = [[NSBundle mainBundle] pathForResource:self.bigImageArray[indexPath.row] ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
     NSLog(@"load end --- ");
    
    SSImageViewerViewController *vc = [[SSImageViewerViewController alloc] initWithImage:image];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
