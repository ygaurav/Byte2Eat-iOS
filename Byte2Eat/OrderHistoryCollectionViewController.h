#import <UIKit/UIKit.h>

@interface OrderHistoryCollectionViewController : UIViewController  <UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)changeCollectionLayout:(UIButton *)sender;

@end
