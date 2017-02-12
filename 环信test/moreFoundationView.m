//
//  moreFoundationView.m
//  环信test
//
//  Created by 上海均衡 on 2017/1/9.
//  Copyright © 2017年 上海均衡. All rights reserved.
//...

#import "moreFoundationView.h"
#import "Masonry.h"

@interface moreFoundationView()
@property(nonatomic,weak) UIButton *my_pictureButton;
@property(nonatomic,weak) UIButton *my_talkButton;
@property(nonatomic,weak) UIButton *my_videoButton;

@end



@implementation moreFoundationView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        UIButton *pictureButton=[[UIButton alloc]init];
        [pictureButton setBackgroundImage:[UIImage imageNamed:@"other"] forState:UIControlStateNormal];
        [pictureButton addTarget:self action:@selector(sendImageMessage:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:pictureButton];
        
        UIButton *talkButton=[[UIButton alloc]init];
        [talkButton setBackgroundImage:[UIImage imageNamed:@"other"] forState:UIControlStateNormal];
        [self addSubview:talkButton];
        
        UIButton *videoButton=[[UIButton alloc]init];
        [videoButton setBackgroundImage:[UIImage imageNamed:@"other"] forState:UIControlStateNormal];
        [self addSubview:videoButton];
        
        self.my_pictureButton=pictureButton;
        self.my_talkButton=talkButton;
        self.my_videoButton=videoButton;
    }
    return self;
}
-(void)sendImageMessage:(id)sender{
    self.sendImageBlock(@"image");
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat selfWidth=self.frame.size.width;
//    CGFloat selfHeight=self.frame.size.height;
    CGFloat buttonWidth=(selfWidth-20)/3;
    CGFloat buttonHeight=buttonWidth;
    [self.my_pictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.mas_left).offset(5);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@(buttonHeight));
    }];
    [self.my_talkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.my_pictureButton.mas_right).offset(5);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@(buttonHeight));
    }];
    [self.my_videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.my_talkButton.mas_right).offset(5);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@(buttonHeight));
    }];
}
@end
