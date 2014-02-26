
#import "OrderViewController.h"
#import "UIImage+ImageEffects.h"
#import "Constants.h"
#import "OrderHistoryViewController.h"
#import "TransitionManager.h"
#import "ThanksViewController.h"
#import "Utilities.h"
#import "OrderHistoryCollectionViewController.h"

@implementation OrderViewController{
    BOOL isFetchingMenu;
    BOOL isCoreMotionTimerValid;
    BOOL isPickerVisible;
    NSLayoutConstraint *beforeConstraint;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    isFetchingMenu = NO;
    isCoreMotionTimerValid = false;
//    self.transitionManager = [[TransitionManager alloc] init];
    self.transitionManager = [[InteractiveTransitionManager alloc] init];
    beforeConstraint = self.totalCostConstraint;

    [self.orderQuantityButton setTitle:@"1" forState:UIControlStateNormal];

    [self initShadows];
    [self setUserInformation];
    [self styleStaticData];
    [self setRandomBackgroundImage];
    [self hidePickerView];
    [self setUpAnimations];
    [self fetchTodayMenu];
}

-(void)hidePickerView{
    self.totalCostConstraint.constant = 12;
    self.OrderNumberPicker.alpha = 0;
    isPickerVisible = NO;
}

-(void)togglePicker:(UIGestureRecognizer *)gestureRecognizer{
    if(isPickerVisible){
        self.totalCostConstraint.constant = 12;
    }else{
        self.totalCostConstraint.constant = 162;
    }
    [self.scrollView setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(isPickerVisible){
                             [self.scrollView layoutIfNeeded];
                             self.OrderNumberPicker.alpha = 0;
                         }else{
                             [self.scrollView layoutIfNeeded];
                             [self.OrderNumberPicker setAlpha:1];
                         }
                     } completion:^(BOOL finished){
                         isPickerVisible = !isPickerVisible;
                     }];
}

-(void)startAccUpdates{
    self.coreMotionManager = [[CMMotionManager alloc]init];
    NSLog(@"Starting accelerometer updates..");
    self.coreMotionManager.accelerometerUpdateInterval = 1/30;
    isCoreMotionTimerValid = YES;
    [self.coreMotionManager startAccelerometerUpdates];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getData:) userInfo:nil repeats:YES];
}

-(void)stopAccelerometerUpdates{
    isCoreMotionTimerValid = NO;
    NSLog(@"Stopping acceleromteter updates...");
    [self.coreMotionManager stopAccelerometerUpdates];
    self.coreMotionManager = nil;
}

-(void)getData:(NSTimer *)thisTimer{
    if (isCoreMotionTimerValid) {
        CMAccelerometerData *newestData = self.coreMotionManager.accelerometerData;
        if (newestData != nil) {
            [self outputRotationData:newestData.acceleration];
        }
    }else{
        [thisTimer invalidate];
    }
}

- (void)outputRotationData:(CMAcceleration)rotation {
    [_leftEmitterLayer setValue:[NSNumber numberWithInt:(int) (rotation.x * 100)] forKeyPath:@"emitterCells.left.xAcceleration"];
    [_leftEmitterLayer setValue:[NSNumber numberWithInt:(int) -(rotation.y * 100)] forKeyPath:@"emitterCells.left.yAcceleration"];
    
    [_rightEmitterLayer setValue:[NSNumber numberWithInt:(int) (rotation.x * 100)] forKeyPath:@"emitterCells.right.xAcceleration"];
    [_rightEmitterLayer setValue:[NSNumber numberWithInt:(int) -(rotation.y * 100)] forKeyPath:@"emitterCells.right.yAcceleration"];
}

- (void)initShadows {
    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);

    self.whiteShadow = [[NSShadow alloc] init];
    self.whiteShadow.shadowBlurRadius = 3.0;
    self.whiteShadow.shadowColor = [UIColor colorWithRed:60 green:71 blue:210 alpha:1];
    self.whiteShadow.shadowOffset = CGSizeMake(0, 0);

    self.redShadow = [[NSShadow alloc] init];
    self.redShadow.shadowBlurRadius = 3.0;
    self.redShadow.shadowColor = [UIColor redColor];
    self.redShadow.shadowOffset = CGSizeMake(0, 0);

    self.greenShadow = [[NSShadow alloc] init];
    self.greenShadow.shadowBlurRadius = 3.0;
    self.greenShadow.shadowColor = [UIColor colorWithRed:50/256.0 green:193/256.0 blue:92/256.0 alpha:1];
    self.greenShadow.shadowOffset = CGSizeMake(0, 0);
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
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake){
        if (isFetchingMenu){
            NSLog(@"Shake detected. Already fetching...");
            return;
        }else{
            NSLog(@"Shake detected. Refreshing menu..");
            [self fetchTodayMenu];
            [self fetchUserDetails];
        }
    }
}

