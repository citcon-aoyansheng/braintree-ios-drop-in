//
//  BraintreeDropInExt.m
//  BraintreeDropIn
//
//  Created by long.zhao on 3/3/22.
//

#import "BraintreeDropInExt.h"
#import "BTDropInControllerExt.h"
#import <Braintree/BTThreeDSecurePostalAddress.h>
#import <Braintree/BTThreeDSecureAdditionalInformation.h>

@interface BraintreeDropInExt ()

@end

@implementation BraintreeDropInExt

+ (BTDropInRequest *)createRequest:(NSDictionary *)order {
    BTDropInRequest *request = [BTDropInRequest new];
    request.vaultManager = YES;
    
    if ([[order allKeys] containsObject:@"threeDS"] &&
        [[order objectForKey:@"threeDS"] intValue] != 0) {
        BTThreeDSecureRequest *threeDSecureRequest = [BTThreeDSecureRequest new];
        
        threeDSecureRequest.amount = [NSDecimalNumber decimalNumberWithString:[order objectForKey:@"amount"]];
        threeDSecureRequest.email = [order objectForKey:@"email"];
        threeDSecureRequest.versionRequested = BTThreeDSecureVersion2;
        
        BTThreeDSecurePostalAddress *billingAddr = [BTThreeDSecurePostalAddress new];
        billingAddr.givenName = [order objectForKey:@"givenName"];
        billingAddr.surname = [order objectForKey:@"surname"];
        billingAddr.phoneNumber = [order objectForKey:@"phoneNumber"];
        billingAddr.streetAddress = [order objectForKey:@"streetAddress"];
        billingAddr.extendedAddress = [order objectForKey:@"extendedAddress"];
        billingAddr.locality = [order objectForKey:@"locality"];
        billingAddr.region = [order objectForKey:@"region"];
        billingAddr.postalCode = [order objectForKey:@"postalCode"];
        billingAddr.countryCodeAlpha2 = [order objectForKey:@"countryCodeAlpha2"];
        threeDSecureRequest.billingAddress = billingAddr;
        
        BTThreeDSecureAdditionalInformation *info = [BTThreeDSecureAdditionalInformation new];
        info.shippingAddress = billingAddr;
        threeDSecureRequest.additionalInformation = info;
        
        request.threeDSecureRequest = threeDSecureRequest;
    }
    
    return request;
}

+ (void)payOrder:(NSDictionary *)order
            type:(NSString *)type
           token:(NSString *)token
      controller:(UIViewController *)vc
        callback:(CompletionBlock)completionBlock {
    BTDropInRequest *request = [BraintreeDropInExt createRequest:order];
    BTDropInControllerExt *dropIn = [[BTDropInControllerExt alloc] initWithAuthorization:token
                                                                                    type:type
                                                                                 request:request
                                                                                 handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (completionBlock) {
                completionBlock(@{@"status": @"fail", @"code": @"-1", @"message": error.localizedDescription});
            }
        } else if (result.isCanceled) {
            if (completionBlock) {
                completionBlock(@{@"status": @"fail", @"code": @"-2", @"message": @"Canceled"});
            }
        } else {
            if (result.paymentMethodType == BTDropInPaymentMethodTypeApplePay) {
                
            } else {
                if (completionBlock) {
                    completionBlock(@{@"status": @"success", @"code": @"0", @"nonce": result.paymentMethod.nonce});
                }
            }
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [vc presentViewController:dropIn animated:YES completion:nil];
}

@end
