#import "OrderHistoryViewController.h"
#import "Constants.h"
#import "Order.h"
#import "OrderHistoryCell.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "TableViewCellWithButtons.h"

@interface OrderHistoryViewController () <ScrollingCellDelegate>
@end

@implementation OrderHistoryViewController {
    NSString *userName;
    BOOL isFetchingHistory;
    CAEmitterLayer *_leftEmitterLayer;
    CAEmitterLayer *_rightEmitterLayer;
    NSMutableData *totalData;
    NSDateFormatter *shortDateFormatter;
    NSDateFormatter *dateFromJSONFormatter;
    CGPoint touchCenter;
    CGRect initialFrame;
    UIView *topHalfSnapshot;
    UIView *bottomHalfSnapshot;
    UIView *fullSnapShot ;
    CATransform3D transform;
    BOOL isAscending;
    NSMutableDictionary *didDisplay;
    NSMutableArray *insertedIndexPaths;
    NSMutableArray *updatedIndexPaths;
    BOOL firstFetch;
    
    NSIndexPath *pinchedIndexPath;
    CGFloat initialPinchedHeight;
    NSMutableArray *rowHeights;
    NSMutableArray *rowColor;
}

@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

-(void)scrollingCellDidBeginPulling:(TableViewCellWithButtons *)cell{
    NSLog(@"Pulling !!");
}
-(void)scrollingCell:(TableViewCellWithButtons *)cell didChangePullOffset:(CGFloat)offset{
    
}
-(void)scrollingCellDidEndPulling:(TableViewCellWithButtons *)cell{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpDateFormatter];
    [self setData];
    [self setUpAnimations];
    isAscending = NO;
    firstFetch = YES;
    self.historyTitleLabel.layer.zPosition = 2000;
    [self setupGestureRecognizer];
    touchCenter = self.historyTitleLabel.center;
    initialFrame = self.view.frame;
    transform = CATransform3DIdentity;
    didDisplay = [[NSMutableDictionary alloc] init];
    insertedIndexPaths = [[NSMutableArray alloc] init];
    updatedIndexPaths = [[NSMutableArray alloc] init];
    rowHeights = [[NSMutableArray alloc]init];
    rowColor = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCellWithButtons" bundle:nil] forCellReuseIdentifier:@"scrollViewTableCell"];
    
    self.managedObjectContext = [Utilities getManagedObjectContext];
    
    NSError *error;
    if (![[self fetchedResultsController:isAscending ] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
//    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][0];
//    NSInteger count = [sectionInfo numberOfObjects];
//    if (count != 0) {
//        for (int i = 0; i < count; i++) {
//            rowHeights[i] = @60;
//            rowColor[i] = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:.5];
//        }
//    }
//    
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//    
//    [self.tableView addGestureRecognizer:pinchRecognizer];
//    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
//    return [rowHeights[indexPath.row] floatValue];
}

-(void) updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath *)indexPath{

    if (indexPath && indexPath.section != NSNotFound && indexPath.row != NSNotFound) {
        CGFloat newHeight;
        if(initialPinchedHeight*scale < 60){
            newHeight = 60;
        }else if(initialPinchedHeight*scale > 95){
            newHeight = 95;
        }else{
            newHeight = initialPinchedHeight*scale;
        }
        
        NSLog(@"Height : %f", newHeight);
        
        [self setHeight:@(newHeight) forRowAtIndexPath:indexPath];

        BOOL animationEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:animationEnabled];
    }
}

-(void)setHeight:(id)height forRowAtIndexPath:(NSIndexPath *)indexPath{
    rowHeights[indexPath.row] = height;
}

-(void)handlePinch:(UIPinchGestureRecognizer *)pinch{
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint pinchLocation = [pinch locationInView:self.tableView];
            pinchedIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
            initialPinchedHeight = [self tableView:self.tableView heightForRowAtIndexPath:pinchedIndexPath];
            [self updateForPinchScale:pinch.scale atIndexPath:pinchedIndexPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self updateForPinchScale:pinch.scale atIndexPath:pinchedIndexPath];
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            pinchedIndexPath = nil;
            initialPinchedHeight = 0;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            pinchedIndexPath = nil;
            initialPinchedHeight = 0;
            break;
        }
        default:
            break;
    }
}

