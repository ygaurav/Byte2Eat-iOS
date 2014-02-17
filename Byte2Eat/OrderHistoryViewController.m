//
//  OrderHistoryViewController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 09/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "OrderHistoryViewController.h"
#import "Constants.h"
#import "Order.h"
#import "OrderHistoryCell.h"
#import "AppDelegate.h"
#import "OrderViewModel.h"

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

- (void)viewDidLoad{
    [super viewDidLoad];
    orderHistory = [[NSMutableArray alloc] init];

    [self setData];
    [self setUpAnimations];

    AppDelegate* appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;

    orderHistory = [[self getSavedOrderHistory] mutableCopy];
    NSLog(@"Saved Order count : %u", orderHistory.count);

}

-(NSArray*)getSavedOrderHistory
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;

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
    blueShadow.shadowColor = [UIColor colorWithRed:102/256.0 green:153/256.0 blue:255/256.0 alpha:0.5];
    blueShadow.shadowOffset = CGSizeMake(0, 0);
    blueShadow.shadowBlurRadius = 3.0;

    self.doneButton.backgroundColor = [UIColor colorWithRed:102/256.0 green:153/256.0 blue:255/256.0 alpha:.6];
    NSMutableAttributedString *doneButton = [[NSMutableAttributedString alloc] initWithString:@"Done"];
    [doneButton addAttribute:NSShadowAttributeName value:blueShadow range:NSMakeRange(0, doneButton.length)];
    [doneButton addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/256.0 green:153/256.0 blue:255/256.0 alpha:1] range:NSMakeRange(0, doneButton.length)];
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

-(void)viewDidAppear:(BOOL)animated {
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

    [self.view.layer addSublayer:_leftEmitterLayer];
    [self.view.layer addSublayer:_rightEmitterLayer];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake){
        if (isFetchingHistory){
            NSLog(@"Shake detected. Already fetching history.");
            return;
        }else{
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

    NSString *orderHistoryURL = [NSString stringWithFormat:keyURLOrderHistory,userName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:orderHistoryURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return orderHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderHistoryCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"OrderHistoryCell" forIndexPath:indexPath];
    Order *order = [orderHistory objectAtIndex:(NSUInteger) indexPath.row];
    [self configureOrderHistoryCell:historyCell order:order];
    return historyCell;
}

- (void)configureOrderHistoryCell:(OrderHistoryCell *)historyCell order:(Order *)order {
    NSShadow *blueShadow = [[NSShadow alloc] init];
    UIColor *blueColor = [UIColor colorWithRed:102/256.0 green:153/256.0 blue:255/256.0 alpha:1];
    blueShadow.shadowColor = blueColor;
    blueShadow.shadowOffset = CGSizeMake(0, 0);
    blueShadow.shadowBlurRadius = 2.0;

    NSShadow *greenShadow = [[NSShadow alloc] init];
    greenShadow.shadowOffset = CGSizeMake(0, 0);
    greenShadow.shadowBlurRadius = 1.0;
    UIColor *green = [UIColor colorWithRed:131/256.0 green:204/256.0 blue:57/256.0 alpha:1];
    greenShadow.shadowColor = green;

    NSShadow *redShadow = [[NSShadow alloc] init];
    redShadow.shadowBlurRadius = 2.0;
    redShadow.shadowOffset = CGSizeMake(0, 0);
    UIColor *redColor = [UIColor colorWithRed:220/256.0 green:92/256.0 blue:75/256.0 alpha:1];
    redShadow.shadowColor = redColor;

    NSMutableAttributedString *itemName = [[NSMutableAttributedString alloc] initWithString:order.itemName];
    [itemName addAttribute:NSShadowAttributeName value:blueShadow range:NSMakeRange(0, itemName.length)];
    [itemName addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0, itemName.length)];
    [itemName addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, itemName.length)];

    NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@/-",order.price]] ;
    [price addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, price.length)];
    [price addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, price.length)];
    [price addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, price.length)];

    NSMutableAttributedString *quantity = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",order.quantity]] ;
    [quantity addAttribute:NSShadowAttributeName value:greenShadow range:NSMakeRange(0, quantity.length)];
    [quantity addAttribute:NSForegroundColorAttributeName value:green range:NSMakeRange(0, quantity.length)];
    [quantity addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, quantity.length)];

    NSMutableAttributedString *cost = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %i/-", [order.price integerValue]*[order.quantity integerValue]]] ;
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
    NSLog(@"Response - %@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received %d bytes of data",[data length]);
    if (data != nil) {
        [totalData appendData:data];
    }
}

