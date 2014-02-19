#import <CoreData/CoreData.h>


@interface OrderHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property(nonatomic, strong) NSShadow *shadow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;

- (IBAction)onDoneTap:(UIButton *)sender;

- (void)setUser:(NSString *)name;
@end