- (void)setUpDateFormatter{
    shortDateFormatter = [[NSDateFormatter alloc] init];
    [shortDateFormatter setDateStyle:NSDateFormatterLongStyle];
    dateFromJSONFormatter = [[NSDateFormatter alloc] init];
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFromJSONFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFromJSONFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFromJSONFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (NSFetchedResultsController *)fetchedResultsController:(BOOL)ascending {

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
            entityForName:@"Order" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"orderDate" ascending:ascending];

    [fetchRequest setSortDescriptors:@[sort]];

//    [fetchRequest setFetchBatchSize:20];

    NSFetchedResultsController *theFetchedResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:managedObjectContext
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSArray *)getSavedOrderHistory {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;

    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    return fetchedRecords;
}

- (void)setData {
    self.operationLabel.text = @"";
    
    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);

    NSShadow *blueShadow = [[NSShadow alloc] init];
    blueShadow.shadowColor = [UIColor colorWithRed:102 / 256.0 green:153 / 256.0 blue:255 / 256.0 alpha:0.5];
    blueShadow.shadowOffset = CGSizeMake(0, 0);
    blueShadow.shadowBlurRadius = 3.0;

    NSMutableAttributedString *doneButton = [[NSMutableAttributedString alloc] initWithString:@"Done"];
    [doneButton addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, doneButton.length)];
    [doneButton addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, doneButton.length)];
    [doneButton addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22] range:NSMakeRange(0, doneButton.length)];
    [self.doneButton setAttributedTitle:doneButton forState:UIControlStateNormal];

    NSMutableAttributedString *history = [[NSMutableAttributedString alloc] initWithString:@"Order History"];
    NSRange range = NSMakeRange(0, [history length]);
    [history addAttribute:NSShadowAttributeName value:self.shadow range:range];
    [history addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:range];
    [_historyTitleLabel setAttributedText:history];

    _historyTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _historyTitleLabel.layer.shadowOpacity = 0.5;
    _historyTitleLabel.layer.shadowOffset = CGSizeMake(0, 0);
    _historyTitleLabel.layer.shadowRadius = 4;
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchOrderHistory:YES ];
}

- (void)setUpAnimations {
    _leftEmitterLayer = [CAEmitterLayer layer];
    _leftEmitterLayer.emitterPosition = CGPointMake(self.historyTitleLabel.center.x - 160, self.historyTitleLabel.center.y);
    _leftEmitterLayer.emitterZPosition = 10.0;
    _leftEmitterLayer.emitterSize = CGSizeMake(5, 5);
    _leftEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    _rightEmitterLayer = [CAEmitterLayer layer];
    _rightEmitterLayer.emitterPosition = CGPointMake(self.historyTitleLabel.center.x + 160, self.historyTitleLabel.center.y);
    _rightEmitterLayer.emitterZPosition = 10.0;
    _rightEmitterLayer.emitterSize = CGSizeMake(5, 30);
    _rightEmitterLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell *leftEmitterCell = [CAEmitterCell emitterCell];
    leftEmitterCell.birthRate = 0;
    leftEmitterCell.emissionLongitude = M_PI * 2;
    leftEmitterCell.lifetime = 2;
    leftEmitterCell.velocity = 100;
    leftEmitterCell.velocityRange = 40;
    leftEmitterCell.emissionRange = M_PI * 8 / 180;
    leftEmitterCell.spin = 3;
    leftEmitterCell.spinRange = 6;
    leftEmitterCell.xAcceleration = 100;
    leftEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    leftEmitterCell.scale = 0.03;
    leftEmitterCell.alphaSpeed = -0.12;
    leftEmitterCell.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
    [leftEmitterCell setName:@"left"];

    CAEmitterCell *rightEmitterCell = [CAEmitterCell emitterCell];
    rightEmitterCell.birthRate = 0;
    rightEmitterCell.emissionLongitude = -M_PI* 179 / 180;
    rightEmitterCell.lifetime = 2;
    rightEmitterCell.velocity = 100;
    rightEmitterCell.velocityRange = 40;
    rightEmitterCell.emissionRange = M_PI * 8 / 180;
    rightEmitterCell.spin = 3;
    rightEmitterCell.spinRange = 6;
    rightEmitterCell.xAcceleration = -100;
    rightEmitterCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    rightEmitterCell.scale = 0.03;
    rightEmitterCell.alphaSpeed = -0.12;
    rightEmitterCell.color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;
    [rightEmitterCell setName:@"right"];

    _leftEmitterLayer.emitterCells = @[leftEmitterCell];
    _rightEmitterLayer.emitterCells = @[rightEmitterCell];

    [self.view.layer addSublayer:_leftEmitterLayer];
    [self.view.layer addSublayer:_rightEmitterLayer];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if (isFetchingHistory) {
            NSLog(@"Shake detected. Already fetching history.");
            return;
        } else {
            NSLog(@"Shake detected. Refreshing history..");
            [self fetchOrderHistory:NO ];
        }
    }
}

