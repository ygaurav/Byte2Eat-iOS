#import <CoreData/CoreData.h>
#import "OrderHistoryCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyFlowLayout.h"
#import "Constants.h"
#import "Order.h"
#import "Utilities.h"
#import "MySimpleLayout.h"
#import "MySpringyLayout.h"
#import "MyCoverFlowLayout.h"
#import "MyWideCollectionViewCell.h"
#import "MyCircleLayout.h"

BOOL isFetchingHistory;
BOOL isSimple = NO;

NSMutableData *totalData;

int layoutId = 1;

@implementation OrderHistoryCollectionViewController {
    NSString *userName;
    NSMutableArray *orderHistory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MyFlowLayout *flowLayout = [[MyFlowLayout alloc] init];
//    MySimpleLayout *flowLayout = [[MySimpleLayout alloc] init];
//    MyCoverFlowLayout *flowLayout = [[MyCoverFlowLayout alloc] init];
//    MySpringyLayout *flowLayout = [[MySpringyLayout alloc] init];
//    MyCircleLayout *flowLayout  = [[MyCircleLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.myCollectionView setCollectionViewLayout:flowLayout animated:YES];
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"WideCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"wideCollectionViewCell"];

    self.shadow = [[NSShadow alloc] init];
    self.shadow.shadowBlurRadius = 3.0;
    self.shadow.shadowColor = [UIColor blackColor];
    self.shadow.shadowOffset = CGSizeMake(0, 0);
    self.errorLabel.text = @"";

    [self.plusButton setHidden:YES];
    [self.minusButton setHidden:YES];

    self.managedObjectContext = [Utilities getManagedObjectContext];
    [self fetchOrderHistory:YES];

}

- (void)fetchOrderHistory:(bool)isFirstFetch {
    isFetchingHistory = YES;
    totalData = [[NSMutableData alloc] init];

//    NSMutableAttributedString *historyTitle = [[NSMutableAttributedString alloc] initWithString:@"fetching data..."];
//    [historyTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, historyTitle.length)];
//    [historyTitle addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, historyTitle.length)];
//    [historyTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:1 alpha:1] range:NSMakeRange(0, historyTitle.length)];
//    CATransition *animation = [CATransition animation];
//    animation.duration = 1.0;
//    animation.type = kCATransitionFade;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    [_errorLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
//    [_errorLabel setAttributedText:historyTitle];

//    NSString *orderHistoryURL = [NSString stringWithFormat:keyURLOrderHistory, userName];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:orderHistoryURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//    [request setHTTPMethod:@"GET"];
//    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Order"
                                                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    NSError *error = nil;
    orderHistory = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (error) {
        [self showError:error.localizedDescription];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma CollectionViewDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return orderHistory.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//  For Other Layout
    MyCollectionViewCell *collectionViewCell = (MyCollectionViewCell *) [self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionCell" forIndexPath:indexPath];

//  For Springy Layout
//    MyWideCollectionViewCell *collectionViewCell = (MyWideCollectionViewCell *)[self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"wideCollectionViewCell" forIndexPath:indexPath];
    Order *order = [orderHistory objectAtIndex:(NSUInteger) indexPath.item];

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

    collectionViewCell.labelItemName.attributedText = itemName;
    collectionViewCell.labelItemPrice.attributedText = price;
    collectionViewCell.labelItemCost.attributedText = cost;
    collectionViewCell.labelQuantity.attributedText = quantity;
    collectionViewCell.labelOrderDate.attributedText = date;

    return collectionViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(210, 234);                      //For Every other Layout
//    return CGSizeMake(320, 100);                        //For Springy Layout
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 55, 50, 55);          //For Every other layout
//    return UIEdgeInsetsMake(0, 0, 0, 0);                //For Springy Layout
}

- (IBAction)changeCollectionLayout:(UIButton *)sender {
    //TODO Do Something
}

- (IBAction)onDoneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDeleteTap:(UIButton *)sender {
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received %d bytes of data", [data length]);
    if (data != nil) {
        [totalData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    isFetchingHistory = NO;
    [self showError:error.localizedDescription];
    NSLog(@"Seriously what happend : %@", error.localizedDescription);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    isFetchingHistory = NO;
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
    [_errorLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_errorLabel setAttributedText:historyTitle];
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
    [_errorLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_errorLabel setAttributedText:historyTitle];

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
    [_errorLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [_errorLabel setAttributedText:historyTitle];
    [timer invalidate];
}

- (void)setOrderHistory:(NSDictionary *)dictionary {
    NSArray *orderHistoryDictionary = [dictionary objectForKey:keyOrderHistory];
    NSLog(@"Saving order History for first time.");
    NSNumber *displayOrder = [NSNumber numberWithInt:1];
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
    
    NSError *error;
    [(self.managedObjectContext) save:&error];
    if (error) {
        NSLog(@"Error occured : %@", error.localizedDescription);
    }
    [self.managedObjectContext processPendingChanges];
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
/*! Takes NSDate and returns short string containing date only
 
 @param NSDate *
 @returns NSString *
 
*/

- (NSString *)shortDateTimeString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)setUser:(NSString *)name {
    userName = name;
}


@end
