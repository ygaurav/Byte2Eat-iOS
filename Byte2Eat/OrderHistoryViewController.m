
#import "OrderHistoryViewController.h"
#import "Constants.h"
#import "Order.h"
#import "OrderHistoryCell.h"
#import "AppDelegate.h"
#import "OrderViewModel.h"
#import "Utilities.h"

@implementation OrderHistoryViewController {
    NSString *userName;
    BOOL isFetchingHistory;
    NSMutableArray *orderHistory;
    CAEmitterLayer *_leftEmitterLayer;
    CAEmitterLayer *_rightEmitterLayer;
    NSMutableArray *newerData;
    NSMutableData *totalData;
}

@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    orderHistory = [[NSMutableArray alloc] init];

    [self setData];
    [self setUpAnimations];

    self.managedObjectContext = [Utilities getManagedObjectContext];

    orderHistory = [self mapFromManagedObject:[[self getSavedOrderHistory] mutableCopy]];
    NSLog(@"Saved Order count : %u", orderHistory.count);
}

- (NSMutableArray *)mapFromManagedObject:(NSMutableArray *)savedOrders {
    NSMutableArray *viewModelArray = [[NSMutableArray alloc] initWithCapacity:savedOrders.count];

    if (savedOrders.count == 0) return viewModelArray;

    for (Order *order in savedOrders) {
        OrderViewModel *model = [[OrderViewModel alloc] init];
        model.orderDate = order.orderDate;
        model.itemName = order.itemName;
        model.displayOrder = order.displayOrder;
        model.quantity = order.quantity;
        model.price = order.price;
        [viewModelArray addObject:model];
    }
    return viewModelArray;
}

- (NSArray *)getSavedOrderHistory {
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;

    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    // Returning Fetched Records
    return fetchedRecords;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setData {

    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);
    self.operationLabel.text = @"";


    NSShadow *blueShadow = [[NSShadow alloc] init];
    blueShadow.shadowColor = [UIColor colorWithRed:102 / 256.0 green:153 / 256.0 blue:255 / 256.0 alpha:0.5];
    blueShadow.shadowOffset = CGSizeMake(0, 0);
    blueShadow.shadowBlurRadius = 3.0;

    self.doneButton.backgroundColor = [UIColor colorWithRed:102 / 256.0 green:153 / 256.0 blue:255 / 256.0 alpha:.6];
    NSMutableAttributedString *doneButton = [[NSMutableAttributedString alloc] initWithString:@"Done"];
    [doneButton addAttribute:NSShadowAttributeName value:blueShadow range:NSMakeRange(0, doneButton.length)];
    [doneButton addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102 / 256.0 green:153 / 256.0 blue:255 / 256.0 alpha:1] range:NSMakeRange(0, doneButton.length)];
    [doneButton addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, doneButton.length)];
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
    newerData = [[NSMutableArray alloc] init];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:orderHistoryURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return orderHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderHistoryCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"OrderHistoryCell" forIndexPath:indexPath];
    OrderViewModel *order = [orderHistory objectAtIndex:(NSUInteger) indexPath.row];
    [self configureOrderHistoryCell:historyCell order:order];
    return historyCell;
}

- (void)configureOrderHistoryCell:(OrderHistoryCell *)historyCell order:(OrderViewModel *)order {
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

    NSMutableAttributedString *cost = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %i/-", [order.price integerValue] * [order.quantity integerValue]]];
    [cost addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, cost.length)];
    [cost addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, cost.length)];
    [cost addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, cost.length)];

    NSMutableAttributedString *date = [[NSMutableAttributedString alloc] initWithString:[self shortDateTimeString:order.orderDate]];
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

- (NSString *)shortDateTimeString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response - %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received %d bytes of data", [data length]);
    if (data != nil) {
        [totalData appendData:data];
    }
}

- (NSDate *)dateWithJSONString:(NSString *)stringDate {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    NSDate *date;
    date = [dateFormatter dateFromString:stringDate];
    return date;
}

- (BOOL)isThereAnyOrderHistory:(NSDictionary *)jsonArray {
//    NSUInteger integer = ((NSArray *) [jsonArray objectForKey:keyOrderHistory]).count;
//    NSLog(@"Order History Count %u",integer);
//    return integer > 0;
    return YES;
}