- (void)fetchOrderHistory:(bool)isFirstFetch {
    isFetchingHistory = YES;
    [self changeEmitterBirthrateTo:100];
    totalData = [[NSMutableData alloc] init];

    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:@"fetching data..."];
    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:1 alpha:1] range:NSMakeRange(0, historyTitle.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_operationLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_operationLabel setAttributedText:historyTitle];

    NSString *orderHistoryURL = [NSString stringWithFormat:keyURLOrderHistory, userName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:orderHistoryURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             isFetchingHistory = NO;
             [self changeEmitterBirthrateTo:0];
             [self setTitleBack];
             
             BOOL userExists = ![((NSNumber *) responseObject[keyUserId]) isEqualToNumber:@1];
             
             if (userExists) {
                 [self setOrderHistory:responseObject];
             } else {
                 NSString *response = (NSString *) responseObject[keyResponseMessage];
                 [self showError:response];
                 NSLog(@"Response : %@", response);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             isFetchingHistory = NO;
             [self changeEmitterBirthrateTo:0];
             [self setTitleBack];
             [self showError:error.localizedDescription];
             NSLog(@"Error : %@", error.localizedDescription);
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][(NSUInteger) section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderHistoryCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"OrderHistoryCell" forIndexPath:indexPath];
    [self configureCell:historyCell atIndexPath:indexPath];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [historyCell addGestureRecognizer:tap];
//    TableViewCellWithButtons *historyCell = [tableView dequeueReusableCellWithIdentifier:@"scrollViewTableCell" forIndexPath:indexPath];
//    [self configCustomCell:historyCell atIndexPath:indexPath];
    return historyCell;
}


-(void)configCustomCell:(TableViewCellWithButtons *)cell atIndexPath:(NSIndexPath *)indexPath{
    Order *order = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.scrollDelegate = self;
    cell.testScrollView.showsHorizontalScrollIndicator = YES;
    cell.testScrollView.showsVerticalScrollIndicator = NO;
    cell.testScrollView.contentSize = CGSizeMake(CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
    cell.labelItemName.text = order.itemName;
    cell.labelOrderDate.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.testScrollView.backgroundColor = rowColor[indexPath.row];
}

-(void)handleTap:(UITapGestureRecognizer *)tap{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[tap locationInView:self.tableView]];

    CGFloat height = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    CGFloat newHeight;
    if (height < 70) {
        newHeight = 95;
        [self setHeight:@(95) forRowAtIndexPath:indexPath];
    }else{
        newHeight = 60;
        [self setHeight:@(60) forRowAtIndexPath:indexPath];
    }
    NSLog(@"Handle tap on %ld, old %f , new %f",(long)indexPath.row, height, newHeight);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Order *order = [_fetchedResultsController objectAtIndexPath:indexPath];
    OrderHistoryCell *historyCell = (OrderHistoryCell *) cell;

    NSShadow *blueShadow = [[NSShadow alloc] init];
    UIColor *blueColor = [UIColor colorWithRed:102 / 256.0 green:153 / 256.0 blue:255 / 256.0 alpha:1];
    blueShadow.shadowColor = blueColor;
    blueShadow.shadowOffset = CGSizeMake(0, 0);
    blueShadow.shadowBlurRadius = 2.0;

    NSShadow *greenShadow = [[NSShadow alloc] init];
    greenShadow.shadowOffset = CGSizeMake(0, 0);
    greenShadow.shadowBlurRadius = 1.0;
    UIColor *green = [UIColor colorWithRed:131 / 256.0 green:204 / 256.0 blue:57 / 256.0 alpha:1];
    greenShadow.shadowColor = green;

    NSShadow *redShadow = [[NSShadow alloc] init];
    redShadow.shadowBlurRadius = 2.0;
    redShadow.shadowOffset = CGSizeMake(0, 0);
    UIColor *redColor = [UIColor colorWithRed:220 / 256.0 green:92 / 256.0 blue:75 / 256.0 alpha:1];
    redShadow.shadowColor = redColor;

    NSMutableAttributedString *itemName = [[NSMutableAttributedString alloc] initWithString:order.itemName];
    [itemName addAttribute:NSShadowAttributeName value:blueShadow range:NSMakeRange(0, itemName.length)];
    [itemName addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0, itemName.length)];
    [itemName addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, itemName.length)];

    NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-", order.price]];
    [price addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, price.length)];
    [price addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, price.length)];
    [price addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, price.length)];

    NSMutableAttributedString *quantity = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", order.quantity]];
    [quantity addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, quantity.length)];
    [quantity addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, quantity.length)];
    [quantity addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, quantity.length)];

    NSMutableAttributedString *cost = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %li/-", [order.price integerValue] * [order.quantity integerValue]]];
    [cost addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, cost.length)];
    [cost addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, cost.length)];
    [cost addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, cost.length)];

    NSMutableAttributedString *date = [[NSMutableAttributedString alloc] initWithString:[shortDateFormatter stringFromDate:order.orderDate]];
    [date addAttribute:NSShadowAttributeName value:redShadow range:NSMakeRange(0, date.length)];
    [date addAttribute:NSForegroundColorAttributeName value:redColor range:NSMakeRange(0, date.length)];
    [date addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, date.length)];

    historyCell.labelItemName.attributedText = itemName;
    historyCell.labelItemPrice.attributedText = price;
    historyCell.labelOrderCost.attributedText = cost;
    historyCell.labelOrderQty.attributedText = quantity;
    historyCell.labelOrderDate.attributedText = date;
    
    historyCell.alpha = 0.3;

}

