//
//  chatToolView.h
//  环信test
//
//  Created by 上海均衡 on 2016/12/28.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

typedef enum{
    toolViewRecordTypeStart,
    toolViewRecordTypeStop,
    toolViewRecordTypeCancel
}toolViewRecordType;

typedef enum{
    toolViewSendTypeSend,
    toolViewSendTypeBegin
}toolViewSendType;

#import <UIKit/UIKit.h>
typedef void (^sendTextBlock)(UITextField *text,toolViewSendType type);
//定义一个block
typedef void(^recordButtonClickBlock)(toolViewRecordType,UIButton *);
//弹出更多视图的block
typedef void(^appearMoreView)();
//创建一个协议
@protocol toolViewRecordButtonDelegate <NSObject>
-(void)toolViewWithType:(toolViewRecordType )type buttonClick:(UIButton *)btn;
@end
@interface chatToolView : UIView
{
    NSInteger _num;
}
@property(nonatomic,copy) sendTextBlock sendText;
@property(nonatomic,copy) appearMoreView appearMore;

@property(nonatomic,assign) id<toolViewRecordButtonDelegate> delegate;
@end
