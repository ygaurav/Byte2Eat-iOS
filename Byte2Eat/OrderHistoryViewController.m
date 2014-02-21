#import "OrderHistoryViewController.h"
#import "Constants.h"
#import "Order.h"
#import "OrderHistoryCell.h"
#import "AppDelegate.h"
#import "Utilities.h"

@implementation OrderHistoryViewController {
    NSString *userName;
    BOOL isFetchingHistory;
    CAEmitterLayer *_leftEmitterLayer;
    CAEmitterLayer *_rightEmitterLayer;
    NSMutableData *totalData;
}

@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setData];
    [self setUpAnimations];

    self.managedObjectContext = [Utilities getManagedObjectContext];


    NSError *error;
    if (![[self fetchedResultsController:NO ] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
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
            initWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:20];

    NSFetchedResultsController *theFetchedResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                           cacheName:@"Root"];
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
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:(NSUInteger) section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderHistoryCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"OrderHistoryCell" forIndexPath:indexPath];
    [self configureCell:historyCell atIndexPath:indexPath];
    return historyCell;
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

- (void)setOrderHistory:(NSDictionary *)dictionary {
    NSArray *orderHistoryDictionary = [dictionary objectForKey:keyOrderHistory];
    if ([_fetchedResultsController fetchedObjects].count == 0) {
        NSLog(@"Saving order History for first time.");
        NSNumber *displayOrder = [[NSNumber alloc] initWithInt:1];
        for (NSDictionary *order in orderHistoryDictionary) {
            NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];

            Order *orderObject = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Order"
                             inManagedObjectContext:self.managedObjectContext];
            orderObject.quantity = [order objectForKey:@"Quantity"];
            orderObject.itemName = [dailyMenu objectForKey:keyItemName];
            orderObject.price = [dailyMenu objectForKey:keyItemPrice];
            orderObject.orderDate = [self dateWithJSONString:(NSString *) [order objectForKey:@"OrderDate"]];
            orderObject.displayOrder = displayOrder;

            NSError *error;
            [(self.managedObjectContext) save:&error];
            if (error) {
                NSLog(@"Error occured : %@", error.localizedDescription);
            } else {
                displayOrder = [NSNumber numberWithInt:[displayOrder integerValue] + 1];
                NSLog(@"Order saved : %@", [dailyMenu objectForKey:@"ItemName"]);
            }
        }
    } else {
        //Checking for deleted or updated records
        for(Order *order in _fetchedResultsController.fetchedObjects){
            BOOL isDeleted = YES;
            for(NSDictionary *orderDict in orderHistoryDictionary){
                if([[self dateWithJSONString:(NSString *) [orderDict objectForKey:@"OrderDate"]] compare:order.orderDate] == NSOrderedSame){
                    if(order.quantity != [orderDict objectForKey:@"Quantity"]){
                        NSLog(@"Updated %@, from %@ to %@", order.itemName, order.quantity,[orderDict objectForKey:@"Quantity"] );
                        order.quantity = [orderDict objectForKey:@"Quantity"];
                    }
                    isDeleted = NO;
                    break;
                }
            }
            if(isDeleted){
                NSLog(@"Deleted : %@", order.itemName);
                [self.managedObjectContext deleteObject:order];
            }
        }

        //Checking for inserted records
        for (NSDictionary *order in orderHistoryDictionary) {
            BOOL isNew = YES;
            for(Order *orderManagedObject in [_fetchedResultsController fetchedObjects]){
                if([[self dateWithJSONString:(NSString *) [order objectForKey:@"OrderDate"]] compare:orderManagedObject.orderDate] == NSOrderedSame){
                    isNew = NO;
                    break;
                }
            }

            if(isNew){
                Order *orderObject = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Order"
                                 inManagedObjectContext:self.managedObjectContext];

                NSDictionary *dailyMenu = [order objectForKey:@"DailyMenu"];
                orderObject.quantity = [order objectForKey:@"Quantity"];
                orderObject.itemName = [dailyMenu objectForKey:keyItemName];
                orderObject.price = [dailyMenu objectForKey:keyItemPrice];
                orderObject.orderDate = [self dateWithJSONString:(NSString *) [order objectForKey:@"OrderDate"]];
                NSLog(@"Saving Order %@, %@", orderObject.itemName, orderObject.orderDate);
            }
        }
    }
    NSError *error;
    [(self.managedObjectContext) save:&error];
    if (error) {
        NSLog(@"Error occured : %@", error.localizedDescription);
    }
    [_fetchedResultsController performFetch:&error];
    NSLog(@"Count after save = %u", [_fetchedResultsController fetchedObjects].count);
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
        [self setOrderHistory:jsonArray];
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
    NSLog(@"Seriously what happend : %@", error.localizedDescription);
}


#pragma FetchedResultsController methods

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSLog(@"didChangeSection at index %u", sectionIndex);

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


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"didChangeObject at indexpath %@, new Indexpath %@", indexPath, newIndexPath);

    UITableView *tableView = self.tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationRight];
            break;

        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}


#pragma FetchedResultController methods end


- (IBAction)onDoneTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTopButtonTap:(UIButton *)sender {
    NSError *error;
    NSMutableArray *array = [[_fetchedResultsController fetchedObjects] mutableCopy];

    for(int j = 0; j <array.count; j++){
        Order *order = (Order *) [array objectAtIndex:(NSUInteger) j];
        NSLog(@"Before %@ - %@",order.orderDate, order.displayOrder);
        (order).displayOrder = [NSNumber numberWithUnsignedInteger:array.count - j];
        NSLog(@"After %@ - %@",order.orderDate, order.displayOrder);
    }

    [self.managedObjectContext save:nil];

}

- (void)setUser:(NSString *)name {
    userName = name;
}
@end
