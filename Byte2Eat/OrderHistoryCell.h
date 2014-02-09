//
//  OrderHistoryCell.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 09/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//



@interface OrderHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelItemName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderQty;
@property (weak, nonatomic) IBOutlet UILabel *labelItemPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderCost;

@end
