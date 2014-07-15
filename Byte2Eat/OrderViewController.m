
#import "OrderViewController.h"
#import "UIImage+ImageEffects.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "ThanksViewController.h"
#import "TransitionManager.h"
#import "Utilities.h"
#import <POP/POP.h>

@implementation OrderViewController{
    BOOL isFetchingMenu;
    BOOL isCoreMotionTimerValid;
    BOOL isPickerVisible;
    NSLayoutConstraint *beforeConstraint;
    OrderHistoryViewController *modal;
    BOOL isSettingBackground;
    CAEmitterLayer *buttonEmitterLayer;
    CAEmitterLayer *buttonTopLayer;
    CAEmitterLayer *buttonBottomLayer;
    CAEmitterLayer *itemNameLayer;
    CGPoint center;
    CGPoint offsetFromCenter;
    CGPoint aajKaOffsetFromCenter;
    CGPoint aajCenter;
    CATransform3D aajTransform;
    CATransform3D currentAajTransform;
    CGFloat currentScale;
    CGFloat currentRotation;
    BOOL firstStart;
}

UIColor * GetColor(int red, int green, int blue, float alpha){
    return [UIColor colorWithRed:red/256.0 green:green/256.0 blue:blue/256.0 alpha:alpha];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    firstStart = YES;
    isFetchingMenu = NO;
    isSettingBackground = NO;
    isCoreMotionTimerValid = false;
    self.transitionManager = [[TransitionManager alloc] init];
    //    self.transitionManager = [[MyInteractiveTransitionManager alloc] init];
    beforeConstraint = self.totalCostConstraint;
    
    [self.orderQuantityButton setTitle:@"n/a" forState:UIControlStateNormal];
    [self.orderQuantityButton setEnabled:YES];
    
    [self initShadows];
    [self setUserInformation];
    [self styleStaticData];
    [self setRandomBackgroundImage];
    if (![Utilities isiPad]) {
        [self hidePickerView];
    }
    [self setUpAnimations];
    [self fetchTodayMenu];
    [self.orderButton addTarget:self action:@selector(onOrderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.orderButton addTarget:self action:@selector(onOrderTouchCancel:) forControlEvents:UIControlEventTouchDragExit];
    [self.orderButton addTarget:self action:@selector(onOrderTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderButton addTarget:self action:@selector(onOrderTouchDown:) forControlEvents:UIControlEventTouchDragEnter];
    center = self.LabelDailyMenuItemName.center;
    
    [self addDoubleTapGestureOnItemLabel];
    [self addPanGestureRecognizerToItemName];
    [self addGestureRecognizersToAaj];
}

-(void)addGestureRecognizersToAaj{
    [self.aajKhaneMeinKyaHai setUserInteractionEnabled:YES];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.aajKhaneMeinKyaHai addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotate.delegate = self;
    [self.aajKhaneMeinKyaHai addGestureRecognizer:rotate];
    currentScale = 1;
    currentRotation = 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
        return NO;
    }
    return YES;
}

-(void)handleRotation:(UIRotationGestureRecognizer *)rotate{
    switch (rotate.state) {
        case UIGestureRecognizerStateBegan:{
            break;
        }
        case UIGestureRecognizerStateChanged:{
            currentRotation = rotate.rotation;
            CATransform3D t = CATransform3DMakeRotation(currentRotation, 0, 0, 1);
            t = CATransform3DScale(t, currentScale, currentScale, currentScale);
            self.aajKhaneMeinKyaHai.layer.transform = t;
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.aajKhaneMeinKyaHai.layer.transform = CATransform3DIdentity;
                                 currentScale = 1;
                                 currentRotation = 0;
                             }];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSLog(@"Rotate Ended");
            [UIView animateWithDuration:0.2
                             animations:^{
                                 
                                 self.aajKhaneMeinKyaHai.layer.transform = CATransform3DIdentity;
                                 currentScale = 1;
                                 currentRotation = 0;
                             }];
            break;
        }
        default:
            break;
    }
}

