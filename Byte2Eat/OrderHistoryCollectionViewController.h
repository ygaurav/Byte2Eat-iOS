#import <UIKit/UIKit.h>

@interface OrderHistoryCollectionViewController : UIViewController  <UICollectionViewDelegateFlowLayout, NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSShadow *shadow;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

- (IBAction)changeCollectionLayout:(UIButton *)sender;
- (IBAction)onDoneButtonTap:(UIButton *)sender;
- (IBAction)onDeleteTap:(UIButton *)sender;

- (void)setUser:(NSString *)name;

@end
