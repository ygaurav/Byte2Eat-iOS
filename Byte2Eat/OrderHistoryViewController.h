#import <CoreData/CoreData.h>


@interface OrderHistoryViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (strong, nonatomic) NSShadow *shadow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalOrder;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalCost;

- (IBAction)onDoneTap:(UIButton *)sender;
- (IBAction)onRefreshTap:(UIButton *)sender;

- (void)setUser:(NSString *)name;
@end
