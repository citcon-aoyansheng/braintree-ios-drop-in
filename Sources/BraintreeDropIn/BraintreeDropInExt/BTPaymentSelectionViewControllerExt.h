//
//  BTPaymentSelectionViewControllerExt.h
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

#import "BTPaymentSelectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentSelectionViewControllerExt : BTPaymentSelectionViewController

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient
                             type:(NSString *)type
                          request:(BTDropInRequest *)request;

@end

NS_ASSUME_NONNULL_END
