//
//  OrderViewController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 07/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "OrderViewController.h"
#import "UIImage+ImageEffects.h"
#import "Constants.h"
#import "OrderHistoryViewController.h"
#import "TransitionManager.h"
#import "ThanksViewController.h"

@implementation OrderViewController{
    BOOL isFetchingMenu;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    isFetchingMenu = NO;
    [self setUserData];
    [self styleStaticData];
    [self setRandomBackgroundImage];
    [self setUpAnimations];
    [self fetchTodayMenu];

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];

    [self fetchUserDetails];
}

- (void)fetchUserDetails {
    NSString *usernameURL = [NSString stringWithFormat:keyURLUserAuth, _userName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:usernameURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
//    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake){
        if (isFetchingMenu){
            NSLog(@"Shake detected. Already fetching...");
            return;
        }else{
            NSLog(@"Shake detected. Refreshing menu..");
            [self fetchTodayMenu];
        }
    }
}

- (void)fetchTodayMenu {
    isFetchingMenu = YES;
    [self changeEmitterBirthrateTo:100];

    NSMutableAttributedString *itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"fetching today's menu"];
    [itemKaNaam addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSShadowAttributeName value:self.blueShadow range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60 green:71 blue:210 alpha:1] range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat: -3.0] range:NSMakeRange(0, [itemKaNaam length])];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_LabelDailyMenuItemName setAttributedText:itemKaNaam];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:keyURLDailyMenu] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)setUpAnimations {
    _leftEmitterLayer = [CAEmitterLayer layer];
    _leftEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x - 160, self.LabelDailyMenuItemName.center.y+15);
    _leftEmitterLayer.emitterZPosition = 10.0;
    _leftEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _leftEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    _rightEmitterLayer = [CAEmitterLayer layer];
    _rightEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x + 160, self.LabelDailyMenuItemName.center.y+15);
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

    self.emitterLayer = [CAEmitterLayer layer];
    self.emitterLayer.emitterPosition = CGPointMake(_LabelTotalCost.layer.position.x, _LabelTotalCost.layer.position.y + 60);
    self.emitterLayer.emitterZPosition = 10.0;
    self.emitterLayer.emitterSize = CGSizeMake(_LabelTotalCost.bounds.size.width + 5, _LabelTotalCost.bounds.size.height + 5);
    self.emitterLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell*sparkleCell = [CAEmitterCell emitterCell];
    sparkleCell.birthRate = 100;
    sparkleCell.emissionLongitude = M_PI * 2;
    sparkleCell.lifetime = 0.4;
    sparkleCell.velocity = 30;
    sparkleCell.velocityRange = 40;
    sparkleCell.emissionRange = M_PI * 2;
    sparkleCell.spin = 3;
    sparkleCell.spinRange = 6;
    sparkleCell.yAcceleration = 60;
    sparkleCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    sparkleCell.scale = 0.03;
    sparkleCell.alphaSpeed = -0.12;
    sparkleCell.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;

    self.emitterLayer.emitterCells = @[sparkleCell];

}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    [_leftEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.left.birthRate"];
    [_rightEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.right.birthRate"];
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)styleStaticData {

    self.orderButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.logoutButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.orderHistoryButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.orderHistoryButton.layer.cornerRadius = 3;
    self.logoutButton.layer.cornerRadius = 3;
    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);

    self.blueShadow = [[NSShadow alloc] init];
    self.blueShadow.shadowBlurRadius = 3.0;
    self.blueShadow.shadowColor = [UIColor colorWithRed:60 green:71 blue:210 alpha:1];
    self.blueShadow.shadowOffset = CGSizeMake(0, 0);

    self.redShadow = [[NSShadow alloc] init];
    self.redShadow.shadowBlurRadius = 3.0;
    self.redShadow.shadowColor = [UIColor redColor];
    self.redShadow.shadowOffset = CGSizeMake(0, 0);

    self.greenShadow = [[NSShadow alloc] init];
    self.greenShadow.shadowBlurRadius = 3.0;
    self.greenShadow.shadowColor = [UIColor colorWithRed:50/256.0 green:193/256.0 blue:92/256.0 alpha:1];
    self.greenShadow.shadowOffset = CGSizeMake(0, 0);

    UIFont *font = [UIFont systemFontOfSize:40];

    NSMutableAttributedString *khanemein = [[NSMutableAttributedString alloc] initWithString:@"Aaj Khane Mein Kya Hai"];
    NSRange range = NSMakeRange(0, [khanemein length]);
    [khanemein addAttribute:NSShadowAttributeName value:self.shadow range:range];
    [khanemein addAttribute:NSFontAttributeName value:font range:range];
    [_aajKhaneMeinKyaHai setAttributedText:khanemein];

    NSMutableAttributedString *userKaNaam = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi, %@", _userName]];
    [userKaNaam addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, userKaNaam.length)];
    [_LabelUserName setAttributedText:userKaNaam];

    [_LabelTotalOrder setText:[NSString stringWithFormat:@"%@",_todayTotalOrder]];

    NSMutableAttributedString *remainingBalanceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-",_remainingBalance]];
    if([_remainingBalance compare:[NSNumber numberWithInt:0]] == NSOrderedAscending ){
        [remainingBalanceString addAttribute:NSShadowAttributeName value:self.redShadow range:NSMakeRange(0, remainingBalanceString.length)];
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, remainingBalanceString.length)];
    }else{
        [remainingBalanceString addAttribute:NSShadowAttributeName value:self.greenShadow range:NSMakeRange(0, remainingBalanceString.length)];
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:50/256.0 green:193/256.0 blue:92/256.0 alpha:1] range:NSMakeRange(0, remainingBalanceString.length)];
    }
    [_LabelRemainingBalance setAttributedText:remainingBalanceString];
}

