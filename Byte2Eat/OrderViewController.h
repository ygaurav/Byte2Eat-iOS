//
//  OrderViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 07/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//


@interface OrderViewController : UIViewController  <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *LabelRemainingBalance;
@property (weak, nonatomic) IBOutlet UILabel *LabelUserName;
@property (weak, nonatomic) IBOutlet UILabel *LabelDailyMenuItemName;
@property (weak, nonatomic) IBOutlet UILabel *LabelPricePerUnit;
@property (weak, nonatomic) IBOutlet UILabel *LabelTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *LabelTotalOrder;
@property (weak, nonatomic) IBOutlet UIPickerView *OrderNumberPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;

@property (nonatomic) NSNumber *remainingBalance;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *itemName;
@property (nonatomic) NSNumber *pricePerUnit;
@property (nonatomic) NSNumber *totalCost;
@property (nonatomic) NSString *todayTotalOrder;
@property (nonatomic) NSNumber *currentOrderNumber;

@property (nonatomic, strong) NSShadow *shadow;
@property (nonatomic, strong) NSShadow *blueShadow;
@property (nonatomic, strong) NSShadow *greenShadow;
@property (nonatomic, strong) NSShadow *redShadow;


@property (nonatomic) CAEmitterLayer *emitterLayer;

@property (weak, nonatomic) IBOutlet UILabel *aajKhaneMeinKyaHai;

- (IBAction)onOrder:(UIButton *)sender;

@end
