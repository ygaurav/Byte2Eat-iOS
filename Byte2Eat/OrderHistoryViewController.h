//
//  OrderHistoryViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 09/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//



@interface OrderHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property(nonatomic, strong) NSShadow *shadow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
- (IBAction)onDoneTap:(UIButton *)sender;

- (void)setUser:(NSString *)name;
@end