- (void)setOrderHistory:(NSDictionary *)dictionary {
    NSArray *orderHistoryDictionary = [dictionary objectForKey:keyOrderHistory];

    //TODO : If no prior order history save as is. If not, then check each order for their displayOrder.

    if (orderHistory.count == 0) {
        //TODO : Save every order in history
        NSLog(@"Saving order History for first time.");
        NSNumber *displayOrder = [NSNumber numberWithInt:0];
        for (NSDictionary *order in orderHistoryDictionary) {
            NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];

            NSManagedObjectContext *context = [self managedObjectContext];
            Order *orderObject = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Order"
                             inManagedObjectContext:context];
            orderObject.quantity = [order objectForKey:@"Quantity"];
            orderObject.itemName = [dailyMenu objectForKey:keyItemName];
            orderObject.price = [dailyMenu objectForKey:keyItemPrice];
            orderObject.orderDate = [self dateWithJSONString:(NSString *) [order objectForKey:@"OrderDate"]];
            orderObject.displayOrder = displayOrder;

            NSError *error;
            [context save:&error];
            if (error) {
                NSLog(@"Error occured : %@", error.localizedDescription);
            } else {
                displayOrder = [NSNumber numberWithInt:[displayOrder intValue] + 1];
                NSLog(@"Order saved : %@", [dailyMenu objectForKey:@"ItemName"]);
            }
        }
        [self insertTableData];
    } else {
        NSLog(@"Updates to order history");
        BOOL didRecordCountChange = orderHistoryDictionary.count > orderHistory.count || orderHistoryDictionary.count < orderHistory.count;
        if (orderHistoryDictionary.count > orderHistory.count) {
            NSLog(@"%i New records in order history.", orderHistoryDictionary.count - orderHistory.count);
        }
        if (orderHistoryDictionary.count < orderHistory.count) {
            NSLog(@"%i Records were deleted", orderHistory.count - orderHistoryDictionary.count);
        }
        NSLog(@"Record Count changed  %i", didRecordCountChange);
        didRecordCountChange = true;

        for (Order *order in [self getSavedOrderHistory]) {
            [[self managedObjectContext] deleteObject:order];
        }

        NSError *error = nil;
        [[self managedObjectContext] save:&error];
        if (error) {
            NSLog(@"Error deleting records - %@", error.localizedDescription);
        }

        if (didRecordCountChange) {
            NSNumber *displayOrder = [NSNumber numberWithChar:0];
            for (NSDictionary *order in orderHistoryDictionary) {
                NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];
                NSManagedObjectContext *context = [self managedObjectContext];
                Order *orderObject = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Order"
                                 inManagedObjectContext:context];

                orderObject.quantity = [order objectForKey:@"Quantity"];
                orderObject.itemName = [dailyMenu objectForKey:keyItemName];
                orderObject.price = [dailyMenu objectForKey:keyItemPrice];
                orderObject.orderDate = [self dateWithJSONString:(NSString *) [order objectForKey:@"OrderDate"]];
                orderObject.displayOrder = displayOrder;

                [context save:&error];
                if (error) {
                    NSLog(@"Error occured : %@", error.localizedDescription);
                } else {
                    displayOrder = [NSNumber numberWithInt:[displayOrder intValue] + 1];
                    NSLog(@"Order saved : %@", [dailyMenu objectForKey:@"ItemName"]);
                }
            }
            newerData = [[self getSavedOrderHistory] mutableCopy];

            NSArray *deletedRowIndexPaths = [self getDeletedIndexPathsFrom:newerData comparedTo:orderHistory];
            NSArray *insertedRowIndexPaths = [self getInsertedIndexPathsFrom:newerData comparedTo:orderHistory];
            NSArray *obsoleteRowIndexPaths = [self getObsoleteIndexPathsFrom:newerData comparedTo:orderHistory];

            orderHistory = [self mapFromManagedObject:newerData];
            NSLog(@"Deleted : %u, Inserted : %u", deletedRowIndexPaths.count, insertedRowIndexPaths.count);

            [self updateTableWithDeletedOrders:deletedRowIndexPaths insertedOrders:insertedRowIndexPaths reloadedOrders:obsoleteRowIndexPaths ];
        }
    }
}

- (NSArray *)getDeletedIndexPathsFrom:(NSMutableArray *)newerOrders comparedTo:(NSMutableArray *)olderData {
    NSDate *methodStart = [NSDate date];
    NSMutableArray *deletedIndexPaths = [[NSMutableArray alloc] init];
    NSLog(@"Checking for deletion Newer : %u, Older count : %u", newerOrders.count, olderData.count);
    for (OrderViewModel *older in olderData) {
        BOOL flag = YES;
        for (Order *order in newerOrders) {
            NSComparisonResult result = [order.orderDate compare:older.orderDate];
            if (result == NSOrderedSame) {
                NSLog(@" already there, dont delete %@ - %@", older.itemName, older.orderDate);
                flag = NO;
                break;
            }
        }
        if (flag) {
            NSLog(@"Deleted - Display Order : %@, Item : %@", older.displayOrder, older.itemName);
            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:[older.displayOrder integerValue] inSection:0]];
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"Delete executionTime = %f", executionTime);
    return deletedIndexPaths;
}

