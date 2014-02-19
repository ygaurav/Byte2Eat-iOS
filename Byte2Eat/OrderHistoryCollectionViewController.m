

#import "OrderHistoryCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyFlowLayout.h"
#import "MyWideCollectionViewCell.h"

@implementation OrderHistoryCollectionViewController

BOOL isVertical = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.myCollectionView setCollectionViewLayout:flowLayout animated:YES];
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"WideCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"wideCollectionViewCell"];
//    [self.myCollectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"myCollectionCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma CollectionViewDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (!isVertical) {
        MyCollectionViewCell *collectionViewCell = (MyCollectionViewCell *) [self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionCell" forIndexPath:indexPath];
        collectionViewCell.labelItemName.text = [NSString stringWithFormat:@"%i", indexPath.item];
        collectionViewCell.labelItemCost.text = [NSString stringWithFormat:@"%i", indexPath.item];
        collectionViewCell.labelQuantity.text = [NSString stringWithFormat:@"%i", indexPath.item];
        return collectionViewCell;
//    } else {
//        MyWideCollectionViewCell *collectionViewCell = (MyWideCollectionViewCell *)[self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"wideCollectionViewCell" forIndexPath:indexPath];
//        collectionViewCell.labelItemName.text = [NSString stringWithFormat:@"%i", indexPath.item];
//        collectionViewCell.labelItemCost.text = [NSString stringWithFormat:@"%i", indexPath.item];
//        collectionViewCell.labelQuantity.text = [NSString stringWithFormat:@"%i", indexPath.item];
//        return collectionViewCell;
//    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(210, 234);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 30, 50, 30);
}


- (IBAction)changeCollectionLayout:(UIButton *)sender {
//    MyFlowLayout *flowLayout = [[MyFlowLayout alloc] init];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = isVertical ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    isVertical = !isVertical;
    [self.myCollectionView setCollectionViewLayout:flowLayout animated:YES];
//    [self.myCollectionView reloadItemsAtIndexPaths:[self.myCollectionView visibleCells]];
}

- (IBAction)onDoneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
