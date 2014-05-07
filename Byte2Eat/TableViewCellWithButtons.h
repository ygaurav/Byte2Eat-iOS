//
//  TableViewCellWithButtons.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 10/04/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScrollingCellDelegate;

@interface TableViewCellWithButtons : UITableViewCell <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelItemName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (strong, nonatomic) IBOutlet UIScrollView *testScrollView;
@property (strong, nonatomic) id<ScrollingCellDelegate> scrollDelegate;
@property (strong, nonatomic) UIColor *color;
@end

@protocol ScrollingCellDelegate <NSObject>

-(void)scrollingCellDidBeginPulling:(TableViewCellWithButtons *)cell;
-(void)scrollingCell:(TableViewCellWithButtons *)cell didChangePullOffset:(CGFloat)offset;
-(void)scrollingCellDidEndPulling:(TableViewCellWithButtons *)cell;

@end
