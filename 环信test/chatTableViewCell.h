//
//  chatTableViewCell.h
//  环信test
//
//  Created by 上海均衡 on 2016/12/28.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDK.h"
@interface chatTableViewCell : UITableViewCell
@property(nonatomic,strong) EMMessage *message;
@property(nonatomic,assign) CGFloat rowHeight;
@end
