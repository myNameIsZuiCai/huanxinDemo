//
//  chatToolView.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/28.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "chatToolView.h"
#import "Masonry.h"
#import "moreFoundationView.h"

@interface chatToolView ()<UITextFieldDelegate,toolViewRecordButtonDelegate>

@property(weak,nonatomic) UIButton *my_voiceBtn;
@property(weak,nonatomic) UITextField *my_inputView;
@property(weak,nonatomic) UIButton *my_recordBtn;
@property(weak,nonatomic) UIButton *my_moreBtn;
@end



@implementation chatToolView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _num=0;
        //添加子控件
        self.backgroundColor=[UIColor redColor];
        //1、语音按钮
        UIButton *voiceBtn=[[UIButton alloc]init];
        [self addSubview:voiceBtn];
        //2、文本输入框
        UITextField *inputView=[[UITextField alloc]init];
        inputView.delegate=self;
        [self addSubview:inputView];
        //3、录音按钮
        UIButton *recordBtn=[[UIButton alloc]init];
        //为录音按钮绑定事件
        [recordBtn addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
        [recordBtn addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
        [recordBtn addTarget:self action:@selector(cancelRecord:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:recordBtn];
        //4、更多按钮
        UIButton *moreBtn=[[UIButton alloc]init];
        [moreBtn addTarget:self action:@selector(presentMoreFoundationView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreBtn];
        
        //赋值
        //声音按钮
        self.my_voiceBtn=voiceBtn;
        self.my_voiceBtn.backgroundColor=[UIColor clearColor];
        //添加点击事件
        [self.my_voiceBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [self.my_voiceBtn addTarget:self action:@selector(setBgImage) forControlEvents:UIControlEventTouchUpInside];
        //输入框
        self.my_inputView=inputView;
        self.my_inputView.backgroundColor=[UIColor whiteColor];
        self.my_recordBtn=recordBtn;
        self.my_recordBtn.backgroundColor=[UIColor grayColor];
        [self.my_recordBtn setTitle:@"按住录音" forState:UIControlStateNormal];
        [self.my_recordBtn setTitle:@"松开发送" forState:UIControlStateHighlighted];
        self.my_recordBtn.hidden=YES;
        self.my_moreBtn=moreBtn;
        [self.my_moreBtn setBackgroundImage:[UIImage imageNamed:@"addContact"] forState:UIControlStateNormal];
    }
    return self;
}
#pragma mark 处理更多功能的操作
-(void)presentMoreFoundationView:(id)sender{
    //实现block的回调
    self.appearMore();
}
#pragma mark 开始录音
-(void)startRecord:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:buttonClick:)]) {
        [self.delegate toolViewWithType:toolViewRecordTypeStart buttonClick:button];
    }
}
#pragma mark 停止录音
-(void)stopRecord:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:buttonClick:)]) {
        [self.delegate toolViewWithType:toolViewRecordTypeStop buttonClick:button];
    }
}
#pragma mark 取消录音
-(void)cancelRecord:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:buttonClick:)]) {
        [self.delegate toolViewWithType:toolViewRecordTypeCancel buttonClick:button];
    }
}

-(void)setBgImage{
    if (_num==0) {
        //设置默认的图片
        [self.my_voiceBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        self.my_recordBtn.hidden=NO;
        _num++;
        
    }else if (_num==1){
        [self.my_voiceBtn setBackgroundImage:[UIImage imageNamed:@"keyBoard"] forState:UIControlStateNormal];
        self.my_recordBtn.hidden=YES;
        _num--;
    }else{
        return;
    }
}
-(void)layoutSubviews{
    
    [super layoutSubviews];
    [self.my_voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(@(40));
    }];
    [self.my_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
        make.left.equalTo(self.my_voiceBtn.mas_right).offset(5);
        make.right.equalTo(self.mas_right).offset(-45);
    }];
    //“按住说话”按钮
    [self.my_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
        make.left.equalTo(self.my_inputView.mas_right).offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
    }];
    
    
    [self.my_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
        make.left.equalTo(self.my_voiceBtn.mas_right).offset(5);
        make.right.equalTo(self.mas_right).offset(-45);
    }];
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (_sendText) {
        self.sendText(textField,toolViewSendTypeBegin);
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.returnKeyType=UIReturnKeySend;
}

#pragma mark 监听键盘的send事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //发送消息
    
    if (textField.text.length>0) {
        self.sendText(textField,toolViewSendTypeSend);
    }
    return YES;
}
@end
