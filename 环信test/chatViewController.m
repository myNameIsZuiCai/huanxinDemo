//
//  chatViewController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/28.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "chatViewController.h"
#import "chatToolView.h"
#import "chatTableViewCell.h"
#import "EMSDK.h"
#import "EMCDDeviceManager.h"
#import "moreFoundationView.h"
@interface chatViewController ()<UITableViewDelegate,UITableViewDataSource,EMChatManagerDelegate,UIImagePickerControllerDelegate>
@property(strong,nonatomic) UITableView *chatTableView;
@property(strong,nonatomic) UIScrollView *contentView;
@property(strong,nonatomic) NSMutableArray *messages;
@property(strong,nonatomic) NSString *currentChatter;
@property(strong,nonatomic) moreFoundationView *moreView;
@property(strong,nonatomic) chatToolView *toolView;

/** 更多功能需要拿到的textView */
@property (nonatomic, weak) UITextView *anyViewNeedTextView;
@end

@implementation chatViewController
-(NSMutableArray *)messages{
    if (_messages==nil) {
        _messages=[NSMutableArray array];
    }
    return _messages;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //加载所有的会话
    [self loadAllConversations];
    //创建content
    self.contentView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.contentView.backgroundColor=[UIColor purpleColor];
    [self.view addSubview:self.contentView];
    //1、创建聊天表格
    self.chatTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-44) style:UITableViewStylePlain];
    
    self.chatTableView.delegate=self;
    self.chatTableView.dataSource=self;
    self.chatTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:self.chatTableView];
    //创建自定义控件
    self.toolView=[[chatToolView alloc]init];
    self.toolView.delegate=self;
    self.toolView.backgroundColor=[UIColor redColor];
    self.toolView.frame=CGRectMake(0, self.contentView.frame.size.height-64-44, self.view.frame.size.width, 44);

    //创建更多功能控件
    self.moreView=[[moreFoundationView alloc]init];
    self.moreView.backgroundColor=[UIColor cyanColor];
    self. moreView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/4);
    [[UIApplication sharedApplication].keyWindow addSubview:self.moreView];
    
    //发送消息
    self.toolView.sendText=^(UITextField *textFiled,toolViewSendType type){
        if (type == toolViewSendTypeSend) {
            [self sendTextMessage:textFiled];
        }else{
            self.anyViewNeedTextView=textFiled;
        }
    };
    [self.contentView addSubview:self.toolView];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //添加聊天代理
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].chatManager addDelegate:self];
    
    
    self.toolView.appearMore=^(){
        if (self.anyViewNeedTextView) {
            [self.anyViewNeedTextView resignFirstResponder];
            
        }
        self.toolView.frame=CGRectMake(0, self.view.frame.size.height/4*3-44-64, self.view.frame.size.width, 44);
        //弹出moreView
        self.moreView.frame=CGRectMake(0, self.view.frame.size.height/4*3, self.view.frame.size.width, self.view.frame.size.height/4);
    };
    //图片block
    self.moreView.sendImageBlock=^(NSString *para){
        NSLog(@"你点击了图片");
        UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
        imagePicker.delegate=self;
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        //改变moreView的位置
        self.moreView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/4);
        [self presentViewController:imagePicker animated:YES completion:nil];

    };
    //    //语音block
    //    self.moreView.sendTalkBlock=^(NSInteger *para){
    //
    //    };
    //    //视频block
    //    self.moreView.sendVideoBlock=^(NSInteger *para){
    //        
    //    };

}
#pragma mark 如果发送的消息类型是文本
-(void)sendTextMessage:(UITextField *)textFiled{
    NSLog(@"你点击了发送按钮");
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:textFiled.text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.currentChatter from:from to:self.currentChatter body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        NSLog(@"当前发送进度：%f",progress);
    } completion:^(EMMessage *message, EMError *error) {
        NSLog(@"%@",error.errorDescription);
        //添加进数组当中
        [self.messages addObject:message];
        [self.chatTableView reloadData];
        [self scrollToLastRow];
        //清空数据
        textFiled.text=@"";
    }];
}
#pragma mark 发送录音文件的方法
-(void)sendRecordWithFilePath:(NSString *)filePath durationTime:(NSInteger)aDuration{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:filePath displayName:@"audio"];
    body.duration = aDuration;
    NSString *from = [[EMClient sharedClient] currentUsername];
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.currentChatter from:from to:self.currentChatter body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        NSLog(@"当前进度%d",progress);
    } completion:^(EMMessage *message, EMError *error) {
        NSLog(@"发送完成");
        [self.messages addObject:message];
        [self.chatTableView reloadData];
        [self scrollToLastRow];
    }];
    
}
#pragma mark 当选择完成的时候
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //隐藏picker
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    //保持moreView位置不变
    self.moreView.frame=CGRectMake(0, self.view.frame.size.height/4*3, self.view.frame.size.width, self.view.frame.size.height/4);
    //发送图片
    [self sendImageMessage:image];
}
#pragma mark 发送图片消息
-(void)sendImageMessage:(UIImage *)image{
    NSData *data = UIImagePNGRepresentation(image);
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:data displayName:@"me.png"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.currentChatter from:from to:self.currentChatter body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        NSLog(@"当前发送图片的进度:%d",progress);
    } completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"发送完成");

            [self.messages addObject:message];
            [self.chatTableView reloadData];
            [self scrollToLastRow];
        }
        
    }];
}

