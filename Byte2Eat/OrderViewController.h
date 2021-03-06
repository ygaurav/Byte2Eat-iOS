
#import <CoreData/CoreData.h>
#import <CoreMotion/CoreMotion.h>
#import "MyInteractiveTransitionManager.h"
@class MyInteractiveTransitionManager;
@class TransitionManager;

@interface OrderViewController : UIViewController  <UIGestureRecognizerDelegate,UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UILabel *LabelRemainingBalance;
@property (weak, nonatomic) IBOutlet UILabel *LabelUserName;
@property (weak, nonatomic) IBOutlet UILabel *LabelDailyMenuItemName;
@property (weak, nonatomic) IBOutlet UILabel *LabelPricePerUnit;
@property (weak, nonatomic) IBOutlet UILabel *LabelTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *LabelTotalOrder;
@property (strong, nonatomic) IBOutlet UIPickerView *OrderNumberPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *aajKhaneMeinKyaHai;
@property (weak, nonatomic) IBOutlet UIButton *orderHistoryButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderQuantityButton;



@property (nonatomic) NSNumber *remainingBalance;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *itemName;
@property (nonatomic) NSNumber *pricePerUnit;
@property (nonatomic) NSNumber *totalCost;
@property (nonatomic) NSNumber *todayTotalOrder;
@property (nonatomic) NSNumber *currentOrderNumber;
@property (nonatomic) NSNumber *userId;
@property (nonatomic) NSNumber *dailyMenuId;

@property (nonatomic, strong) NSShadow *shadow;
@property (nonatomic, strong) NSShadow *whiteShadow;
@property (nonatomic, strong) NSShadow *greenShadow;
@property (nonatomic, strong) NSShadow *redShadow;
@property (nonatomic) CAEmitterLayer *sparkleEmitterLayer;

@property (nonatomic) CAEmitterLayer *leftEmitterLayer;
@property (nonatomic) CAEmitterLayer *rightEmitterLayer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalCostConstraint;

@property (nonatomic,weak) NSDictionary *userInfo;
@property (nonatomic,strong) TransitionManager *transitionManager;
//@property(nonatomic,strong) MyInteractiveTransitionManager *transitionManager;
@property (nonatomic,strong) CMMotionManager *coreMotionManager;

@property(nonatomic, strong) NSTimer *timer;

- (void)setTodayMenu:(NSDictionary *)dictionary;

- (IBAction)onLogout:(UIButton *)sender;
- (IBAction)onOrder:(UIButton *)sender;
- (IBAction)onOrderHistory:(UIButton *)sender;
- (IBAction)onQuantityChangeButton:(UIButton *)sender;

@end
