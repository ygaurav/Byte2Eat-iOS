

#import "OrderHistoryCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyFlowLayout.h"

@implementation OrderHistoryCollectionViewController

BOOL toggle = false;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    MyCollectionViewCell *collectionViewCell = (MyCollectionViewCell *) [self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionCell" forIndexPath:indexPath];
    collectionViewCell.labelItemName.text = [NSString stringWithFormat:@"%i", indexPath.item];
    collectionViewCell.labelItemCost.text = [NSString stringWithFormat:@"%i", indexPath.item];
    collectionViewCell.labelQuantity.text = [NSString stringWithFormat:@"%i", indexPath.item];
    return collectionViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(210, 234);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 30, 50, 30);
}


- (IBAction)changeCollectionLayout:(UIButton *)sender {
    MyFlowLayout *flowLayout = [[MyFlowLayout alloc] init];
    flowLayout.scrollDirection = toggle ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    toggle = !toggle;
    [self.myCollectionView setCollectionViewLayout:flowLayout animated:YES];
}
@end
