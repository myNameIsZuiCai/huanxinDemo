//
//  chatTableViewCell.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/28.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "chatTableViewCell.h"
#import "Masonry.h"
#import "EMCDDeviceManager.h"
#import "EMSDK.h"
#import "UIButton+WebCache.h"
#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

#define D_BII_DATE_Format @"yyyy/MM/dd"
#define D_BII_DATE_Format2 @"yyyy-MM-dd"

#define D_BII_TIME_Format @"HH:mm:ss"
@interface chatTableViewCell ()
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *otherIcon;
@property (strong, nonatomic) IBOutlet UIButton *otherContent;
@property (strong, nonatomic) IBOutlet UIButton *myContent;
@property (strong, nonatomic) IBOutlet UIImageView *myIcon;
@property (strong, nonatomic) EMVoiceMessageBody *voiceBody;
@property (assign, nonatomic) CGSize realSize;
@end
@implementation chatTableViewCell
-(EMVoiceMessageBody *)voiceBody{
    if (!_voiceBody) {
        _voiceBody=[[EMVoiceMessageBody alloc]init];
    }
    return _voiceBody;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.myContent.titleLabel.numberOfLines=0;
    self.otherContent.titleLabel.numberOfLines=0;
    
    [self setConstraints];
}
-(void)setConstraints{
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width);
        make.height.equalTo(@(30));
    }];

    [self.myIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    [self.otherIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
        make.left.equalTo(self.mas_left).offset(5);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];

    [self.otherContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.myIcon.mas_top);
        make.left.equalTo(self.otherIcon.mas_right).offset(5);
        
//        self.otherContent.backgroundColor=[UIColor redColor];
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)setMessage:(EMMessage *)message{
    _message=message;
    self.timeLabel.text=[self conversationTime:message.timestamp];
    //判断消息类型
    EMMessageBody *messageBody = message.body;
    if (messageBody.type == EMMessageBodyTypeText) {
        //获取消息体
        EMTextMessageBody *textBody=(EMTextMessageBody *)messageBody;
        CGSize Size = [textBody.text boundingRectWithSize:CGSizeMake(self.frame.size.width/2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]} context:nil].size;
        self.realSize=CGSizeMake(Size.width + 40, Size.height + 40);
        [self handleTextMessage:message content:textBody realsize:self.realSize];
    }else if(messageBody.type == EMMessageBodyTypeImage){
        EMImageMessageBody *imageBody=(EMImageMessageBody *)messageBody;
        [self handleImageMessage:message imageBody:imageBody];
        
    }else if(messageBody.type == EMMessageBodyTypeVoice){
        EMVoiceMessageBody *voiceBody = ((EMVoiceMessageBody *)messageBody);
        //处理语音消息
        [self handleVoiceMessage:message voicebody:voiceBody];

    }
}