- (void)setOrderHistory:(NSDictionary *)dictionary {
    NSArray *orderHistoryDictionary = dictionary[keyOrderHistory];
    if ([_fetchedResultsController fetchedObjects].count == 0) {
        NSLog(@"Saving order History for first time.");
        NSNumber *displayOrder = @1;
        for (NSDictionary *order in orderHistoryDictionary) {
            NSDictionary *dailyMenu = order[@"DailyMenu"];

            Order *orderObject = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Order"
                             inManagedObjectContext:self.managedObjectContext];
            orderObject.quantity = order[@"Quantity"];
            orderObject.itemName = dailyMenu[keyItemName];
            orderObject.price = dailyMenu[keyItemPrice];
            orderObject.orderDate = [dateFromJSONFormatter dateFromString:(NSString *) order[@"OrderDate"]];
            orderObject.displayOrder = displayOrder;

            NSError *error;
            [(self.managedObjectContext) save:&error];
            if (error) {
                NSLog(@"Error occured : %@", error.localizedDescription);
            } else {
                displayOrder = @([displayOrder integerValue] + 1);
            }
        }
    } else {
        //Checking for deleted or updated records
        firstFetch = NO;
        for(Order *order in _fetchedResultsController.fetchedObjects){
            BOOL isDeleted = YES;
            for(NSDictionary *orderDict in orderHistoryDictionary){
                if([[dateFromJSONFormatter dateFromString:(NSString *) orderDict[@"OrderDate"]] compare:order.orderDate] == NSOrderedSame){
                    NSNumber *saved = order.quantity;
                    NSNumber *fetched = orderDict[@"Quantity"];
                    
                    if([saved compare:fetched] != NSOrderedSame){
                        NSLog(@"Saved Quantity %@  == %@ Fetched Quantity",order.quantity,orderDict[@"Quantity"]);
                        order.quantity = orderDict[@"Quantity"];
                    }
                    isDeleted = NO;
                    break;
                }
            }
            if(isDeleted){
                [self.managedObjectContext deleteObject:order];
            }
        }

        //Checking for inserted records
        for (NSDictionary *order in orderHistoryDictionary) {
            BOOL isNew = YES;
            for(Order *orderManagedObject in [_fetchedResultsController fetchedObjects]){
                if([[dateFromJSONFormatter dateFromString:(NSString *) order[@"OrderDate"]] compare:orderManagedObject.orderDate] == NSOrderedSame){
                    isNew = NO;
                    break;
                }
            }

            if(isNew){
                Order *orderObject = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Order"
                                 inManagedObjectContext:self.managedObjectContext];

                NSDictionary *dailyMenu = order[@"DailyMenu"];
                orderObject.quantity = order[@"Quantity"];
                orderObject.itemName = dailyMenu[keyItemName];
                orderObject.price = dailyMenu[keyItemPrice];
                orderObject.orderDate = [dateFromJSONFormatter dateFromString:(NSString *) order[@"OrderDate"]];
            }
        }
    }
    NSError *error;
    [(self.managedObjectContext) save:&error];
    if (error) {
        NSLog(@"Error occured : %@", error.localizedDescription);
    }
    [_fetchedResultsController performFetch:&error];
    NSLog(@"Count after save = %lu", (unsigned long)[_fetchedResultsController fetchedObjects].count);
    [self.managedObjectContext processPendingChanges];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Color flash for inserted cell
    if ([insertedIndexPaths containsObject:indexPath]) {
        cell.backgroundColor = [UIColor colorWithRed:180/256.0 green:250/256.0 blue:186/256.0 alpha:1];
        [UIView animateWithDuration:3
                         animations:^{
                             cell.backgroundColor = [UIColor whiteColor];
                         }
                         completion:^(BOOL finished){
                             [insertedIndexPaths removeObject:indexPath];
                         }];
    }
    
    //Color flash for updated cell
    if ([updatedIndexPaths containsObject:indexPath]) {
        OrderHistoryCell *orderCell = (OrderHistoryCell *)cell;
        orderCell.labelOrderQty.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
//        orderCell.labelOrderQty.layer.transform = CATransform3DMakeScale(4, 4, 4);
        [UIView animateWithDuration:2
                              delay:0
             usingSpringWithDamping:0.1
              initialSpringVelocity:3
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             orderCell.labelOrderQty.layer.transform = CATransform3DIdentity;
                         }
                         completion:nil];
        
        cell.backgroundColor = [UIColor colorWithRed:250/256.0 green:244/256.0 blue:162/256.0 alpha:1];
        [UIView animateWithDuration:3
                         animations:^{
                             cell.backgroundColor = [UIColor whiteColor];
                         }
                         completion:^(BOOL finished){
                             [updatedIndexPaths removeObject:indexPath];
                         }];
    }
    
    // Disable animation for already shown cells
