//
//  settingViewController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "settingViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "EMSDK.h"
@interface settingViewController ()

@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    // Do any additional setup after loading the view.
}

- (IBAction)ExitLogin:(id)sender {
    //退出登录
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        if (!aError) {
            //退出登录的时候再次设置根控制器为ViewController对象
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController *vc= [story instantiateViewControllerWithIdentifier:@"ViewController"];
            //获取AppDelegate中的navigationController
            AppDelegate *app=[UIApplication sharedApplication].delegate;
            //获取到window
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            window.rootViewController=app.navigation;
        }
    }];
    
}


@end
