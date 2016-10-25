//
//  AppDelegate.m
//  TestCompress
//
//  Created by Shane on 16/9/20.
//  Copyright © 2016年 Shane. All rights reserved.
//

#import "AppDelegate.h"
#import "TmpClass.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

extern void _objc_autoreleasePoolPrint();
extern int _objc_rootRetainCount();

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setTranslucent:NO];
     //    TmpClass *tmp = nil;
//    [self tmepdd:tmp];
//    
//    NSError *error = nil;
//    [self dealError:&error];
    
//
//    NSString *tmpString = @"firstString";
//    [self changeString:tmpString];
    
//    id  __strong obj = [[NSObject alloc]init];
//    _objc_autoreleasePoolPrint();
//    id __weak o = obj;
//    NSLog(@"count: %d",_objc_rootRetainCount(obj));
//    NSLog(@"class=%@",[o class]);
//    NSLog(@"count: %d",_objc_rootRetainCount(obj));
//    _objc_autoreleasePoolPrint();
    
    return YES;
}

//- (void)tmepdd:(TmpClass *)tmp
//{
//    tmp = [TmpClass new];
//    tmp.name = @"jason";
//    tmp.id = 7;
//}
//
- (void)dealError:(NSError **)error
{
    NSError *tmp = [NSError errorWithDomain:@"tttt" code:-1 userInfo:nil];
    *error = tmp;
//    _objc_autoreleasePoolPrint();
}
//
//- (void)changeString:(NSString *)tmpString
//{
//    tmpString = @"changedString";
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
