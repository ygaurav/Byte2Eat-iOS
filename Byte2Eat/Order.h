@import Foundation;
@import CoreData;


@interface Order : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSDate * orderDate;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * quantity;

@end
