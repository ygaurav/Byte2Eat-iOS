#import "TableViewCellWithButtons.h"
#import "OrderHistoryCell.h"

#define PULL_THRESHOLD 60
#define PAGE_NUMBER 3

@implementation TableViewCellWithButtons

-(void)awakeFromNib{
    NSLog(@"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
    self.testScrollView.delegate = self;
    self.testScrollView.pagingEnabled = YES;
    [self.testScrollView setAlwaysBounceHorizontal:YES];
    [self.testScrollView setScrollEnabled:YES];
    self.testScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.testScrollView.contentSize = CGSizeMake(320*PAGE_NUMBER, CGRectGetHeight(self.testScrollView.frame));
    NSLog(@"frame width %f",CGRectGetWidth(self.testScrollView.frame));
    for (int i = 0; i < PAGE_NUMBER; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(320*i,0, 320, CGRectGetHeight(self.testScrollView.frame))];
        view.backgroundColor = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:.5];
        [self.testScrollView addSubview:view];
    }
    
    NSLog(@"Content Size %f, %f", self.testScrollView.contentSize.width, self.testScrollView.contentSize.height);
    CGRect frame = self.testScrollView.frame;
    NSLog(@"ScrollView %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    CGFloat offset = scrollView.contentOffset.x;
    if (offset < -PULL_THRESHOLD) {
        [self.scrollDelegate scrollingCellDidBeginPulling:self];
    }
}


-(void)scrollingEnded{
    [self.scrollDelegate scrollingCellDidEndPulling:self];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self scrollingEnded];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollingEnded];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Find out if the user is actively scrolling the tableView of which this is a member.
    // If they are, return NO, and don't let the gesture recognizers work simultaneously.
    //
    // This works very well in maintaining user expectations while still allowing for the user to
    // scroll the cell sideways when that is their true intent.
    NSLog(@"Conflict");
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        // Find the current scrolling velocity in that view, in the Y direction.
        CGFloat yVelocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].y;
        
        // Return YES iff the user is not actively scrolling up.
        return fabs(yVelocity) <= 0.25;
        
    }
    return YES;
}

@end