- (void)fetchTodayMenu {
    isFetchingMenu = YES;
    [self changeEmitterBirthrateTo:100];

    NSMutableAttributedString *itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"fetching today's menu"];
    [itemKaNaam addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSShadowAttributeName value:self.whiteShadow range:NSMakeRange(0, itemKaNaam.length)];
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

    self.sparkleEmitterLayer = [CAEmitterLayer layer];
//    self.sparkleEmitterLayer.emitterPosition = CGPointMake(_LabelTotalCost.layer.position.x + 2, _LabelTotalCost.layer.position.y + 63);
    self.sparkleEmitterLayer.emitterPosition = CGPointMake(_LabelTotalCost.frame.origin.x + 28, _LabelTotalCost.frame.origin.y + 15);
    self.sparkleEmitterLayer.emitterZPosition = 10.0;
    self.sparkleEmitterLayer.emitterSize = CGSizeMake(5, 5);
    self.sparkleEmitterLayer.emitterShape = kCAEmitterLayerPoint;
    self.sparkleEmitterLayer.emitterMode = kCAEmitterLayerPoints;

    CAEmitterCell*sparkleCell = [CAEmitterCell emitterCell];
    sparkleCell.birthRate = 0;
    sparkleCell.emissionLongitude = M_PI * 2;
    sparkleCell.lifetime = 0.4;
    sparkleCell.velocity = 60;
    sparkleCell.velocityRange = 40;
    sparkleCell.emissionRange = M_PI * 2;
    sparkleCell.spin = 3;
    sparkleCell.spinRange = 6;
    sparkleCell.yAcceleration = 0;
    sparkleCell.xAcceleration = 0;
    sparkleCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    sparkleCell.scale = 0.03;
    sparkleCell.alphaSpeed = -0.80;
    sparkleCell.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
    [sparkleCell setName:@"sparkle"];

    self.sparkleEmitterLayer.emitterCells = @[sparkleCell];
    [self.scrollView.layer addSublayer:self.sparkleEmitterLayer];

}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    if (birthRate == 0) {
        [self stopAccelerometerUpdates];
        [_leftEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.left.birthRate"];
        [_leftEmitterLayer setValue:[NSNumber numberWithInt:0] forKeyPath:@"emitterCells.left.yAcceleration"];
        [_rightEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.right.birthRate"];
        [_rightEmitterLayer setValue:[NSNumber numberWithInt:0] forKeyPath:@"emitterCells.right.yAcceleration"];
        [self enableMotionEffect];
    }else{
        [self disableMotionEffect];
        [_leftEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.left.birthRate"];
        [_rightEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.right.birthRate"];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startAccUpdates) userInfo:nil repeats:NO];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)styleStaticData {
    
    self.orderButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    
    self.orderQuantityButton.layer.cornerRadius = 3;
    self.orderQuantityButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    
    self.logoutButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.logoutButton.layer.cornerRadius = 3;
    
    self.orderHistoryButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.orderHistoryButton.layer.cornerRadius = 3;
    

    UIFont *font = [UIFont systemFontOfSize:40];

    NSMutableAttributedString *khanemein = [[NSMutableAttributedString alloc] initWithString:@"Aaj Khane Mein Kya Hai"];
    NSRange range = NSMakeRange(0, [khanemein length]);
    [khanemein addAttribute:NSShadowAttributeName value:self.shadow range:range];
    [khanemein addAttribute:NSFontAttributeName value:font range:range];
    [_aajKhaneMeinKyaHai setAttributedText:khanemein];

    NSMutableAttributedString *userKaNaam = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi, %@", _userName]];
    [userKaNaam addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, userKaNaam.length)];
    [_LabelUserName setAttributedText:userKaNaam];


}

- (void)setUserInformation {
    _errorLabel.text = @"";
    _itemName = @"";
    NSString *name = [_userInfo objectForKey:keyUserName];
    _remainingBalance = [_userInfo objectForKey:keyBalance];
    _currentOrderNumber = [NSNumber numberWithInt:1];

    _userId = [_userInfo objectForKey:keyUserId];
    _todayTotalOrder = [_userInfo objectForKey:keyTodaysOrderQty];
    [_LabelTotalOrder setText:[_todayTotalOrder stringValue]];
    _userName = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];

    NSMutableAttributedString *remainingBalanceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-",_remainingBalance]];
    NSRange range = NSMakeRange(0, remainingBalanceString.length);
    if([_remainingBalance compare:[NSNumber numberWithInt:0]] == NSOrderedAscending ){
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    }else{
        [remainingBalanceString addAttribute:NSShadowAttributeName value:self.greenShadow range:range];
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:50 / 256.0 green:193 / 256.0 blue:92 / 256.0 alpha:1] range:range];
    }
    [remainingBalanceString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, remainingBalanceString.length)];
    [_LabelRemainingBalance setAttributedText:remainingBalanceString];
}

