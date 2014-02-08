//
//  AuthenticatorViewController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "AuthenticatorViewController.h"
#import "UIImage+ImageEffects.h"
#import "OrderViewController.h"
#import "TransitionManager.h"

@implementation AuthenticatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *uiImage = [UIImage imageNamed:@"foodcake"];
    UIImage *image = [uiImage applyLightEffect];
    [self.backgroundView setImage:image];

    _userNameTextField.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    _loginButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];

    self.transitionManager = [[TransitionManager alloc]init];
    self.transitionManager.appearing = YES;
    self.transitionManager.duration = .5;

    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-20.0;
    interpolationHorizontal.maximumRelativeValue = @20.0;

    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-20.0;
    interpolationVertical.maximumRelativeValue = @20.0;

    [self.backgroundView addMotionEffect:interpolationHorizontal];
    [self.backgroundView addMotionEffect:interpolationVertical];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)userNameTextField:(UITextField *)sender {
}
- (IBAction)onLoginButtonTap:(UIButton *)sender {
//    OrderViewController *modal = [[OrderViewController alloc]init];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderViewController"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:modal animated:YES completion:^{
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting

                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.appearing = YES;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.appearing = NO;
    return self.transitionManager;
}
@end
