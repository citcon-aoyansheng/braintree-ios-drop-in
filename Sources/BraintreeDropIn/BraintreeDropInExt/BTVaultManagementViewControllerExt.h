//
//  BTVaultManagementViewControllerExt.h
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

#import "BTVaultManagementViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTVaultManagementViewControllerExt : BTVaultManagementViewController

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient
                             type:(NSString *)type
                          request:(BTDropInRequest *)request;

@end

NS_ASSUME_NONNULL_END