- (void)setRandomBackgroundImage {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];

    long seconds = [components second];
    int d = seconds%9;

    UIImage *uiImage;
    switch(d){
        case 0:
            uiImage = [UIImage imageNamed:@"myoranges"];
            break;
        case 2:
            uiImage = [UIImage imageNamed:@"IceCream"];
            break;
        case 3:
            uiImage = [UIImage imageNamed:@"Foodcopy"];
            break;
        case 4:
            uiImage = [UIImage imageNamed:@"fetasaladfood"];
            break;
        case 5:
            uiImage = [UIImage imageNamed:@"fruits"];
            break;
        case 6:
            uiImage = [UIImage imageNamed:@"spinich"];
            break;
        case 7:
            uiImage = [UIImage imageNamed:@"FruitVegetables"];
            break;
        default:
            uiImage = [UIImage imageNamed:@"everything"];
    }

    dispatch_queue_t queue = dispatch_queue_create("com.spiderlogic.Byte2Eat", NULL);
    dispatch_async(queue, ^{
        __block UIImage *image = [uiImage applyLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_backgroundImageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [_backgroundImageView setImage:image];
                            } completion:^(BOOL finished){
                                
                                image = nil;
                            }];
        });
    });
}

-(void)enableMotionEffect{
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @20.0;
    interpolationHorizontal.maximumRelativeValue = @-20.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @20.0;
    interpolationVertical.maximumRelativeValue = @-20.0;
    
    [self.backgroundImageView addMotionEffect:interpolationHorizontal];
    [self.backgroundImageView addMotionEffect:interpolationVertical];
}

-(void)disableMotionEffect{
    for(UIMotionEffect *motionEffect in self.backgroundImageView.motionEffects){
        [self.backgroundImageView removeMotionEffect:motionEffect];
    }
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
    if (_pricePerUnit && _pricePerUnit != [NSNumber numberWithInt:0]) {
        _currentOrderNumber = [NSNumber numberWithInteger:row + 1];
        [self.orderQuantityButton setTitle:[NSString stringWithFormat:@"%@",_currentOrderNumber] forState:UIControlStateNormal];
        [_sparkleEmitterLayer setEmitterPosition:_LabelTotalCost.center];
        [_sparkleEmitterLayer setValue:[NSNumber numberWithInt:300] forKeyPath:@"emitterCells.sparkle.birthRate"];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTotalCost:) userInfo:nil repeats:NO];
    }
}

- (void)updateTotalCost:(NSTimer *)timer {
    NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %i/-", [_pricePerUnit integerValue] * [_currentOrderNumber integerValue]]];
    [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_LabelTotalCost.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_LabelTotalCost setAttributedText:totalCostString];

    [_sparkleEmitterLayer setValue:[NSNumber numberWithInt:0] forKeyPath:@"emitterCells.sparkle.birthRate"];
    [timer invalidate];
}

