#import <BraintreeDropIn/BTDropInController.h>
#import "BTDropInBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class BTPaymentMethodNonce;
@protocol BTDropInControllerDelegate;

/// Contains form elements for editing vaulted payment methods.
@interface BTVaultManagementViewController : BTDropInBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<BTDropInControllerDelegate> delegate;

#pragma mark - Override begin
@property (nonatomic, strong) NSArray *paymentMethodNonces;
@property (nonatomic, strong) UITableView *paymentOptionsTableView;
#pragma mark - Override end

@end

NS_ASSUME_NONNULL_END
