//
//  contactViewController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "contactViewController.h"
#import "EMSDK.h"
#import "chatViewController.h"
@interface contactViewController ()<EMContactManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;

@property(strong,nonatomic) NSMutableArray *bodies;

@end

@implementation contactViewController
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray *)bodies{
    if (_bodies==nil) {
        _bodies=[NSMutableArray array];
    }
    return _bodies;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor orangeColor];
    [[EMClient sharedClient].chatManager addDelegate:self];
    [[EMClient sharedClient].contactManager addDelegate:self];
    [self createTableView];
    // Do any additional setup after loading the view.
    [self addContactButton];
}
//添加联系人按钮
-(void)addContactButton{
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContacts)];
    self.navigationItem.rightBarButtonItem=rightItem;
}
#pragma mark 创建表格（显示同意拒绝的表格）
-(void)createTableView{
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    //有网络的时候从服务器获取所有的好友；无网络的时候从本地数据库获取好友列表
    
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromDB];
    self.bodies=[NSMutableArray arrayWithArray:userlist];
    NSLog(@"本地获取成功%@",userlist);
    if (userlist.count==0) {
        EMError *error = nil;
        NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        self.bodies=[NSMutableArray arrayWithArray:userlist];
        [self.tableView reloadData];
        if (!error) {
            NSLog(@"服务器获取成功 -- %@",userlist);
        }
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bodies.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *str=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.textLabel.text=self.bodies[indexPath.row];
    return cell;
}
#pragma mark 添加联系人操作
-(void)addContacts{
    //先创建alert弹出框
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"添加好友" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //好友名称
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"请输入好友的名称";
    }];
    //请求信息
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"请输入请求信息";
    }];
    UITextField *userNameTF=[alert.textFields firstObject];
    UITextField *descriptionTF=[alert.textFields lastObject];
    
    //添加两个按钮
    UIAlertAction *actionDefault=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //添加好友的操作
        [[EMClient sharedClient].contactManager addContact:userNameTF.text message:descriptionTF.text completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                NSLog(@"邀请发送成功");
            }else{
                NSLog(@"添加发送失败");
            }
            
        }];
    }];
    UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:actionDefault];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMError *isDelete = [[EMClient sharedClient].contactManager deleteContact:self.bodies[indexPath.row] isDeleteConversation:YES];
        if (isDelete==nil) {
            NSLog(@"删除好友成功");
            //本地数组中删除相对应的元素
            [self.bodies removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }else{
            NSLog(@"删除好友失败");
        }
    }
}
/*!
 *  \~chinese
 *  用户B同意用户A的好友申请后，用户A和用户B都会收到这个回调
 */
- (void)friendshipDidAddByUser:(NSString *)aUsername{
    NSLog(@"%@",aUsername);
    //本地数组添加一个元素aUserName
    [self.bodies addObject:aUsername];
    [self.tableView reloadData];
}
///*
//    用户B同意用户A的加好友请求后，用户A会收到这个回调
// */
//- (void)didReceiveAgreedFromUsername:(NSString *)aUsername __deprecated_msg("Use -friendRequestDidApproveByUser:"){
//    //本地数组添加一个元素aUserName
//    [self.bodies addObject:aUsername];
//    [self.tableView reloadData];
//}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername{
    NSLog(@"我在添加别人");
}
/*  用户B删除与用户A的好友关系后，用户A，B会收到这个回调*/
- (void)friendshipDidRemoveByUser:(NSString *)aUsername{
    
    [self.tableView reloadData];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    chatViewController *chat=[[chatViewController alloc]init];
    [chat setHidesBottomBarWhenPushed:YES];
    //传值
    [chat currentChater:self.bodies[indexPath.row]];
    [self.navigationController pushViewController:chat animated:YES];
}
@end