//    if (![didDisplay objectForKey:indexPath]) {
    if(true){
    

        CATransform3D rotation = CATransform3DMakeScale(.3, .3, .3);
        cell.layer.transform = rotation;
        cell.layer.anchorPoint = CGPointMake(0.5, 0.5);

        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:5
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             cell.layer.transform = CATransform3DIdentity;
                         } completion:nil];
        [didDisplay setObject:@YES forKey:indexPath];
    }
}

- (void)showError:(NSString *)response {

    NSShadow *redShadow = [[NSShadow alloc] init];
    redShadow.shadowBlurRadius = 2.0;
    redShadow.shadowOffset = CGSizeMake(0, 0);
    UIColor *redColor = [UIColor colorWithRed:220 / 256.0 green:92 / 256.0 blue:75 / 256.0 alpha:1];
    redShadow.shadowColor = redColor;

    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Try again later.", response]];
    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSShadowAttributeName value:redShadow range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:220 / 256.0 green:92 / 256.0 blue:75 / 256.0 alpha:1] range:NSMakeRange(0, historyTitle.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_operationLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_operationLabel setAttributedText:historyTitle];

    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(removeErrorMessage:) userInfo:nil repeats:NO];
}

- (void)removeErrorMessage:(NSTimer *)timer {
    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:220 / 256.0 green:92 / 256.0 blue:75 / 256.0 alpha:1] range:NSMakeRange(0, historyTitle.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_operationLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_operationLabel setAttributedText:historyTitle];
    [timer invalidate];
}

- (void)setTitleBack {
    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:1 alpha:1] range:NSMakeRange(0, historyTitle.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_operationLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_operationLabel setAttributedText:historyTitle];
}

- (void)changeEmitterBirthrateTo:(int)birthRate {
    [_leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
    [_rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
}

#pragma mark FetchedResultsController methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [didDisplay removeAllObjects];
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationRight];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;

    switch (type) {

            
        case NSFetchedResultsChangeInsert:
            if (!firstFetch) {
                [insertedIndexPaths addObject:newIndexPath];
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationLeft];
            }else{
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationTop ];
            }
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationRight];
            break;

        case NSFetchedResultsChangeUpdate:
            [updatedIndexPaths addObject:newIndexPath];
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationMiddle];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark IBActions

