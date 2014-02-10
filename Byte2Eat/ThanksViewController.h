//
//  ThanksViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 09/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//



@interface ThanksViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *thanksButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *thanksLabel;


- (IBAction)onThankTap:(UIButton *)sender;

@end
