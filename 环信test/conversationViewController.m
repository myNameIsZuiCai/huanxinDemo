//
//  conversationViewController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "conversationViewController.h"
#import "EMSDK.h"
@interface conversationViewController ()<EMClientDelegate,EMContactManagerDelegate>

@end

@implementation conversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor grayColor];
    [[EMClient sharedClient] addDelegate:self];
    [[EMClient sharedClient].contactManager addDelegate:self];
//    [[EMClient sharedClient].chatManager addDelegate:self];
    // Do any additional setup after loading the view.
}
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState{
    NSLog(@"类型为：%d",aConnectionState);
    switch (aConnectionState) {
        case EMConnectionConnected:
            self.title=@"消息(已连接)";
            break;
        case EMConnectionDisconnected:
            self.title=@"消息(未连接)";
        break;
        default:
            break;
    }
}
- (void)autoLoginDidCompleteWithError:(EMError *)aError{
    if (aError==nil) {
        self.title=@"消息";
    }
}
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage __deprecated_msg("Use -friendRequestDidReceiveFromUser:message:"){
    NSLog(@"你收到了来自%@的好友请求,附带信息：%@",aUsername,aMessage);
    //同意或者拒绝弹窗
    //先创建alert弹出框
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"你收到了来自xxx的好友请求" message:aMessage preferredStyle:UIAlertControllerStyleActionSheet];
    //添加两个按钮
    UIAlertAction *actionDefault=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //同意来自对方的请求
        EMError *error= [[EMClient sharedClient].contactManager acceptInvitationForUsername:aUsername];
        if(error==nil){
            NSLog(@"接受成功");
        }else{
            NSLog(@"接受失败");
        }
        
    }];
    UIAlertAction *actionReject=[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSError *error=[[EMClient sharedClient].contactManager declineInvitationForUsername:aUsername];
        if(error==nil){
            NSLog(@"拒绝成功");
        }else{
            NSLog(@"拒绝失败");
        }
    }];
    [alert addAction:actionDefault];
    [alert addAction:actionReject];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