- (IBAction)onDoneTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTopButtonTap:(UIButton *)sender {
//    [didDisplay removeAllObjects];
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 20, 310) animated:NO];
//    self.fetchedResultsController = nil;
//    NSError *error;
//    if (![[self fetchedResultsController:!isAscending ] performFetch:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//    }
//
//    [self.tableView reloadData];
//    isAscending = !isAscending;
    
//    NSMutableArray *array = [[_fetchedResultsController fetchedObjects] mutableCopy];
//
//    for(int j = 0; j <array.count; j++){
//        Order *order = (Order *) array[(NSUInteger) j];
//        (order).displayOrder = @(array.count - j);
//    }
//
//    [self.managedObjectContext save:nil];

}

- (IBAction)onRefreshTap:(UIButton *)sender {
    [self fetchOrderHistory:NO];
}

- (void)setUser:(NSString *)name {
    userName = name;
}

#pragma mark Folding animation code

-(void)setupGestureRecognizer{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [pan setMaximumNumberOfTouches:1];
    [pan setMinimumNumberOfTouches:1];
    [self.historyTitleLabel addGestureRecognizer:pan];
}

-(void)onPanGesture:(UIPanGestureRecognizer *)panRecognizer{
    CGPoint touch = [panRecognizer translationInView:self.view];
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Began Gesture : %f , %f", touch.x, touch.y);
        fullSnapShot = [self.view snapshotViewAfterScreenUpdates:NO];
        
        CGRect topHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                        CGRectGetMinY(initialFrame),
                                        CGRectGetWidth(initialFrame),
                                        CGRectGetHeight(initialFrame) / 2.0);
        
        topHalfSnapshot = [fullSnapShot resizableSnapshotViewFromRect:topHalfRect
                                                           afterScreenUpdates:NO
                                                                withCapInsets:UIEdgeInsetsZero];
        
        CGRect bottomHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                           CGRectGetMidY(initialFrame),
                                           CGRectGetWidth(initialFrame),
                                           CGRectGetHeight(initialFrame) / 2.0);
        
        bottomHalfSnapshot = [fullSnapShot resizableSnapshotViewFromRect:bottomHalfRect
                                                              afterScreenUpdates:NO
                                                                   withCapInsets:UIEdgeInsetsZero];
        [self.tableView setAlpha:0];
        [self.onSortingButton setAlpha:0];
        [self.historyTitleLabel setAlpha:0];

        [self.view addSubview:topHalfSnapshot];
        bottomHalfSnapshot.center = CGPointMake(bottomHalfSnapshot.center.x, bottomHalfSnapshot.center.y + bottomHalfSnapshot.bounds.size.height);
        [self.view addSubview:bottomHalfSnapshot];
//        [self.view insertSubview:bottomHalfSnapshot belowSubview:topHalfSnapshot];

        topHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 1);
        topHalfSnapshot.layer.position = [self getLayerPosition:topHalfSnapshot.layer];
        transform.m34 = 1.0/-1000;
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat y = MIN(0, -touch.y);
        CGFloat angle = M_PI_2*(y/160);
        topHalfSnapshot.layer.transform = CATransform3DRotate(transform, angle, 1, 0, 0);
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Ended Gesture : %f , %f", touch.x, touch.y);
        
        [UIView animateWithDuration:0.5
                         animations:^{
                            topHalfSnapshot.layer.transform = CATransform3DIdentity;
                         } completion:^(BOOL finished){
                             [topHalfSnapshot removeFromSuperview];
                             [bottomHalfSnapshot removeFromSuperview];
                             [self.tableView setAlpha:1];
                             [self.historyTitleLabel setAlpha:1];
                             [self.onSortingButton setAlpha:1];
                         }];
//        [bottomHalfSnapshot removeFromSuperview];
    }
}

-(CGPoint)getLayerPosition:(CALayer *)layer{
    CGFloat ax = layer.anchorPoint.x;
    CGFloat ay = layer.anchorPoint.y;
    CGPoint p = layer.position;
    CGFloat x,y;
    CGFloat width = layer.bounds.size.width;
    CGFloat height = layer.bounds.size.height;
    
    x = p.x - width*(.5 - ax);
    y = p.y + height*(ay - .5);
    
    return CGPointMake(x, y);
}


@end