-(void)handlePinch:(UIPinchGestureRecognizer *)pinchRecognizer{
    switch (pinchRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"Pinch Began");
            [self.aajKhaneMeinKyaHai.layer setZPosition:2000];
            aajKaOffsetFromCenter = CGPointMake(aajCenter.x - [pinchRecognizer locationInView:self.scrollView].x, aajCenter.y - [pinchRecognizer locationInView:self.scrollView].y);
            break;
        }
        case UIGestureRecognizerStateChanged:{
            currentScale = pinchRecognizer.scale;
            CATransform3D t = CATransform3DMakeRotation(currentRotation, 0, 0, 1);
            t = CATransform3DScale(t, currentScale, currentScale, currentScale);
            self.aajKhaneMeinKyaHai.layer.transform = t;
            
            self.aajKhaneMeinKyaHai.center = CGPointMake([pinchRecognizer locationInView:self.scrollView].x + aajKaOffsetFromCenter.x, [pinchRecognizer locationInView:self.scrollView].y + aajKaOffsetFromCenter.y);
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.aajKhaneMeinKyaHai.layer.transform = CATransform3DIdentity;
                                 currentRotation = 0;
                                 currentScale = 1;
                                 self.aajKhaneMeinKyaHai.center = aajCenter;
                             }];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSLog(@"Pinch Ended");
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.aajKhaneMeinKyaHai.layer.transform = CATransform3DIdentity;
                                 currentRotation = 0;
                                 currentScale = 1;
                                 self.aajKhaneMeinKyaHai.center = aajCenter;
                                 [self.aajKhaneMeinKyaHai.layer setZPosition:999];
                             }];
            break;
        }
        default:
            break;
    }
}

-(void)addPanGestureRecognizerToItemName{
    [self.LabelDailyMenuItemName setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLong:)];
    [self.LabelDailyMenuItemName addGestureRecognizer:longpressGesture];
    self.LabelDailyMenuItemName.layer.zPosition = 1000;
}

-(void)handleLong:(UILongPressGestureRecognizer *)longPressGestureRecognizer{
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            offsetFromCenter = CGPointMake(center.x - [longPressGestureRecognizer locationInView:self.scrollView].x, center.y - [longPressGestureRecognizer locationInView:self.scrollView].y);
            CATransform3D transform = self.LabelDailyMenuItemName.layer.transform;
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.LabelDailyMenuItemName.layer.transform = CATransform3DScale(transform, 1.3, 1.3, 1.3);
                                 self.LabelDailyMenuItemName.layer.shadowColor = GetColor(0, 0, 0, 1).CGColor;
                                 self.LabelDailyMenuItemName.layer.shadowOpacity = 0.7;
                                 self.LabelDailyMenuItemName.layer.shadowOffset = CGSizeMake(0, 0);
                                 self.LabelDailyMenuItemName.layer.shadowRadius = 1;
                             }
                             completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint new = CGPointMake([longPressGestureRecognizer locationInView:self.scrollView].x + offsetFromCenter.x, [longPressGestureRecognizer locationInView:self.scrollView].y + offsetFromCenter.y);
            self.LabelDailyMenuItemName.center = new;
            [self changeLayerCenter:new];
            NSLog(@"Birthrate : %@",[itemNameLayer valueForKeyPath:@"emitterCells.center.birthRate"]);
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:10
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.LabelDailyMenuItemName.center = center;
                                 self.LabelDailyMenuItemName.layer.transform = CATransform3DIdentity;
                                 self.LabelDailyMenuItemName.alpha = 1;
                                 self.LabelDailyMenuItemName.layer.shadowColor = [UIColor clearColor].CGColor;
                                 self.LabelDailyMenuItemName.layer.shadowOpacity = 0;
                                 self.LabelDailyMenuItemName.layer.shadowOffset = CGSizeMake(0, 0);
                                 self.LabelDailyMenuItemName.layer.shadowRadius = 1;
                             }
                             completion:^(BOOL finished){
                                 CABasicAnimation* z = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                                 z.fromValue = [NSNumber numberWithFloat: 0];
                                 z.toValue = [NSNumber numberWithFloat: 1*2*M_PI];
                                 z.duration = 0.5;
                                 z.cumulative = YES;
                                 z.repeatCount = 1;
                                 z.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 z.removedOnCompletion = NO;
                                 z.fillMode = kCAFillModeForwards;
                                 z.delegate = self;
                                 
                                 [self.LabelDailyMenuItemName.layer addAnimation:z forKey:nil];
                             }];
            break;
        }
        default:
            break;
    }
}

