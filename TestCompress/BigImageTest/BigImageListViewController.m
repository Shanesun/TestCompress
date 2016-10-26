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
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *promatLabel;

@property (strong, nonatomic) NSArray *bigImageArray;
@property (strong, nonatomic) NSNumber *compressValue;

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
    
    self.compressValue = @(2);
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
    vc.compressType = self.segmentControl.selectedSegmentIndex;
    vc.compressValue = self.compressValue;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark- IBAction

- (IBAction)segmentedChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
         self.sliderView.hidden = NO;
        self.sliderView.value = 0.2;
       int mb = (int)(self.sliderView.value*10);
        self.compressValue = @(mb);
        self.promatLabel.text = [[NSString alloc] initWithFormat:@"%dMB",mb];
    }
    else if(sender.selectedSegmentIndex == 1){
        self.sliderView.hidden = NO;
        self.sliderView.value = 0.9;
         self.promatLabel.text = [[NSString alloc] initWithFormat:@"%.1f",self.sliderView.value];
        self.compressValue = @(self.promatLabel.text.floatValue);
    }
    else if(sender.selectedSegmentIndex == 2){
        self.sliderView.hidden = YES;
        self.compressValue = @(0);
    }
}

- (IBAction)valueChanged:(UISlider *)sender
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        self.promatLabel.text = [[NSString alloc] initWithFormat:@"%dMB",(int)(sender.value*10)];
    }
    else{
        self.promatLabel.text = [[NSString alloc] initWithFormat:@"%.1f",sender.value];
    }
}

@end