- (void)setTodayMenu:(NSDictionary *)dictionary {
    _dailyMenuId = [dictionary objectForKey:keyMenuId];
    _itemName = [dictionary objectForKey:keyItemName];
    _pricePerUnit = (NSNumber *)[dictionary objectForKey:keyItemPrice];
    
    
    NSMutableAttributedString *itemKaNaam = nil;
    if ([_itemName isEqualToString:@""]||[_itemName isEqualToString:@"N/A"]) {
        itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"nothing today :("];
        [self.orderQuantityButton setTitle:@"n/a" forState:UIControlStateNormal];
        self.orderQuantityButton.userInteractionEnabled = NO;
    } else {
        itemKaNaam = [[NSMutableAttributedString alloc] initWithString:_itemName];
        self.orderQuantityButton.userInteractionEnabled = YES;
    }
    
    [itemKaNaam addAttribute:NSShadowAttributeName value:self.whiteShadow range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60 green:71 blue:210 alpha:1] range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat: -3.0] range:NSMakeRange(0, [itemKaNaam length])];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_LabelDailyMenuItemName setAttributedText:itemKaNaam];

    NSString *itemPriceText=nil;
    NSString *totalCostText=nil;

    if (_pricePerUnit && _pricePerUnit != [NSNumber numberWithInt:0]) {
        itemPriceText = [NSString stringWithFormat:@"Rs %@/-",[dictionary objectForKey:keyItemPrice]];
        totalCostText = [NSString stringWithFormat:@"Rs %i/-", [_pricePerUnit integerValue] * [_currentOrderNumber integerValue]];
        [self.orderQuantityButton setTitle:[NSString stringWithFormat:@"%@",_currentOrderNumber] forState:UIControlStateNormal];
        self.orderQuantityButton.userInteractionEnabled = YES;
    } else {
        itemPriceText = @"N/A";
        totalCostText = @"N/A";
        [self.orderQuantityButton setTitle:@"n/a" forState:UIControlStateNormal];
        self.orderQuantityButton.userInteractionEnabled = NO;
    }
    NSMutableAttributedString *pricePerUnitString = [[NSMutableAttributedString alloc] initWithString:itemPriceText];
    [pricePerUnitString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, pricePerUnitString.length)];
    [_LabelPricePerUnit setAttributedText:pricePerUnitString];

    NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:totalCostText];
    [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
    [_LabelTotalCost setAttributedText:totalCostString];
    
    [self setRandomBackgroundImage];
}

- (void)showError:(NSString *)response {
    [self.timer invalidate];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);


    NSMutableAttributedString *error = [[NSMutableAttributedString alloc] initWithString:response];
    [error addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, error.length)];
    [error addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, error.length)];
    [error addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, error.length)];
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
    [self.OrderNumberPicker setUserInteractionEnabled:YES];
}

-(void)disableUserInput{
    [self.OrderNumberPicker setUserInteractionEnabled:NO];
}