-(void)addDoubleTapGestureOnItemLabel{
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuDoubleTap)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.LabelDailyMenuItemName addGestureRecognizer:doubleTapGesture];
}

-(void)handleMenuDoubleTap{
    NSLog(@"DoubleTap handled");
    if(!isFetchingMenu){
        NSLog(@"Already fetching menu...");
        [self fetchTodayMenu];
        [self fetchUserDetails];
    }
}

-(void)onOrderTouchDown:(UIButton *)button{
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.orderButton.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3);
                     }
                     completion:nil];
    buttonTopLayer.emitterPosition = CGPointMake(self.orderButton.center.x, self.orderButton.frame.origin.y);
    buttonBottomLayer.emitterPosition = CGPointMake(self.orderButton.center.x, self.orderButton.frame.origin.y + self.orderButton.bounds.size.height*1.3);
    
    [self changeButtonEmitterBirthrateTo:200];
}

-(void)onOrderTouchCancel:(UIButton *)button{
    self.orderButton.layer.shadowColor = [UIColor clearColor].CGColor;
    self.orderButton.layer.shadowOpacity = 0.5f;
    self.orderButton.layer.shadowOffset = CGSizeMake(0, 0);
    self.orderButton.layer.shadowRadius = 5;
    
    [self changeButtonEmitterBirthrateTo:0];
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.orderButton.layer.transform = CATransform3DIdentity;
                     }
                     completion:nil];
}

- (void)changeButtonEmitterBirthrateTo:(int)birthRate {
    [buttonBottomLayer setValue:@(birthRate) forKeyPath:@"emitterCells.bottom.birthRate"];
    [buttonTopLayer setValue:@(birthRate) forKeyPath:@"emitterCells.top.birthRate"];
}

-(void)changeLayerCenter:(CGPoint)newCenter{
    [itemNameLayer setValue:[NSValue valueWithCGPoint:newCenter] forKeyPath:@"emitterPosition"];
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
    [_leftEmitterLayer setValue:@((int) (rotation.x * 100)) forKeyPath:@"emitterCells.left.xAcceleration"];
    [_leftEmitterLayer setValue:@((int) -(rotation.y * 100)) forKeyPath:@"emitterCells.left.yAcceleration"];
    
    [_rightEmitterLayer setValue:@((int) (rotation.x * 100)) forKeyPath:@"emitterCells.right.xAcceleration"];
    [_rightEmitterLayer setValue:@((int) -(rotation.y * 100)) forKeyPath:@"emitterCells.right.yAcceleration"];
}

- (void)initShadows {
    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);
    
    self.whiteShadow = [[NSShadow alloc] init];
    self.whiteShadow.shadowBlurRadius = 3.0;
    self.whiteShadow.shadowColor = GetColor(256, 256, 256, 1);
    self.whiteShadow.shadowOffset = CGSizeMake(0, 0);
    
    self.redShadow = [[NSShadow alloc] init];
    self.redShadow.shadowBlurRadius = 3.0;
    self.redShadow.shadowColor = [UIColor redColor];
    self.redShadow.shadowOffset = CGSizeMake(0, 0);
    
    self.greenShadow = [[NSShadow alloc] init];
    self.greenShadow.shadowBlurRadius = 3.0;
    self.greenShadow.shadowColor = GetColor(50, 193, 92, 1);
    self.greenShadow.shadowOffset = CGSizeMake(0, 0);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [self fetchUserDetails];
    aajCenter = CGPointMake(self.LabelDailyMenuItemName.center.x, self.LabelDailyMenuItemName.center.y - 95);
    NSLog(@"LOCATION : %f. %f",aajCenter.x, aajCenter.y);
}

