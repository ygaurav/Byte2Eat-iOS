//
//  AuthenticatorViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//


@class TransitionManager;

@interface AuthenticatorViewController : UIViewController <UIViewControllerTransitioningDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *byte2eatHeader;
@property (weak, nonatomic) IBOutlet UILabel *loginSubheading;
@property(nonatomic, strong) TransitionManager *transitionManager;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) NSDictionary *jsonArray;
- (IBAction)onTextFieldTouch:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;

@property (nonatomic) CAEmitterLayer *leftEmitterLayer;
@property (nonatomic) CAEmitterLayer *rightEmitterLayer;

@property(nonatomic, strong) NSTimer *timer;

- (IBAction)onLoginButtonTap:(UIButton *)sender;

@end
