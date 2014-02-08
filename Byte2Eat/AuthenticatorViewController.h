//
//  AuthenticatorViewController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransitionManager;

@interface AuthenticatorViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(nonatomic, strong) TransitionManager *transitionManager;

- (IBAction)onLoginButtonTap:(UIButton *)sender;

@end