- (void)setUserData {

    self.transitionManager = [[TransitionManager alloc] init];
    _errorLabel.text = @"";
    _pricePerUnit = (NSNumber *)[_userInfo objectForKey:keyItemPrice];
    _itemName = @"";
    NSString *name = [_userInfo objectForKey:keyUserName];
    _userName = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
    _remainingBalance = [_userInfo objectForKey:keyBalance];
    _currentOrderNumber = [NSNumber numberWithInt:1];
    _todayTotalOrder = [_userInfo objectForKey:keyTodaysOrderQty];
    _userId = [_userInfo objectForKey:keyUserId];
}

- (void)setRandomBackgroundImage {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];

    int seconds = [components second];
    int d = seconds%5;

    UIImage *uiImage;
    switch(d){
        case 0:
            uiImage = [UIImage imageNamed:@"myoranges"];
            break;
        case 2:
            uiImage = [UIImage imageNamed:@"fruits.png"];
            break;
        case 3:
            uiImage = [UIImage imageNamed:@"foodcake"];
            break;
        case 4:
            uiImage = [UIImage imageNamed:@"slicedfruitcopy"];
            break;
        default:
            uiImage = [UIImage imageNamed:@"slicedfruitcopy"];
    }

    UIImage *image = [uiImage applyLightEffect];

    [self.backgroundImageView setImage:image];

    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-20.0;
    interpolationHorizontal.maximumRelativeValue = @20.0;

    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-20.0;
    interpolationVertical.maximumRelativeValue = @20.0;

    [self.backgroundImageView addMotionEffect:interpolationHorizontal];
    [self.backgroundImageView addMotionEffect:interpolationVertical];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%i",row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _currentOrderNumber = [NSNumber numberWithInteger:row + 1];

    [self.scrollView.layer addSublayer:self.emitterLayer];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(removeEmitter:) userInfo:nil repeats:NO];
}

- (void)removeEmitter:(NSTimer *)timer {
    NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %i/-", [_pricePerUnit integerValue] * [_currentOrderNumber integerValue]]];
    [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
    [_LabelTotalCost setAttributedText:totalCostString];

    [self.emitterLayer removeFromSuperlayer];
    [timer invalidate];
}

- (void)setTodayMenu:(NSDictionary *)dictionary {
    _dailyMenuId = [dictionary objectForKey:keyMenuId];
    _itemName = [dictionary objectForKey:keyItemName];
    NSLog(@"---- %@",_dailyMenuId);
    NSMutableAttributedString *itemKaNaam = [[NSMutableAttributedString alloc] initWithString:_itemName];
    [itemKaNaam addAttribute:NSShadowAttributeName value:self.blueShadow range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60 green:71 blue:210 alpha:1] range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat: -3.0] range:NSMakeRange(0, [itemKaNaam length])];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_LabelDailyMenuItemName setAttributedText:itemKaNaam];

    _pricePerUnit = (NSNumber *)[dictionary objectForKey:keyItemPrice];

    NSMutableAttributedString *pricePerUnitString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-",[dictionary objectForKey:keyItemPrice]]];
    [pricePerUnitString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, pricePerUnitString.length)];
    [_LabelPricePerUnit setAttributedText:pricePerUnitString];

    NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %i/-", [_pricePerUnit integerValue] * [_currentOrderNumber integerValue]]];
    [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
    [_LabelTotalCost setAttributedText:totalCostString];
}

