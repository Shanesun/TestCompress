//
//  NSData+Encryption.h
//  TestCompress
//
//  Created by Shane on 2016/10/19.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
