//
//  AppDelegate.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()<EMChatManagerDelegate,UITextViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    EMOptions *option=[EMOptions optionsWithAppkey:@"1151161221115226#huanxinlallala"];
    EMError *error=[[EMClient sharedClient] initializeSDKWithOptions:option];
    if (!error) {
        NSLog(@"SDK初始化成功");
    }
    //从故事版获得ViewController对象
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc= [story instantiateViewControllerWithIdentifier:@"ViewController"];
    self.navigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //设置控制器为Window的根控制器
    self.window.rootViewController=self.navigation;

    [self.window makeKeyAndVisible];
    //判断是否是自动登录
    BOOL isAutoLogin=[EMClient sharedClient].options.isAutoLogin;
    if (isAutoLogin) {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        rootTabbarController *rootTab=[[rootTabbarController alloc]init];
        window.rootViewController=rootTab;
    }
    return YES;
}
/*

 
 */

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