- (void)showError:(NSString *)response {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.7];
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);


    NSMutableAttributedString *error = [[NSMutableAttributedString alloc] initWithString:response];
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

- (void)enableUserInput {
    [self.OrderNumberPicker setUserInteractionEnabled:YES];
}

-(void)disableUserInput{
    [self.OrderNumberPicker setUserInteractionEnabled:NO];
}


- (IBAction)onOrder:(UIButton *)sender {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OrderSummary"
//            message:@"Today's order \n ---------- \n " delegate:self
//  cancelButtonTitle:@"Cancel"
//          otherButtonTitles:@"OK", nil];
//    [alert show];

    [self goToThankYouScreen];
    [self changeEmitterBirthrateTo:100];
//    [self disableUserInput];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:keyURLPostOrder]];
//    request.HTTPMethod = @"POST";
//    request.timeoutInterval = 10;
//    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    NSError *error;
//    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
//    [order setObject:_currentOrderNumber forKey:@"Quantity"];
//    [order setObject:_userId forKey:@"UserId"];
//    [order setObject:_dailyMenuId forKey:@"DailyMenuid"];
//    [order setObject:@"iPhone" forKey:@"DeviceInfo"];
//    NSData *requestBodyData =   [NSJSONSerialization dataWithJSONObject:order options:NSJSONWritingPrettyPrinted error:&error];
//    request.HTTPBody = requestBodyData;
//    NSLog(@"%@",requestBodyData);
//    NSLog(@"%@",request);
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

//    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onOrderHistory:(UIButton *)sender {
    self.transitionManager.scaleFactor = 0.9;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderHistoryViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderHistoryScreen"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [modal setUser:_userName];
    [self presentViewController:modal animated:YES completion:^{
    }];
}
- (IBAction) onLogout:(UIButton *)sender {
    //TODO : logout
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"GET"]) {
        [self enableUserInput];
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        BOOL itemExists = ![((NSNumber *)[jsonArray objectForKey:keyMenuId]) isEqualToNumber:[NSNumber numberWithInt:1]];
        if(itemExists){
            [self setTodayMenu:jsonArray];
        }else{
            NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
            [self showError:response];
        }
    } else {
        [self enableUserInput];
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSString *response = (NSString *) [responseDict objectForKey:keyResponseMessage];
        bool boolValue = (bool)[responseDict objectForKey:keyBoolValue];
        if(boolValue){
            [self goToThankYouScreen];
        }

    }
}

- (void)goToThankYouScreen {
    self.transitionManager.scaleFactor = 1;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ThanksViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDThankYouController"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:modal animated:YES completion:^{
    }];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    isFetchingMenu = NO;
    [self changeEmitterBirthrateTo:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    isFetchingMenu = NO;
    [self changeEmitterBirthrateTo:0];
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"GET"]){
        [self showError:@"Some error occurred. Try again."];
        NSMutableAttributedString *itemKaNaam=nil;
        if ([_itemName isEqualToString:@""]||[_itemName isEqualToString:@"N/A"]) {
            itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"N/A"];
        } else {
            itemKaNaam = [[NSMutableAttributedString alloc] initWithString:_itemName];
        }
        [itemKaNaam addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSShadowAttributeName value:self.blueShadow range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60 green:71 blue:210 alpha:1] range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat: -3.0] range:NSMakeRange(0, [itemKaNaam length])];
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0;
        animation.type = kCATransitionFade;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
        [_LabelDailyMenuItemName setAttributedText:itemKaNaam];
    } else {
        [self showError:error.localizedDescription];
    }
    NSLog(@"Seriously what happend : %@", error.domain);
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