- (void)fetchUserDetails {
    NSString *usernameURL = [NSString stringWithFormat:keyURLUserAuth, _userName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:usernameURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self enableUserInput];
             [self changeEmitterBirthrateTo:0];
             BOOL userExists = ![((NSNumber *)responseObject[keyUserId]) isEqualToNumber:@0];
             if(userExists){
                 [self setUserInfo:responseObject];
                 [self setUserInformation];
             }else{
                 NSString *response = (NSString *)responseObject[keyResponseMessage];
                 NSLog(@"Fetch User Detail response message: %@",response);
             }
             isFetchingMenu = NO;
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self enableUserInput];
             [self changeEmitterBirthrateTo:0];
             [self showError:error.localizedDescription];
             NSLog(@"Error fetching User Details : %@", error);
             isFetchingMenu = NO;
         }];
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

-(void)shouldChangeItemText:(BOOL)fetching{
    if(fetching){
        NSMutableAttributedString *itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"fetching today's menu"];
        if ([Utilities isiPad]) {
            [itemKaNaam addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:50] range:NSMakeRange(0, itemKaNaam.length)];
        }else{
            [itemKaNaam addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, itemKaNaam.length)];
        }
        [itemKaNaam addAttribute:NSShadowAttributeName value:self.whiteShadow range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSForegroundColorAttributeName value:GetColor(256, 256, 256, 1) range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:@-3.0f range:NSMakeRange(0, [itemKaNaam length])];
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0;
        animation.type = @"rippleEffect";
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
        [_LabelDailyMenuItemName setAttributedText:itemKaNaam];
        
    }else{
        _dailyMenuId = @0;
        _itemName = @"";
        _pricePerUnit = @0;
        
        NSMutableAttributedString *itemKaNaam = nil;
        
        itemKaNaam = [[NSMutableAttributedString alloc] initWithString:@"N / A"];
        [itemKaNaam addAttribute:NSShadowAttributeName value:self.whiteShadow range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSForegroundColorAttributeName value:GetColor(256, 256, 256, 1) range:NSMakeRange(0, itemKaNaam.length)];
        [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:@-3.0f range:NSMakeRange(0, [itemKaNaam length])];
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0;
        animation.type = @"rippleEffect";
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
        
        self.orderQuantityButton.userInteractionEnabled = NO;
        [self.orderQuantityButton setTitle:@"n/a" forState:UIControlStateNormal];
    }
}

- (void)fetchTodayMenu {
    isFetchingMenu = YES;
    if ([Utilities isiPad]) {
        [self changeEmitterBirthrateTo:300];
    }else{
        [self changeEmitterBirthrateTo:100];
    }
    [self shouldChangeItemText:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:keyURLDailyMenu
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self enableUserInput];
             [self changeEmitterBirthrateTo:0];
             BOOL itemExists = ![((NSNumber *)responseObject[keyMenuId]) isEqualToNumber:@1];
             if(itemExists){
                 [self setTodayMenu:responseObject];
             }else{
                 NSString *response = (NSString *)responseObject[keyResponseMessage];
                 [self showError:response];
             }
             isFetchingMenu = NO;
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self enableUserInput];
             [self changeEmitterBirthrateTo:0];
             [self showError:error.localizedDescription];
             isFetchingMenu = NO;
             NSLog(@"Error fetching Daily Menu : %@", error);
             [self shouldChangeItemText:NO];
             
         }];
}