- (void)postOrderRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:keyURLPostOrder]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    [order setObject:_currentOrderNumber forKey:@"Quantity"];
    [order setObject:_userId forKey:@"UserId"];
    [order setObject:_dailyMenuId forKey:@"DailyMenuid"];
    [order setObject:@"iPhone" forKey:@"DeviceInfo"];
    NSData *requestBodyData =   [NSJSONSerialization dataWithJSONObject:order options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = requestBodyData;
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)onOrder:(UIButton *)sender {
    if (_dailyMenuId && ![_dailyMenuId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        NSString *message = [NSString stringWithFormat:@"Toda's Order Summary \n\n Earlier Order Qty : %@ \nCurrent Order Qty : %@\n-------------------------------\nTotal order Qty: %u", _todayTotalOrder, _currentOrderNumber, [_todayTotalOrder unsignedIntValue] + [_currentOrderNumber unsignedIntValue]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OrderSummary"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert setTag:keyAlertOrderConfirm];
        [alert show];

        [self changeEmitterBirthrateTo:100];
        [self disableUserInput];
    }else{
        [self showError:@"Nothing in menu today. Try refreshing."];
    }
}
- (IBAction)onOrderHistory:(UIButton *)sender {
    self.transitionManager.scaleFactor = 1;

//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
//    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
//    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
//    UIImage *background = [copied applyLightEffect];
//    UIGraphicsEndImageContext();
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderHistoryViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderHistoryScreen"];
//    OrderHistoryCollectionViewController *modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderHistoryCollectionScreen"];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [modal setUser:_userName];
//    [modal setBackgroundImage:background];
    [self presentViewController:modal animated:YES completion:^{
    }];
}

- (IBAction)onQuantityChangeButton:(UIButton *)sender {
    self.orderQuantityButton.userInteractionEnabled = NO;
    if(isPickerVisible){
        self.totalCostConstraint.constant = 20;
    }else{
        self.totalCostConstraint.constant = 162;
    }
    [self.scrollView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(isPickerVisible){
                             [self.scrollView layoutIfNeeded];
                             self.OrderNumberPicker.alpha = 0;
                         }else{
                             [self.scrollView layoutIfNeeded];
                             [self.OrderNumberPicker setAlpha:1];
                         }
                     } completion:^(BOOL finished){
                         isPickerVisible = !isPickerVisible;
                         self.orderQuantityButton.userInteractionEnabled = YES;
                     }];
}
- (IBAction)onLogout:(UIButton *)sender {
    [Utilities logUserOut];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self enableUserInput];
    NSError *error = nil;
    NSURL *url = connection.currentRequest.URL;
    NSLog(@"URL : %@", url);
    if([[url absoluteString] rangeOfString:@"menu"].location != NSNotFound){
        //Menu

        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        BOOL itemExists = ![((NSNumber *)[jsonArray objectForKey:keyMenuId]) isEqualToNumber:[NSNumber numberWithInt:1]];
        if(itemExists){
            [self setTodayMenu:jsonArray];
        }else{
            NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
            [self showError:response];
        }
    }else if([[url absoluteString] rangeOfString:@"user"].location != NSNotFound){
        //User
        NSError *error = nil;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        BOOL userExists = ![((NSNumber *)[jsonArray objectForKey:keyUserId]) isEqualToNumber:[NSNumber numberWithInt:0]];
        if(userExists){
            [self setUserInfo:jsonArray];
            [self setUserInformation];
        }else{
            NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
            NSLog(@"Response : %@",response);
        }
    }else{
        //Order
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSString *response = (NSString *) [responseDict objectForKey:keyResponseMessage];
        NSNumber *boolValue = (NSNumber *)[responseDict objectForKey:keyBoolValue];

        if([boolValue boolValue]){
            [self goToThankYouScreen];
        }else{
            [self showError:response];
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

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    isFetchingMenu = NO;
    [self changeEmitterBirthrateTo:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self changeEmitterBirthrateTo:0];
    isFetchingMenu = NO;
    [self enableUserInput];
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"GET"]){
        [self showError:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        
        _dailyMenuId = 0;
        _itemName = @"";
        _pricePerUnit = 0;
        
        NSMutableAttributedString *itemKaNaam = nil;

        itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"N/A"];
        [itemKaNaam addAttribute:NSShadowAttributeName value:self.whiteShadow range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60 green:71 blue:210 alpha:1] range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat: -3.0] range:NSMakeRange(0, [itemKaNaam length])];
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0;
        animation.type = kCATransitionFade;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
        [_LabelDailyMenuItemName setAttributedText:itemKaNaam];
        
        NSString *itemPriceText = @"N/A";
        NSString *totalCostText = @"N/A";
        NSMutableAttributedString *pricePerUnitString = [[NSMutableAttributedString alloc] initWithString:itemPriceText];
        [pricePerUnitString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, pricePerUnitString.length)];
        [_LabelPricePerUnit setAttributedText:pricePerUnitString];
        
        NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:totalCostText];
        [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
        [_LabelTotalCost setAttributedText:totalCostString];
        
        [self.orderQuantityButton setTitle:@"n/a" forState:UIControlStateNormal];
        self.orderQuantityButton.userInteractionEnabled = NO;
        
    } else {
        [self showError:error.localizedDescription];
    }
    NSLog(@"Seriously what happend : %@", error.localizedDescription);
}

#pragma NSURLConnection Delegate Methods end


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.appearing = YES;
    self.transitionManager.cornerRadius = 5;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.appearing = NO;
    return self.transitionManager;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == keyAlertOrderConfirm){
        if(buttonIndex == 1){
            [self postOrderRequest];
        }else if(buttonIndex ==0){
            [self changeEmitterBirthrateTo:0];
            [self enableUserInput];
        }
    }
}

@end
