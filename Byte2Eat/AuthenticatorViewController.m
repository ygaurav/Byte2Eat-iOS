#import "AuthenticatorViewController.h"
#import "UIImage+ImageEffects.h"
#import "TransitionManager.h"
#import "OrderViewController.h"
#import "Constants.h"
#import "Utilities.h"

@implementation AuthenticatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _userNameTextField.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    _loginButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    _errorLabel.text = @"";

    self.transitionManager = [[TransitionManager alloc]init];
    self.transitionManager.appearing = YES;
    self.transitionManager.duration = .5;
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
//    if(self.view.bounds.size.height < 500){
//        self.loginButtonConstraint.constant = 100;
//        [self.scrollView setNeedsUpdateConstraints];
//        [self.scrollView layoutIfNeeded];
//    }

    [self setTitleStyles];
    [self setMotionEffect];
    [self setEmitterAnimation];
    [self setBackgroundImage];
    [self.userNameTextField addTarget:self action:@selector(onTextFieldTouch:) forControlEvents:UIControlEventAllEvents];
    [self changeEmitterBirthrateTo:100];
}

-(void)viewDidAppear:(BOOL)animated {
    if([Utilities isUserLoggedIn]){
        [self changeEmitterBirthrateTo:0];
        [self goToOrderScreen:[Utilities getUserDetailsFromPlist]];
        return;
    }else{
        [self setTitleAnimation];
        [self showError:@"Please log in to continue."];
    }
}

- (void)setBackgroundImage {
    [_backgroundView setImage:[UIImage imageNamed:@"slicedfruitcopy"]];
    dispatch_async(dispatch_queue_create("com.spiderlogic.Byte2Eat", NULL), ^{
        __block UIImage *image = [[UIImage imageNamed:@"slicedfruitcopy"] applyLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_backgroundView
                              duration:3.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [_backgroundView setImage:image];
                            } completion:^(BOOL finished){
                image = nil;
            }];
        });
    });
}

- (void)setTitleStyles {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 3.0;
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(0, 0);

    NSMutableAttributedString *byte2eatHeader = [[NSMutableAttributedString alloc] initWithString:@"Byte2Eat"];
    NSRange range = NSMakeRange(0, [byte2eatHeader length]);
    [byte2eatHeader addAttribute:NSShadowAttributeName value:shadow range:range];

    NSMutableAttributedString *loginSubheading = [[NSMutableAttributedString alloc] initWithString:@"Login"];
    [loginSubheading addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, loginSubheading.length)];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.userNameTextField.layer.cornerRadius = 10;
        self.loginButton.layer.cornerRadius = 10;
        [byte2eatHeader addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:100] range:range];
        [byte2eatHeader addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:100] range:range];
        
        [loginSubheading addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:35] range:NSMakeRange(0, loginSubheading.length)];
        [loginSubheading addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:35] range:NSMakeRange(0, loginSubheading.length)];
    }else{
        [byte2eatHeader addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:50] range:range];
        [byte2eatHeader addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:50] range:range];
        
        [loginSubheading addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, loginSubheading.length)];
        [loginSubheading addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:25] range:NSMakeRange(0, loginSubheading.length)];
    }
    
    [self.byte2eatHeader setAttributedText:byte2eatHeader];
    [self.loginSubheading setAttributedText:loginSubheading];

}

- (void)setTitleAnimation {
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D = CATransform3DScale(transform3D, 5, 5, 5);
    transform3D.m34 = 1./-1200;

    self.byte2eatHeader.layer.transform = transform3D;
    self.loginSubheading.layer.transform = transform3D;
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             self.byte2eatHeader.layer.transform = CATransform3DIdentity;
                         self.loginSubheading.layer.transform = CATransform3DIdentity;
                     } completion:nil];

}

- (void)setMotionEffect {
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @30.0;
    interpolationHorizontal.maximumRelativeValue = @-30.0;

    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @30.0;
    interpolationVertical.maximumRelativeValue = @-30.0;

    [self.backgroundView addMotionEffect:interpolationHorizontal];
    [self.backgroundView addMotionEffect:interpolationVertical];
}