- (void)setUpAnimations {
    _leftEmitterLayer = [CAEmitterLayer layer];
    //    _leftEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x - 160, self.LabelDailyMenuItemName.center.y+15);
    _leftEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x - self.view.bounds.size.width/2, self.LabelDailyMenuItemName.center.y);
    _leftEmitterLayer.emitterZPosition = 10.0;
    _leftEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _leftEmitterLayer.emitterShape = kCAEmitterLayerSphere;
    
    _rightEmitterLayer = [CAEmitterLayer layer];
    //    _rightEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x + 160, self.LabelDailyMenuItemName.center.y+15);
    _rightEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x + self.view.bounds.size.width/2, self.LabelDailyMenuItemName.center.y);
    _rightEmitterLayer.emitterZPosition = 10.0;
    _rightEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _rightEmitterLayer.emitterShape = kCAEmitterLayerSphere;
    
    CAEmitterCell*leftEmitterCell = [CAEmitterCell emitterCell];
    leftEmitterCell.birthRate = 0;
    leftEmitterCell.emissionLongitude = M_PI*2;
    leftEmitterCell.lifetime = 3;
    if ([Utilities isiPad]) {
        leftEmitterCell.velocity = 200;
    }else{
        leftEmitterCell.velocity = 100;
    }
    leftEmitterCell.velocityRange = 40;
    leftEmitterCell.emissionRange = M_PI*8/180;
    leftEmitterCell.spin = 3;
    leftEmitterCell.spinRange = 6;
    leftEmitterCell.xAcceleration = 100;
    leftEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    leftEmitterCell.scale = 0.03;
    leftEmitterCell.alphaSpeed = -0.15;
    leftEmitterCell.color = GetColor(0, 0, 256, 0.5).CGColor;
    [leftEmitterCell setName:@"left"];
    
    CAEmitterCell *rightEmitterCell = [CAEmitterCell emitterCell];
    rightEmitterCell.birthRate = 0;
    rightEmitterCell.emissionLongitude = -M_PI*179/180;
    rightEmitterCell.lifetime = 3;
    if ([Utilities isiPad]) {
        rightEmitterCell.velocity = 200;
    }else{
        rightEmitterCell.velocity = 100;
    }
    rightEmitterCell.velocityRange = 40;
    rightEmitterCell.emissionRange = M_PI*8/180;
    rightEmitterCell.spin = 3;
    rightEmitterCell.spinRange = 6;
    rightEmitterCell.xAcceleration = -100;
    rightEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    rightEmitterCell.scale = 0.03;
    rightEmitterCell.alphaSpeed = -0.15;
    rightEmitterCell.color = GetColor(256, 0, 0, 0.5).CGColor;
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
    sparkleCell.color =GetColor(0, 0, 256, 0.5).CGColor;
    [sparkleCell setName:@"sparkle"];
    
    self.sparkleEmitterLayer.emitterCells = @[sparkleCell];
    [self.scrollView.layer addSublayer:self.sparkleEmitterLayer];
    
    
    buttonTopLayer = [CAEmitterLayer layer];
    buttonTopLayer.emitterPosition = CGPointMake(self.orderButton.center.x, self.orderButton.frame.origin.y);
    buttonTopLayer.emitterZPosition = -10.0;
    buttonTopLayer.emitterSize = CGSizeMake(self.orderButton.bounds.size.width, 1);
    buttonTopLayer.emitterShape = kCAEmitterLayerLine;
    
    CAEmitterCell*topCell = [CAEmitterCell emitterCell];
    topCell.birthRate = 0;
    topCell.lifetime = 1;
    topCell.emissionLongitude = -M_PI*(1/2);
    topCell.velocity = 60;
    topCell.velocityRange = 40;
    topCell.emissionRange = M_PI*(10/180);
    topCell.spin = 3;
    topCell.spinRange = 6;
    topCell.yAcceleration = 50;
    topCell.xAcceleration = 0;
    topCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    topCell.scale = 0.03;
    topCell.alphaSpeed = -0.30;
    topCell.color =GetColor(256, 256, 256, 0.5).CGColor;
    [topCell setName:@"top"];
    
    buttonTopLayer.emitterCells = @[topCell];
    [self.scrollView.layer addSublayer:buttonTopLayer];
    
    buttonBottomLayer = [CAEmitterLayer layer];
    buttonBottomLayer.emitterPosition = CGPointMake(self.orderButton.center.x, self.orderButton.frame.origin.y + self.orderButton.bounds.size.height);
    buttonBottomLayer.emitterZPosition = -10.0;
    buttonBottomLayer.emitterSize = CGSizeMake(self.orderButton.bounds.size.width, 1);;
    buttonBottomLayer.emitterShape = kCAEmitterLayerLine;
    
    CAEmitterCell*bottomCell = [CAEmitterCell emitterCell];
    bottomCell.birthRate = 0;
    bottomCell.lifetime = 1;
    bottomCell.emissionLongitude = M_PI_2 + M_PI/2;
    bottomCell.velocity = 60;
    bottomCell.velocityRange = 40;
    bottomCell.emissionRange = M_PI*(10/180);
    bottomCell.spin = 3;
    bottomCell.spinRange = 6;
    bottomCell.yAcceleration = -50;
    bottomCell.xAcceleration = 0;
    bottomCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    bottomCell.scale = 0.03;
    bottomCell.alphaSpeed = -0.30;
    bottomCell.color =GetColor(256, 256, 256, 0.5).CGColor;
    [bottomCell setName:@"bottom"];
    
    buttonBottomLayer.emitterCells = @[bottomCell];
    
    [self.scrollView.layer addSublayer:buttonBottomLayer];
}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    if (birthRate == 0) {
        [self stopAccelerometerUpdates];
        
        _leftEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x - self.view.bounds.size.width/2, self.LabelDailyMenuItemName.center.y);
        [_leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
        [_leftEmitterLayer setValue:@0 forKeyPath:@"emitterCells.left.yAcceleration"];
        
        _rightEmitterLayer.emitterPosition = CGPointMake(self.LabelDailyMenuItemName.center.x + self.view.bounds.size.width/2, self.LabelDailyMenuItemName.center.y);
        [_rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
        [_rightEmitterLayer setValue:@0 forKeyPath:@"emitterCells.right.yAcceleration"];
        //        [self enableMotionEffect];
    }else{
        //        [self disableMotionEffect];
        [_leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
        [_rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startAccUpdates) userInfo:nil repeats:NO];
    }
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)styleStaticData {
    
    self.orderButton.backgroundColor = GetColor(256, 256, 256, 0.3);
    self.orderButton.layer.zPosition = 100;
    
    self.orderQuantityButton.layer.cornerRadius = 3;
    self.orderQuantityButton.backgroundColor = GetColor(256, 256, 256, 0.3);
    
    self.logoutButton.backgroundColor = GetColor(256, 256, 256, 0.3);
    self.logoutButton.layer.cornerRadius = 3;
    
    self.orderHistoryButton.backgroundColor = GetColor(256, 256, 256, 0.3);
    self.orderHistoryButton.layer.cornerRadius = 3;
    
    
    UIFont *font;
    
    if ([Utilities isiPad]) {
        font = [UIFont italicSystemFontOfSize:100];
        [self.shadow setShadowBlurRadius:7];
        self.orderQuantityButton.hidden = YES;
        self.orderQuantityButton.userInteractionEnabled = NO;
        self.orderButton.layer.cornerRadius = 10;
        self.orderHistoryButton.layer.cornerRadius = 10;
        self.logoutButton.layer.cornerRadius = 10;
    }else{
        font = [UIFont italicSystemFontOfSize:40];
    }
    
    NSMutableAttributedString *khanemein = [[NSMutableAttributedString alloc] initWithString:@"Aaj Khane Mein Kya Hai"];
    NSRange range = NSMakeRange(0, [khanemein length]);
    [khanemein addAttribute:NSShadowAttributeName value:self.shadow range:range];
    [khanemein addAttribute:NSFontAttributeName value:font range:range];
    [_aajKhaneMeinKyaHai setAttributedText:khanemein];
    
    
    aajTransform = self.LabelDailyMenuItemName.layer.transform;
    currentAajTransform = aajTransform;
    
    NSMutableAttributedString *userKaNaam = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi %@", _userName]];
    if (![Utilities isiPad]) {
        [userKaNaam addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, userKaNaam.length)];
    }
    [_LabelUserName setAttributedText:userKaNaam];
    
}

