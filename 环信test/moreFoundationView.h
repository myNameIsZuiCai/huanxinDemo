//
//  moreFoundationView.h
//  环信test
//
//  Created by 上海均衡 on 2017/1/9.
//  Copyright © 2017年 上海均衡. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^imageBlock)(NSString *image);

typedef void(^talkBlock)(NSString *talk);

typedef void(^videoBlock)(NSString *video);
@interface moreFoundationView : UIView
@property(nonatomic,copy) imageBlock sendImageBlock;
@property(nonatomic,copy) talkBlock sendTalkBlock;
@property(nonatomic,copy) videoBlock sendVideoBlock;
@end