- (NSDate*)dateWithJSONString:(NSString *)stringDate
{
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

    if(orderHistory.count == 0){
        //TODO : Save every order in history
        NSLog(@"Saving order History for first time.");
        NSNumber *displayOrder = [NSNumber numberWithInt:0];
        for(NSDictionary *order in orderHistoryDictionary){
            NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];

            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *orderObject = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Order"
                             inManagedObjectContext:context];
            [orderObject setValue:[order objectForKey:@"Quantity"] forKey:@"quantity"];
            [orderObject setValue:[dailyMenu objectForKey:@"ItemName"] forKey:@"itemName"];
            [orderObject setValue:[dailyMenu objectForKey:@"ItemPrice"] forKey:@"price"];
            [orderObject setValue:[self dateWithJSONString:(NSString *)[order objectForKey:@"OrderDate"]] forKey:@"orderDate"];
            [orderObject setValue:displayOrder forKey:@"displayOrder"];
            NSError *error;
            [context save:&error];
            if(error){
                NSLog(@"Error occured : %@",error.localizedDescription);
            }else{
                displayOrder =  [NSNumber numberWithInt:[displayOrder intValue] + 1];
                NSLog(@"Order saved : %@",[dailyMenu objectForKey:@"ItemName"]);
            }
        }
        [self insertTableData];
    }else{
        NSLog(@"Updates to order history");
        BOOL didRecordCountChange = orderHistoryDictionary.count > orderHistory.count || orderHistoryDictionary.count < orderHistory.count;
        if(orderHistoryDictionary.count > orderHistory.count){
            NSLog(@"%i New records in order history.", orderHistoryDictionary.count - orderHistory.count);
        }
        if(orderHistoryDictionary.count < orderHistory.count){
            NSLog(@"%i Records were deleted", orderHistory.count - orderHistoryDictionary.count);
        }
        NSLog(@"Record Count changed  %i", didRecordCountChange);
        didRecordCountChange = true;

        if(didRecordCountChange){
            NSNumber *displayOrder = [NSNumber numberWithChar:0];
            for(NSDictionary *order in orderHistoryDictionary){
                OrderViewModel *orderDict = [[OrderViewModel alloc] init];
                orderDict.quantity = [order objectForKey:@"Quantity"];
                orderDict.orderDate = [self dateWithJSONString:(NSString *)[order objectForKey:@"OrderDate"]];
                NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];
                orderDict.itemName = [dailyMenu objectForKey:@"ItemName"];
                orderDict.price = [dailyMenu objectForKey:@"ItemPrice"];
                if (![[dailyMenu objectForKey:@"ItemName"] isEqualToString:@"Bhel"]) {
                    [newerData addObject:orderDict];
                }
//                NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];
//
//                NSManagedObjectContext *context = [self managedObjectContext];
//                NSManagedObject *orderObject = [NSEntityDescription
//                        insertNewObjectForEntityForName:@"Order"
//                                 inManagedObjectContext:context];
//                [orderObject setValue:[order objectForKey:@"Quantity"] forKey:@"quantity"];
//                [orderObject setValue:[dailyMenu objectForKey:@"ItemName"] forKey:@"itemName"];
//                [orderObject setValue:[dailyMenu objectForKey:@"Price"] forKey:@"price"];
//                [orderObject setValue:[self dateWithJSONString:(NSString *)[order objectForKey:@"OrderDate"]] forKey:@"orderDate"];
//                [orderObject setValue:displayOrder forKey:@"displayOrder"];
//                NSError *error;
//                [context save:&error];
//                if(error){
//                    NSLog(@"Error occured : %@",error.localizedDescription);
//                }else{
//                    displayOrder =  [NSNumber numberWithInt:[displayOrder intValue] + 1];
//                    NSLog(@"Order saved : %@",[dailyMenu objectForKey:@"ItemName"]);
//                }
            }

            OrderViewModel *new = [[OrderViewModel alloc] init];
            new.quantity = [NSNumber numberWithInt:5];
            new.itemName = @"Burger";
            new.price = [NSNumber numberWithInt:25];
            new.orderDate = [self dateWithJSONString:@"2014-02-20T00:00:00"];
            [newerData insertObject:new atIndex:0];

            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:new];

            NSArray *deletedRowIndexPaths = [self getDeletedIndexPathsFrom:newerData comparedTo:orderHistory];
            NSArray *insertedRowIndexPaths = [self getInsertedIndexPathsFrom:newerData comparedTo:orderHistory];

            NSLog(@"Deleted : %u, Inserted : %u",deletedRowIndexPaths.count, insertedRowIndexPaths.count);
            [self updateTableWithDeleted:deletedRowIndexPaths insertedPaths:insertedRowIndexPaths insertedOrders:array ];
        }
    }
}

- (NSArray *)getDeletedIndexPathsFrom:(NSMutableArray *)newerOrders comparedTo:(NSMutableArray *)olderData {
    NSMutableArray *deletedIndexPaths = [[NSMutableArray alloc] init];

    for(Order *older in olderData){
        BOOL flag = YES;
        for(OrderViewModel *orderViewModel in newerOrders){
            NSComparisonResult result = [orderViewModel.orderDate compare:older.orderDate];
            if (result == NSOrderedSame) {
                flag = NO;
                break;
            }
        }
        if(flag){
            NSLog(@"Deleted - Display Order : %@, Item : %@", older.displayOrder, older.itemName);
            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:[older.displayOrder integerValue] inSection:0]];
        }
    }
    return deletedIndexPaths;
}