- (void)setUserInformation {
    _errorLabel.text = @"";
    _itemName = @"";
    NSString *name = _userInfo[keyUserName];
    _remainingBalance = _userInfo[keyBalance];
    _currentOrderNumber = @1;
    
    _userId = _userInfo[keyUserId];
    _todayTotalOrder = _userInfo[keyTodaysOrderQty];
    [_LabelTotalOrder setText:[_todayTotalOrder stringValue]];
    _userName = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
    
    NSMutableAttributedString *remainingBalanceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-",_remainingBalance]];
    NSRange range = NSMakeRange(0, remainingBalanceString.length);
    if([_remainingBalance compare:@0] == NSOrderedAscending ){
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    }else{
        [remainingBalanceString addAttribute:NSShadowAttributeName value:self.greenShadow range:range];
        [remainingBalanceString addAttribute:NSForegroundColorAttributeName value:GetColor(50, 193, 92, 1) range:range];
    }
    
    if ([Utilities isiPad]) {
        [remainingBalanceString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, remainingBalanceString.length)];
    }else{
        [remainingBalanceString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, remainingBalanceString.length)];
    }
    
    [_LabelRemainingBalance setAttributedText:remainingBalanceString];
    
    
}

- (void)setRandomBackgroundImage {
    if (isSettingBackground) {
        NSLog(@"Already setting the background.....");
        return;
    }
    
    NSLog(@"Setting the background");
    isSettingBackground = YES;
    
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
    if (firstStart) {
        [_backgroundImageView setImage:uiImage];
    }
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.spiderlogic.Byte2Eat", NULL);
    dispatch_async(queue, ^{
        __block UIImage *image = [uiImage applyLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_backgroundImageView
                              duration:1.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [_backgroundImageView setImage:image];
                            } completion:^(BOOL finished){
                                isSettingBackground = NO;
                                firstStart = NO;
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
    return [NSString stringWithFormat:@"%li",row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_pricePerUnit && ![_pricePerUnit  isEqual: @0]) {
        [self updateCurrentOrderTo:@(row+1)];
    }
}

-(void)updateCurrentOrderTo:(NSNumber *)total{
    _currentOrderNumber = total;
    
    CABasicAnimation* z = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    z.fromValue = [NSNumber numberWithFloat: 0];
    z.toValue = [NSNumber numberWithFloat: 1*2*M_PI];
    z.duration = 0.5;
    z.cumulative = YES;
    z.repeatCount = 1;
    z.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    z.removedOnCompletion = NO;
    z.fillMode = kCAFillModeForwards;
    z.delegate = self;
    
    CATransition *t = [CATransition animation];
    t.duration = 0.5;
    t.type = kCATransitionFade;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *g = [CAAnimationGroup animation];
    [g setAnimations:@[t,z]];
    [g setDuration:0.5f];
    
    [self.orderQuantityButton.layer addAnimation:g forKey:nil];
    [self.orderQuantityButton setTitle:[NSString stringWithFormat:@"%@",_currentOrderNumber] forState:UIControlStateNormal];
    
    [_sparkleEmitterLayer setEmitterPosition:_LabelTotalCost.center];
    [_sparkleEmitterLayer setValue:@300 forKeyPath:@"emitterCells.sparkle.birthRate"];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTotalCost:) userInfo:nil repeats:NO];
}

- (void)updateTotalCost:(NSTimer *)timer {
    NSMutableAttributedString *totalCostString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %li/-",[_pricePerUnit integerValue] * [_currentOrderNumber integerValue]]];
    [totalCostString addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, totalCostString.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [_LabelTotalCost.layer addAnimation:animation forKey:nil];
    [_LabelTotalCost setAttributedText:totalCostString];
    
    [_sparkleEmitterLayer setValue:@0 forKeyPath:@"emitterCells.sparkle.birthRate"];
    [timer invalidate];
}

- (void)setTodayMenu:(NSDictionary *)dictionary {
    _dailyMenuId = dictionary[keyMenuId];
    _itemName = dictionary[keyItemName];
    _pricePerUnit = (NSNumber *)dictionary[keyItemPrice];
    
    
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
    [itemKaNaam addAttribute:NSForegroundColorAttributeName value:GetColor(256, 256, 256, 1) range:NSMakeRange(0, itemKaNaam.length)];
    [itemKaNaam addAttribute:NSStrokeWidthAttributeName value:@-3.0f range:NSMakeRange(0, [itemKaNaam length])];
    CATransition *animation = [CATransition animation];
    animation.duration = 2.0;
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromTop;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_LabelDailyMenuItemName.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_LabelDailyMenuItemName setAttributedText:itemKaNaam];
    
    NSString *itemPriceText=nil;
    NSString *totalCostText=nil;
    
    if (_pricePerUnit && ![_pricePerUnit  isEqual: @0]) {
        itemPriceText = [NSString stringWithFormat:@"Rs %@/-",dictionary[keyItemPrice]];
        totalCostText = [NSString stringWithFormat:@"Rs %li/-", [_pricePerUnit integerValue] * [_currentOrderNumber integerValue]];
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
    shadow.shadowColor = GetColor(256, 256, 256, 0.7);
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    
    NSMutableAttributedString *error = [[NSMutableAttributedString alloc] initWithString:response];
    [error addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, error.length)];
    [error addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, error.length)];
    if ([Utilities isiPad]) {
        [error addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Baskerville-SemiBoldItalic" size:25] range:NSMakeRange(0, error.length)];
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

- (void)disableUserInput{
    [self.OrderNumberPicker setUserInteractionEnabled:NO];
}

- (void)postOrderRequest {
    
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    order[@"Quantity"] = _currentOrderNumber;
    order[keyUserId] = _userId;
    order[@"DailyMenuid"] = _dailyMenuId;
    order[@"DeviceInfo"] = @"iPhone";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:keyURLPostOrder
       parameters:order
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *response = (NSString *) responseObject[keyResponseMessage];
              NSNumber *boolValue = (NSNumber *)responseObject[keyBoolValue];
              
              if([boolValue boolValue]){
                  [self updateCurrentOrderTo:@(1)];
                  [self.OrderNumberPicker selectRow:0 inComponent:0 animated:YES];
                  [self goToThankYouScreen];
              }else{
                  [self showError:response];
              }
              [self enableUserInput];
              [self changeEmitterBirthrateTo:0];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self enableUserInput];
              [self changeEmitterBirthrateTo:0];
              NSLog(@"Error posting Order  : %@",error.localizedDescription);
          }];
}

