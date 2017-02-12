//
//  ViewController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "ViewController.h"
#import "rootTabbarController.h"
@interface ViewController ()<EMClientDelegate,EMChatManagerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *accountTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountTF.text=@"testzyn";
    self.passwordTF.text=@"12345";
    // Do any additional setup after loading the view, typically from a nib.
    //添加代理
//    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}
- (IBAction)regiestClick:(id)sender {
    EMError *error=[[EMClient sharedClient] registerWithUsername:@"testzyn" password:@"12345"];
    if (!error) {
        NSLog(@"注册成功");
    }else{
        NSLog(@"注册失败");
    }
}
- (IBAction)loginClick:(id)sender {
        EMError *error=[[EMClient sharedClient] loginWithUsername:@"testzyn" password:@"12345"];
        if (!error) {
            NSLog(@"登录成功");
            //设置自动登录
            //如果登录成功，就切换当前的根控制器
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            rootTabbarController *rootTab=[[rootTabbarController alloc]init];
            window.rootViewController=rootTab;
            //设置自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
        }else{
            NSLog(@"登录失败");
        }
    
    
    
    
    BOOL isAutoLogin=[EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        EMError *error=[[EMClient sharedClient] loginWithUsername:@"testzyn" password:@"12345"];
        if (!error) {
            NSLog(@"登录成功");
            //设置自动登录
            //如果登录成功，就切换当前的根控制器
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            rootTabbarController *rootTab=[[rootTabbarController alloc]init];
            window.rootViewController=rootTab;
        }else{
            NSLog(@"登录失败");
        }
    }
}
- (void)didAutoLoginWithError:(EMError *)aError{
    NSLog(@"错误提示：%@",aError);
}

@end