- (void)setEmitterAnimation {
    _leftEmitterLayer = [CAEmitterLayer layer];
    _leftEmitterLayer.emitterPosition = CGPointMake(self.errorLabel.center.x - self.view.bounds.size.width/2, self.errorLabel.center.y);
    _leftEmitterLayer.emitterZPosition = 10.0;
    _leftEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _leftEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    _rightEmitterLayer = [CAEmitterLayer layer];
    _rightEmitterLayer.emitterPosition = CGPointMake(self.errorLabel.center.x  + self.view.bounds.size.width/2, self.errorLabel.center.y);
    _rightEmitterLayer.emitterZPosition = 10.0;
    _rightEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _rightEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell*leftEmitterCell = [CAEmitterCell emitterCell];
    leftEmitterCell.birthRate = 0;
    leftEmitterCell.emissionLongitude = M_PI*2;
    leftEmitterCell.lifetime = 4;
    leftEmitterCell.velocity = 100;
    leftEmitterCell.velocityRange = 40;
    leftEmitterCell.emissionRange = M_PI*8/180;
    leftEmitterCell.spin = 3;
    leftEmitterCell.spinRange = 6;
    leftEmitterCell.xAcceleration = 100;
    leftEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    leftEmitterCell.scale = 0.03;
    leftEmitterCell.alphaSpeed = -0.15;
    leftEmitterCell.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
    [leftEmitterCell setName:@"left"];

    CAEmitterCell *rightEmitterCell = [CAEmitterCell emitterCell];
    rightEmitterCell.birthRate = 0;
    rightEmitterCell.emissionLongitude = -M_PI*179/180;
    rightEmitterCell.lifetime = 4;
    rightEmitterCell.velocity = 100;
    rightEmitterCell.velocityRange = 40;
    rightEmitterCell.emissionRange = M_PI*8/180;
    rightEmitterCell.spin = 3;
    rightEmitterCell.spinRange = 6;
    rightEmitterCell.xAcceleration = -100;
    rightEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    rightEmitterCell.scale = 0.03;
    rightEmitterCell.alphaSpeed = -0.15;
    rightEmitterCell.color =[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;
    [rightEmitterCell setName:@"right"];

    _leftEmitterLayer.emitterCells = @[leftEmitterCell];
    _rightEmitterLayer.emitterCells = @[rightEmitterCell];

    [_scrollView.layer addSublayer:self.leftEmitterLayer];
    [_scrollView.layer addSublayer:self.rightEmitterLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)userNameTextField:(UITextField *)sender {
    NSLog(@"hehe");
}
- (IBAction)onLoginButtonTap:(UIButton *)sender {

    NSString *userName = _userNameTextField.text;

    userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSRange whiteSpaceRange = [userName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

    if(userName.length >0){
        if (whiteSpaceRange.location != NSNotFound) {
            [self showError:@"Username cannot have space"];
        }else{
            [self authenticateUserNameAndGotoOrderScreen:userName];
        }
    }
    else{
        [self showError:@"Username cannot be empty" ];
    }
}

-(void) authenticateUserNameAndGotoOrderScreen:(NSString *)userName{
    [self disableUserInput];
    _errorLabel.text = @"";
    
    [self changeEmitterBirthrateTo:100];
    NSString *usernameURL = [NSString stringWithFormat:keyURLUserAuth, userName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:usernameURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self enableUserInput];
             BOOL userExists = ![((NSNumber *)responseObject[keyUserId]) isEqualToNumber:@0];
             NSNumber *userId = (NSNumber *)responseObject[keyUserId];
             NSLog(@"--- %d -- %@", userExists, userId);
             if(userExists){
                 [Utilities setUserDetailsInPlist:responseObject];
                 [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:12*60*60];
                 [self goToOrderScreen:responseObject];
             }else{
                 NSString *response = (NSString *)responseObject[keyResponseMessage];
                 [self showError:response];
                 NSLog(@"%@",response);
             }
             [self changeEmitterBirthrateTo:0];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self enableUserInput];
             [self changeEmitterBirthrateTo:0];
             [self showError:error.localizedDescription];
             NSLog(@"Error: %@", error);
         }];
}

- (void)showError:(NSString *)message {
    [self changeEmitterBirthrateTo:0];
    [self.timer invalidate];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);


    NSMutableAttributedString *error = [[NSMutableAttributedString alloc] initWithString:message];
    [error addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, error.length)];
    [error addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, error.length)];

    
    if ([Utilities isiPad]) {
        [error addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Baskerville-SemiBoldItalic" size:20] range:NSMakeRange(0, error.length)];
    }else{
        [error addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Baskerville-SemiBoldItalic" size:15] range:NSMakeRange(0, error.length)];
    }
    
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
                         } completion:^(BOOL finished){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:keyErrorMessageTime target:self selector:@selector(removeErrorMessage:) userInfo:nil repeats:NO];
    }];

}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    [_leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
    [_rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
}

- (void)goToOrderScreen:(NSDictionary *)userInfo {
    [self.userNameTextField setText:@""];
    
    UIStoryboard *storyboard = [Utilities getStoryBoard];
    OrderViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderViewController"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [modal setUserInfo:userInfo];
    [self presentViewController:modal animated:YES completion:^{
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text field resigned");
    [textField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

    NSString *userName = _userNameTextField.text;

    userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSRange whiteSpaceRange = [userName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

    if(userName.length >0){
        if (whiteSpaceRange.location != NSNotFound) {
            [self showError:@"Username cannot have space"];
        }else{
            [self authenticateUserNameAndGotoOrderScreen:userName];
        }
    }
    else{
        [_userNameTextField setText:@""];
    }
    return YES;
}

- (IBAction)onTextFieldTouch:(UITextField *)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.appearing = YES;
    self.transitionManager.cornerRadius = 0;
    self.transitionManager.scaleFactor = 1;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.appearing = NO;
    return self.transitionManager;
}

- (void)removeErrorMessage:(NSTimer *)timer {
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorLabel.alpha = 0;
                     } completion:nil];
    [timer invalidate];
}

- (void)enableUserInput {
    [_userNameTextField setEnabled:YES];
    [_loginButton setEnabled:YES];
}

- (void)disableUserInput {
    [_loginButton setEnabled:NO];
    [_userNameTextField setEnabled:NO];
}

@end