#pragma mark 实现录音按钮的代理方法
-(void)toolViewWithType:(toolViewRecordType)type buttonClick:(UIButton *)btn{
    switch (type) {
        case toolViewRecordTypeStart:
        {
            NSLog(@"开始录音");
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *currentTime = [formatter stringFromDate:[NSDate date]];
            NSString *fileName=[NSString stringWithFormat:@"%d%@",arc4random()%1000,currentTime];
            
            [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
                if (!error) {
                    NSLog(@"录音成功");
                }
            }];
            
        }
            break;
        case toolViewRecordTypeStop:
        {
            NSLog(@"停止录音录音");
            [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
                if (!error) {
                    NSLog(@"文件路径：%@",recordPath);
                    NSLog(@"文件持续时间：%d",aDuration);
                    [self sendRecordWithFilePath:recordPath durationTime:aDuration];
                }
            }];
        }
            break;
        case toolViewRecordTypeCancel:
        {
            NSLog(@"退出录音");
        }
            break;
        default:
            break;
    }
}

#pragma mark 让表格滚动到最后一行
-(void)scrollToLastRow{
    //滚到最后一行
    if(self.messages.count>0){
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }else{
        return;
    }
    
    
}
#pragma mark 加载所有的会话
-(void)loadAllConversations{
    //当前聊天用户为：self.currentChatter
    //获取当前聊天的会话
    EMConversation *currConver = [[EMClient sharedClient].chatManager getConversation:self.currentChatter type:EMConversationTypeChat createIfNotExist:YES];
//    NSLog(@"当前会话id：%@",currConver.conversationId);
    //获取当前会话的所有消息
    __block chatViewController *obj = self;
    [currConver loadMessagesStartFromId:nil count:10 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        NSLog(@"消息数量%d",aMessages.count);
        //遍历aMessages
        for (int i=0; i<aMessages.count; i++) {
            EMMessageBody *body=[aMessages objectAtIndex:i];
            [obj.messages addObject:body];
        }
        [self.chatTableView reloadData];
        [self scrollToLastRow];
    }];
    
}
#pragma mark 当前和自己的聊天账号
-(void)currentChater:(NSString *)chatter{
    self.currentChatter=chatter;
    self.title=chatter;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

#pragma mark 通知回调的方法
-(void)keyBoardWillChangeFrame:(NSNotification *)noti{
    CGRect keyboardF=[noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyboardF.origin.y<self.view.frame.size.height) {
        //滑动视图向上移一个键盘的位置
        self.contentView.frame = CGRectMake(0, -keyboardF.size.height, self.view.frame.size.width, self.view.frame.size.height);
        
    }else{
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}
#pragma mark 滚动的时候收回键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.contentView endEditing:YES];
    //滚动时收回moreView  toolView
    [UIView animateWithDuration:0.6f animations:^{
        self. moreView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/4);
        self.toolView.frame=CGRectMake(0, self.contentView.frame.size.height-64-44, self.view.frame.size.width, 44);
    }];
    
}

#pragma mark 收到消息
- (void)messagesDidReceive:(NSArray *)aMessages{
    NSLog(@"已经接受到消息",aMessages[0]);
    for (EMMessage *mess in aMessages) {
        switch (mess.body.type) {
            case EMMessageBodyTypeText:
                [self.messages addObject:mess];
                [self.chatTableView reloadData];
                break;
            case EMMessageBodyTypeVoice:
                [self.messages addObject:mess];
                [self.chatTableView reloadData];
                break;
            case EMMessageBodyTypeImage:
                [self.messages addObject:mess];
                [self.chatTableView reloadData];
                break;
            default:
                break;
        }
    }
    [self scrollToLastRow];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:  (NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *identifier=@"cell";
    chatTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"chatTableViewCell" owner:self options:nil] lastObject];
    }
    cell.message=self.messages[indexPath.row];
//    [cell setSelectedBackgroundView:[[UIView alloc]init]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier=@"cell";
    chatTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"chatTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.message=self.messages[indexPath.row];
    //如果消息类型是图片，就将行高固定为150;
    if (cell.message.body.type == EMMessageBodyTypeImage) {
        return 150;
    }
    
    NSLog(@"第 %d 的行高是 row height : %f",indexPath.row,cell.rowHeight);
    return cell.rowHeight;
}

@end
