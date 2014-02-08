//
//  AuthenticatorViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//


@class TransitionManager;

@interface AuthenticatorViewController : UIViewController <UIViewControllerTransitioningDelegate, NSURLConnectionDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(nonatomic, strong) TransitionManager *transitionManager;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) CAEmitterLayer *leftEmitterLayer;
@property (nonatomic) CAEmitterLayer *rightEmitterlayer;

- (IBAction)onLoginButtonTap:(UIButton *)sender;

@end