- (NSArray *)getInsertedIndexPathsFrom:(NSMutableArray *)newerOrders comparedTo:(NSMutableArray *)olderData {
    NSDate *methodStart = [NSDate date];
    NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] init];

    for (Order *order in newerOrders) {
        BOOL flag = YES;
        for (OrderViewModel *older in olderData) {
            if ([order.orderDate compare:older.orderDate] == NSOrderedSame) {
                NSLog(@"is not new, dont insert , %@ - %@ ", order.itemName, order.orderDate);
                flag = NO;
                break;
            }
        }
        if (flag) {
            NSLog(@"Inserted - Display Order : %@, Item : %@", order.displayOrder, order.itemName);
            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:[order.displayOrder integerValue] inSection:0]];
        }
    }

    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"Inserted executionTime = %f", executionTime);
    return insertedIndexPaths;
}

-(NSArray *)getObsoleteIndexPathsFrom:(NSMutableArray *)newerOrders comparedTo:(NSMutableArray *)olderData{
    NSDate *methodStart = [NSDate date];
    NSMutableArray *obsoleteIndexPaths = [[NSMutableArray alloc] init];

    for (Order *order in newerOrders) {
        BOOL flag = NO;
        for (OrderViewModel *older in olderData) {
            if ([order.orderDate compare:older.orderDate] == NSOrderedSame) {
                if(![order.itemName isEqualToString:older.itemName] || [order.quantity compare:older.quantity] != NSOrderedSame){
                    NSLog(@"Is obsolete data, reload row , %@ - %@ ", order.itemName, order.orderDate);
                    flag = YES;
                    break;
                }
            }
        }
        if (flag) {
            NSLog(@"Reload row - Display Order : %@, Item : %@", order.displayOrder, order.itemName);
            [obsoleteIndexPaths addObject:[NSIndexPath indexPathForRow:[order.displayOrder integerValue] inSection:0]];
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"Obsolete executionTime = %f", executionTime);
    return obsoleteIndexPaths;
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
    CATransform3D rotation = CATransform3DMakeScale(.3, .3, .3);
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);

    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cell.layer.transform = CATransform3DIdentity;
                     } completion:nil];
}

- (void)insertTableData {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    orderHistory = [[self getSavedOrderHistory] mutableCopy];
    [self.tableView beginUpdates];
    [orderHistory enumerateObjectsUsingBlock:^(Order *order, NSUInteger index, BOOL *stop) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [array addObject:path];
    }];
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)updateTableWithDeletedOrders:(NSArray *)deleted insertedOrders:(NSArray *)inserted reloadedOrders:(NSArray *)reloaded {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView insertRowsAtIndexPaths:inserted withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView reloadRowsAtIndexPaths:reloaded withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    isFetchingHistory = NO;
    [self changeEmitterBirthrateTo:0];
    [self setTitleBack];

    NSError *error = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:totalData options:NSJSONReadingMutableContainers error:&error];
    BOOL userExists = ![((NSNumber *) [jsonArray objectForKey:keyUserId]) isEqualToNumber:[NSNumber numberWithInt:1]];

    if (error != nil) {
        NSLog(@"Error parsing JSON Data : %@", [[NSString alloc] initWithData:totalData encoding:NSUTF8StringEncoding]);
    }
    if (userExists) {
        if ([self isThereAnyOrderHistory:jsonArray]) {
            [self setOrderHistory:jsonArray];
        }
    } else {
        NSString *response = (NSString *) [jsonArray objectForKey:keyResponseMessage];
        [self showError:response];
        NSLog(@"%@", response);
    }
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
    [_leftEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.left.birthRate"];
    [_rightEmitterLayer setValue:[NSNumber numberWithInt:birthRate] forKeyPath:@"emitterCells.right.birthRate"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    isFetchingHistory = NO;
    [self changeEmitterBirthrateTo:0];
    [self setTitleBack];
    [self showError:error.localizedDescription];
    NSLog(@"Seriously what happend : %@", error.domain);
}


#pragma FetchedResultsController methods


#pragma FetchedResultController methods end


- (IBAction)onDoneTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUser:(NSString *)name {
    userName = name;
}
@end
