//
//  AuthenticatorViewController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "AuthenticatorViewController.h"
#import "UIImage+ImageEffects.h"
#import "TransitionManager.h"
#import "OrderViewController.h"
#import "Constants.h"

@implementation AuthenticatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *uiImage = [UIImage imageNamed:@"slicedfruitcopy"];
    UIImage *image = [uiImage applyLightEffect];
    [self.backgroundView setImage:image];

    _userNameTextField.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    _loginButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    _errorLabel.text = @"";

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


    _leftEmitterLayer = [CAEmitterLayer layer];
    _leftEmitterLayer.emitterPosition = CGPointMake(self.loginLabel.center.x - 160, self.loginLabel.center.y + 55);
    _leftEmitterLayer.emitterZPosition = 10.0;
    _leftEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _leftEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    _rightEmitterLayer = [CAEmitterLayer layer];
    _rightEmitterLayer.emitterPosition = CGPointMake(self.loginLabel.center.x + 160, self.loginLabel.center.y + 55);
    _rightEmitterLayer.emitterZPosition = 10.0;
    _rightEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _rightEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell*leftEmitterCell = [CAEmitterCell emitterCell];
    leftEmitterCell.birthRate = 0;
    leftEmitterCell.emissionLongitude = M_PI*2;
    leftEmitterCell.lifetime = 2;
    leftEmitterCell.velocity = 100;
    leftEmitterCell.velocityRange = 40;
    leftEmitterCell.emissionRange = M_PI*8/180;
    leftEmitterCell.spin = 3;
    leftEmitterCell.spinRange = 6;
    leftEmitterCell.xAcceleration = 100;
    leftEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    leftEmitterCell.scale = 0.03;
    leftEmitterCell.alphaSpeed = -0.12;
    leftEmitterCell.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
    [leftEmitterCell setName:@"left"];

    CAEmitterCell *rightEmitterCell = [CAEmitterCell emitterCell];
    rightEmitterCell.birthRate = 0;
    rightEmitterCell.emissionLongitude = -M_PI*179/180;
    rightEmitterCell.lifetime = 2;
    rightEmitterCell.velocity = 100;
    rightEmitterCell.velocityRange = 40;
    rightEmitterCell.emissionRange = M_PI*8/180;
    rightEmitterCell.spin = 3;
    rightEmitterCell.spinRange = 6;
    rightEmitterCell.xAcceleration = -100;
    rightEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    rightEmitterCell.scale = 0.03;
    rightEmitterCell.alphaSpeed = -0.12;
    rightEmitterCell.color =[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;
    [rightEmitterCell setName:@"right"];

    _leftEmitterLayer.emitterCells = @[leftEmitterCell];
    _rightEmitterLayer.emitterCells = @[rightEmitterCell];

    [_scrollView.layer addSublayer:self.leftEmitterLayer];
    [_scrollView.layer addSublayer:self.rightEmitterLayer];
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

    NSString *userName = _userNameTextField.text;

    userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSRange whiteSpaceRange = [userName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

    if(userName.length >0){
        if (whiteSpaceRange.location != NSNotFound) {
            [self showError:@"Username cannot have space"];
        }else{
            [self disableUserInput];
            _errorLabel.text = @"";

            [self changeEmitterBirthrateTo:100];
            NSString *usernameURL = [NSString stringWithFormat:keyURLUserAuth, userName];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:usernameURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            [request setHTTPMethod:@"GET"];
            [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        }
    }
    else{
        [self showError:@"Username cannot be empty" ];
    }
}

- (void)showError:(NSString *)message {
    [self changeEmitterBirthrateTo:0];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.7];
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);


    NSMutableAttributedString *error = [[NSMutableAttributedString alloc] initWithString:message];
    [error addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, error.length)];
    [error addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, error.length)];
    [_errorLabel setAttributedText:error];

    CGPoint point = _errorLabel.center;
    [_errorLabel setCenter:CGPointMake(point.x, point.y - 100)];
    [_errorLabel setAlpha:0];

    [UIView animateWithDuration:.5
                              delay:0
             usingSpringWithDamping:0.3
              initialSpringVelocity:8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_errorLabel setCenter:point];
                             [_errorLabel setAlpha:1];
                         } completion:nil];
}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    [_leftEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.left.birthRate"];
    [_rightEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.right.birthRate"];
}

- (void)goToOrderScreen:(NSDictionary *)userInfo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderViewController"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [modal setUserInfo:userInfo];
    [self presentViewController:modal animated:YES completion:^{
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self enableUserInput];
    NSError *error = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BOOL userExists = ![((NSNumber *)[jsonArray objectForKey:keyUserId]) isEqualToNumber:[NSNumber numberWithInt:0]];
    NSNumber *userId = (NSNumber *)[jsonArray objectForKey:keyUserId];
    NSLog(@"--- %d -- %@", userExists, userId);
    if(userExists){
        NSString *userName = (NSString *)[jsonArray objectForKey:keyUserName];
        NSNumber *balance = (NSNumber *)[jsonArray objectForKey:keyBalance];
        NSNumber *todayNumberOfOrders = (NSNumber *)[jsonArray objectForKey:keyTodaysOrderQty];
        NSNumber *userId = (NSNumber *)[jsonArray objectForKey:keyUserId];
        NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
        NSLog(@" %@ , %@ , %@ , %@, %@", userName, userId,balance,todayNumberOfOrders,response);
        [self goToOrderScreen:jsonArray];
    }else{
        NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
        [self showError:response];
        NSLog(@"%@",response);
    }
}

- (void)enableUserInput {
    [_userNameTextField setEnabled:YES];
    [_loginButton setEnabled:YES];
}

- (void)disableUserInput {
    [_loginButton setEnabled:NO];
    [_userNameTextField setEnabled:NO];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self enableUserInput];
    [self changeEmitterBirthrateTo:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self enableUserInput];
    NSString *message = [NSString stringWithFormat:@"%@ %@", error.localizedDescription, @"Please try again later."];
    [self showError:message];
}
@end