- (IBAction)onOrder:(UIButton *)sender {
    if (_dailyMenuId && ![_dailyMenuId isEqualToNumber:@0]) {
        NSString *message = [NSString stringWithFormat:@"Toda's Order Summary \n\n Earlier Order Qty : %@ \nCurrent Order Qty : %@\n-------------------------------\nTotal order Qty: %u", _todayTotalOrder, _currentOrderNumber, [_todayTotalOrder unsignedIntValue] + [_currentOrderNumber unsignedIntValue]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OrderSummary"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert setTag:keyAlertOrderConfirm];
        [alert show];
        
        
        if ([Utilities isiPad]) {
            [self changeEmitterBirthrateTo:300];
        }else{
            [self changeEmitterBirthrateTo:100];
        }
        [self disableUserInput];
    }else{
        [self showError:@"Nothing in menu today. Try refreshing."];
    }
}
- (IBAction)onOrderHistory:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderHistoryScreen"];
    //    modal = [storyboard instantiateViewControllerWithIdentifier:@"IDOrderHistoryCollectionScreen"];
    //    AppDelegateAccessor.settingsInteractionController = [[InteractiveTransitionController alloc] init];
    modal.transitioningDelegate = self;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    [modal setUser:_userName];
    [self presentViewController:modal animated:YES completion:nil];
    
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
                             [self.OrderNumberPicker setAlpha:0];
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


- (void)goToThankYouScreen {
    [self fetchUserDetails];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ThanksViewController *thanksViewController = [storyboard instantiateViewControllerWithIdentifier:@"IDThankYouController"];
    thanksViewController.transitioningDelegate = self;
    thanksViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:thanksViewController animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.appearing = YES;
    self.transitionManager.cornerRadius = 5;
    self.transitionManager.scaleFactor = 1;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.appearing = NO;
    return self.transitionManager;
}

//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//
//    if(AppDelegateAccessor.settingsInteractionController){
//        [AppDelegateAccessor.settingsInteractionController prepareTransitionController:presented];
//    }
//
//    self.transitionManager.reverse = NO;
//    return self.transitionManager;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    self.transitionManager.reverse = YES;
//    return self.transitionManager;
//}
//
//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return AppDelegateAccessor.settingsInteractionController && AppDelegateAccessor.settingsInteractionController.interactionInProgress ? AppDelegateAccessor.settingsInteractionController : nil;
//}


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