#pragma mark 处理聊天时间
-(NSString *)conversationTime:(long long)chatTime{
    //1、创建一个日历对象
    NSCalendar *Calendar=[NSCalendar currentCalendar];
    //2、获取当前时间
    NSDate *currentDate=[NSDate date];
    //3、获取当前时间的年月日
    NSDateComponents *components=[Calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear=components.year;
    NSInteger currentMonth=components.month;
    NSInteger currentDay=components.day;
    //4、获取发送时间
    NSDate *sendDate=[NSDate dateWithTimeIntervalSince1970:chatTime/1000];
    //5、获取发送时间的年月日
    NSDateComponents *sendComponents=[Calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:sendDate];
    NSInteger sendYear=sendComponents.year;
    NSInteger sendMonth=sendComponents.month;
    NSInteger sendDay=sendComponents.day;
    //6、当前时间与发送时间的比较
    NSDateFormatter *formate=[[NSDateFormatter alloc]init];
    if (sendYear==currentYear && sendMonth == currentMonth && sendDay == currentDay) {
        formate.dateFormat = @"今天 HH:mm";
    }else if(sendYear==currentYear && sendMonth == currentMonth && currentDay == sendDay + 1){
        formate.dateFormat = @"昨天 HH:mm";
    }else{
        formate.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return [formate stringFromDate:sendDate];
}
#pragma mark 如果消息类型是语音
-(void)handleVoiceMessage:(EMMessage *)message voicebody:(EMVoiceMessageBody *)voiceBody{
    //获取当前聊天的对象
    NSString *chater=[[EMClient sharedClient] currentUsername];
    if ([message.from isEqualToString:chater]) {
        //如果消息来源是自己
        //隐藏别人的头像
        [self setBackgroundOfButtons:@"my"];
        [self setIconContentHidden:@"my"];
        
        //设置图片和文字
        [self.myContent setImage:[UIImage imageNamed:@"chat_sender_audio_playing_full"] forState:UIControlStateNormal];
        self.myContent.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 5, 5);
        [self.myContent setTitle:[NSString stringWithFormat:@"%d",voiceBody.duration] forState:UIControlStateNormal];
        self.myContent.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 5, 5);
        [self setIconPosionBtncontent:@"myContent" size:CGSizeMake(100, 30)];
        //为当前按钮绑定点击事件  播放语音
        
        self.voiceBody=voiceBody;
        [self.myContent addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [self setBackgroundOfButtons:@"other"];
        //如果消息来源是别人
        [self setIconContentHidden:@"other"];
        //设置图片和文字
        [self.otherContent setImage:[UIImage imageNamed:@"chat_receiver_audio_playing_full"] forState:UIControlStateNormal];
        self.otherContent.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 5, 5);
        
        [self.otherContent setTitle:[NSString stringWithFormat:@"%d",voiceBody.duration] forState:UIControlStateNormal];
        self.otherContent.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 5, 5);
        [self setIconPosionBtncontent:@"otherContent" size:CGSizeMake(100, 30)];
        //为当前按钮绑定点击事件  播放语音
        self.voiceBody=voiceBody;
        [self.otherContent addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
}
#pragma mark 播放语音
-(void)playRecord:(id)sender{
    NSString *voicePath=self.voiceBody.localPath;
    //判断当前路径下是否存在该录音文件
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:voicePath]) {
            //如果不存在，就赋值远程服务器路径
            voicePath=self.voiceBody.remotePath;
    }
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:voicePath completion:^(NSError *error) {
            if (!error) {
                NSLog(@"录音播放完毕");
            }
    }];

}
#pragma mark 如果消息类型是图片
-(void)handleImageMessage:(EMMessage *)message imageBody:(EMImageMessageBody *)imaBody{
    //获取当前聊天的对象
    NSString *chater=[[EMClient sharedClient] currentUsername];
    if ([message.from isEqualToString:chater]) {
        //如果是自己发送的隐藏别人的头像和内容
        [self setIconContentHidden:@"my"];
        NSString *path=imaBody.localPath;
        NSURL *url=nil;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            path=imaBody.thumbnailRemotePath;
            url=[NSURL URLWithString:path];
            [self.myContent sd_setBackgroundImageWithURL:url forState:UIControlStateNormal];
        }else{
            //如果存在
            UIImage *image=[UIImage imageWithContentsOfFile:path];
            [self.myContent setBackgroundImage:image forState:UIControlStateNormal];
        }
        //固定宽高为100
        [self.myContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
            make.right.equalTo(self.myIcon.mas_left).offset(-5);
            make.width.equalTo(@(100));
            make.height.equalTo(@(100));
        }];

    }else{
        
        [self setIconContentHidden:@"other"];
        NSString *path=imaBody.thumbnailLocalPath;
        NSURL *url=nil;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            path=imaBody.thumbnailRemotePath;
            url=[NSURL URLWithString:path];
            //设置图片
            [self.otherContent sd_setBackgroundImageWithURL:url forState:UIControlStateNormal];
        }else{
            UIImage *image=[UIImage imageWithContentsOfFile:path];
            //如果是本地 则从本地提取
            [self.otherContent setBackgroundImage:image forState:UIControlStateNormal];
        }
        //固定宽高为100
        [self.otherContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
            make.left.equalTo(self.otherContent.mas_right).offset(5);
            make.width.equalTo(@(100));
            make.height.equalTo(@(100));
        }];

    }
}
#pragma mark 如果消息类型是文本
-(void)handleTextMessage:(EMMessage *)message content:(EMTextMessageBody *)textBody realsize:(CGSize )realSize{
    //获取当前聊天的对象
    NSString *chater=[[EMClient sharedClient] currentUsername];
    if ([message.from isEqualToString:chater]) {
        //自己发送的  头像在右边
        [self setIconContentHidden:@"my"];
        self.myContent.titleLabel.font=[UIFont systemFontOfSize:15.0];
        self.myContent.contentEdgeInsets=UIEdgeInsetsMake(15, 20, 25, 20);
        [self.myContent setTitle:textBody.text forState:UIControlStateNormal];
        [self setIconPosionBtncontent:@"myContent" size:realSize];
        
    }else{
        //别人发的
        [self setIconContentHidden:@"other"];
        self.otherContent.titleLabel.font=[UIFont systemFontOfSize:15.0];
        self.otherContent.contentEdgeInsets=UIEdgeInsetsMake(20, 20, 20, 20);
        [self.otherContent setTitle:textBody.text forState:UIControlStateNormal];
        [self setIconPosionBtncontent:@"otherContent" size:realSize];
    }
}
#pragma mark 设置隐藏头像和内容按钮
-(void)setIconContentHidden:(NSString *)para{
    if ([para isEqualToString:@"my"]) {
        self.otherIcon.hidden=YES;
        self.otherIcon.hidden=YES;
        self.myIcon.hidden=NO;
        self.myContent.hidden=NO;
    }else{
        self.otherIcon.hidden=NO;
        self.otherIcon.hidden=NO;
        self.myIcon.hidden=YES;
        self.myContent.hidden=YES;
    }
}
#pragma mark 设置头像图片  头像位置  btn内容等
-(void)setIconPosionBtncontent:(NSString *)para size:(CGSize)realSize{
    if ([para isEqualToString:@"myContent"]) {
        [self setBackgroundOfButtons:@"my"];
        [self.myContent setTintColor:[UIColor blackColor]];
        [self.myContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.myIcon.mas_left).offset(-5);
            make.top.equalTo(self.myIcon.mas_top);
            make.width.equalTo(@(realSize.width+10));
            make.height.equalTo(@(realSize.height));
        }];
    }else if([para isEqualToString:@"otherContent"]){
        [self setBackgroundOfButtons:@"other"];
        [self.otherContent setTintColor:[UIColor blackColor]];
        [self.otherContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.otherIcon.mas_right).offset(5);
            make.top.equalTo(self.otherIcon.mas_top);
            make.width.equalTo(@(realSize.width+10));
            make.height.equalTo(@(realSize.height));
        }];
    }else{
        
    }
}
#pragma mark 设置按钮的背景图片
-(void)setBackgroundOfButtons:(NSString *)para{
    if ([para isEqualToString:@"my"]) {
        [self.myContent setBackgroundImage:[UIImage imageNamed:@"SenderTextNodeBkg"] forState:UIControlStateNormal];
        [self.myContent setBackgroundImage:[UIImage imageNamed:@"SenderTextNodeBkgHL"] forState:UIControlStateHighlighted];
    }else{
        [self.otherContent setBackgroundImage:[UIImage imageNamed:@"ReceiverTextNodeBkg"] forState:UIControlStateNormal];
        [self.otherContent setBackgroundImage:[UIImage imageNamed:@"ReceiverTextNodeBkgHL"] forState:UIControlStateHighlighted];
    }
}
#pragma mark 处理时间
- (NSString *)dateTimeString2:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSString stringWithFormat:@"%@ %@",D_BII_DATE_Format2, D_BII_TIME_Format];
    return [formatter stringFromDate:date];
}
#pragma mark 处理行高的
-(CGFloat)rowHeight{
    if (self.myContent.hidden==YES) {
//        [self.myContent layoutIfNeeded];
//        NSLog(@"%@",self.otherContent.titleLabel.text);
//        CGFloat myContentH = CGRectGetMaxY(self.otherContent.titleLabel.frame);
//        CGFloat myIconH = CGRectGetMaxY(self.otherIcon.frame);
//        return MAX(myContentH, myIconH);
        return self.realSize.height;
    }else{
//        [self.otherContent layoutIfNeeded];
//        NSLog(@"%@",self.myContent.titleLabel.text);
//        CGFloat otherContentH = CGRectGetMaxY(self.myContent.titleLabel.frame);
//        CGFloat otherIconH = CGRectGetMaxY(self.myIcon.frame);
//        return MAX(otherContentH, otherIconH);
        return self.realSize.height;
    }

}

@end
