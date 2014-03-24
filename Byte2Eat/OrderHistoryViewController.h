#import <CoreData/CoreData.h>


@interface OrderHistoryViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (nonatomic, strong) NSShadow *shadow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *onSortingButton;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
-(void) setBackgroundImage:(UIImage *)backgroundImage;

- (IBAction)onDoneTap:(UIButton *)sender;
- (IBAction)onTopButtonTap:(UIButton *)sender;
- (IBAction)onRefreshTap:(UIButton *)sender;

- (void)setUser:(NSString *)name;
@end
