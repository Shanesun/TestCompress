//
//  EnCryptoImageViewController.m
//  TestCompress
//
//  Created by Shane on 2016/10/19.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "EnCryptoImageViewController.h"
#import "NSData+Encryption.h"

#define AES @"wwwqoqoq"

@interface EnCryptoImageViewController ()

@property (strong, nonatomic) NSString *exmapleImageName;
@property (strong, nonatomic) NSData *cryptoImageData;

@property (nonatomic) NSTimeInterval cryptoTime;
@property (nonatomic) NSTimeInterval encryptoTime;

@property (weak, nonatomic) IBOutlet UITextView *cryptoImageDataTxf;
@property (weak, nonatomic) IBOutlet UIImageView *encryproImageView;
@property (weak, nonatomic) IBOutlet UITextView *encryproTxf;
@property (weak, nonatomic) IBOutlet UIButton *encryptoButton;

@end

@implementation EnCryptoImageViewController

- (instancetype)initWithImageName:(NSString *)nameString
{
    self = [super init];
    if (self) {
        _exmapleImageName = nameString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cryptoImageDataTxf.text = @"加密中...";
    self.cryptoImageDataTxf.editable = NO;
    self.encryproTxf.editable = NO;
    self.encryptoButton.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.exmapleImageName ofType:nil]];
        NSTimeInterval start = CACurrentMediaTime();
        self.cryptoImageData = [data AES256EncryptWithKey:AES];
        NSTimeInterval now = CACurrentMediaTime();
        self.cryptoTime = now - start;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cryptoImageDataTxf.text = self.cryptoImageData.description;
            self.encryptoButton.enabled = YES;
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- IBAction
- (IBAction)encryptoButtonClicked:(id)sender
{
    NSTimeInterval start = CACurrentMediaTime();
   NSData *newData = [self.cryptoImageData AES256DecryptWithKey:AES];
    NSTimeInterval now = CACurrentMediaTime();
    self.encryptoTime = now - start;
    self.encryproImageView.image = [UIImage imageWithData:newData];
    
    
    NSString *promatString = [[NSString alloc] initWithFormat:@"大小：%.2fkb\n分辨率：%dx%d\n 加密时间：%fms\n解密时间：%fms",
                              newData.length/1000.0,
                              (int)self.encryproImageView.image.size.width,
                              (int)self.encryproImageView.image.size.height,
                              self.cryptoTime*1000,
                              self.encryptoTime*1000];
    
    self.encryproTxf.text = promatString;
}


@end