-(NSArray *)getInsertedIndexPathsFrom:(NSMutableArray *)newerOrders comparedTo:(NSMutableArray *)olderData{
    NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] init];

    for(OrderViewModel *newerOrderViewModel in newerOrders){
        BOOL flag = YES;
        for(Order *older in olderData){
            if([newerOrderViewModel.orderDate compare:older.orderDate] == NSOrderedSame){
                flag = NO;
                break;
            }
        }
        if(flag){
            newerOrderViewModel.displayOrder = [NSNumber numberWithInt:0];
            NSLog(@"Inserted - Display Order : %@, Item : %@", newerOrderViewModel.displayOrder, newerOrderViewModel.itemName);
            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:[newerOrderViewModel.displayOrder integerValue] inSection:0]];
        }
    }
    return insertedIndexPaths;
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

-(void) insertTableData{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    orderHistory = [[self getSavedOrderHistory] mutableCopy];
    [self.tableView beginUpdates];
    [orderHistory enumerateObjectsUsingBlock:^(Order *order, NSUInteger index, BOOL *stop){
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [array addObject:path];
    }];
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)updateTableWithDeleted:(NSArray *)deleted insertedPaths:(NSArray *)inserted insertedOrders:(NSArray *)orders {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    orderHistory = [[self getSavedOrderHistory] mutableCopy];
//    [self.tableView beginUpdates];
//    [orderHistory enumerateObjectsUsingBlock:^(Order *order, NSUInteger index, BOOL *stop){
//        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
//        [array addObject:path];
//    }];
//    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
//    [self.tableView endUpdates];

    for(NSIndexPath *path in deleted){
        NSLog(@"Deleted rows at :%i",path.row);
        [orderHistory removeObjectAtIndex:(NSUInteger) path.row];
    }

    for(OrderViewModel *order in orders){
        //TODO : add these viewModel in OrderHistory
        NSLog(@"Adding rows at : %@",order.itemName);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *orderObject = [NSEntityDescription
                insertNewObjectForEntityForName:@"Order"
                         inManagedObjectContext:context];
        [orderObject setValue:order.quantity forKey:@"quantity"];
        [orderObject setValue:order.itemName forKey:@"itemName"];
        [orderObject setValue:order.price forKey:@"price"];
        [orderObject setValue:order.orderDate forKey:@"orderDate"];
//        [orderObject setValue:displayOrder forKey:@"displayOrder"];
        NSError *error;
//        [context save:&error];
        if(error){
            NSLog(@"Error occured : %@",error.localizedDescription);
        }else{
//            displayOrder =  [NSNumber numberWithInt:[displayOrder intValue] + 1];
//            NSLog(@"Order saved : %@",[dailyMenu objectForKey:@"ItemName"]);
        }
        [orderHistory insertObject:orderObject atIndex:0];
    }


    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView insertRowsAtIndexPaths:inserted withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

- (void)showError:(NSString *)response {

    NSShadow *redShadow = [[NSShadow alloc] init];
    redShadow.shadowBlurRadius = 2.0;
    redShadow.shadowOffset = CGSizeMake(0, 0);
    UIColor *redColor = [UIColor colorWithRed:220/256.0 green:92/256.0 blue:75/256.0 alpha:1];
    redShadow.shadowColor = redColor;

    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Try again later.",response]];
    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSShadowAttributeName value:redShadow range:NSMakeRange(0, historyTitle.length)];
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:220/256.0 green:92/256.0 blue:75/256.0 alpha:1] range:NSMakeRange(0, historyTitle.length)];
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
    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:220/256.0 green:92/256.0 blue:75/256.0 alpha:1] range:NSMakeRange(0, historyTitle.length)];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_operationLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_operationLabel setAttributedText:historyTitle];
    [timer invalidate];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    isFetchingHistory = NO;
    [self changeEmitterBirthrateTo:0];
    [self setTitleBack];

    NSError *error = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:totalData options:NSJSONReadingMutableContainers error:&error];
    BOOL userExists = ![((NSNumber *)[jsonArray objectForKey:keyUserId]) isEqualToNumber:[NSNumber numberWithInt:1]];

    if(error != nil){
        NSLog(@"Error parsing JSON Data : %@", [[NSString alloc] initWithData:totalData encoding:NSUTF8StringEncoding]);
    }
    if(userExists){
        if([self isThereAnyOrderHistory:jsonArray]){
            [self setOrderHistory:jsonArray];
        }
    }else{
        NSString *response = (NSString *)[jsonArray objectForKey:keyResponseMessage];
        [self showError:response];
        NSLog(@"%@",response);
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


- (IBAction)onDoneTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUser:(NSString *)name {
    userName = name;
}
@end
