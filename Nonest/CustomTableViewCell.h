//
//  CustomTableViewCell.h
//  Nonest
//
//  Created by 細田 大志 on 2014/05/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageThumb;
@property (weak, nonatomic) IBOutlet UILabel *LabelCell;
@property (weak, nonatomic) IBOutlet UILabel *LabelTag1;
@property (weak, nonatomic) IBOutlet UILabel *LabelTag2;
@property (weak, nonatomic) IBOutlet UILabel *LabelTag3;


+ (CGFloat)rowHeight;



@end
