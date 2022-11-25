//
//  BTDropInDefaultExt.m
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

#import "BTDropInDefaultExt.h"
#import <Braintree/BTPaymentMethodNonce.h>

@interface BTDropInDefaultExt()
@property (nonatomic, strong) NSArray *supportedCardTypes;
@property (nonatomic, strong) NSMutableArray *matchedPaymentMethodNonces;
@end

@implementation BTDropInDefaultExt

+ (nonnull instancetype)default {
    static BTDropInDefaultExt *_inst = nil;
    static dispatch_once_t _once;
    dispatch_once(&_once, ^{
        _inst = [BTDropInDefaultExt new];
        _inst.matchedPaymentMethodNonces = [NSMutableArray array];
    });
    return _inst;
}

- (void)setSupportedCards:(NSArray *)supportedCardTypes {
    self.supportedCardTypes = [supportedCardTypes copy];
}

- (NSArray *)filterPaymentMethodNoces:(NSArray *)paymentMethodNoces type:(NSString *)type {
    if (type == nil) {
        return @[];
    }
    if ([self.supportedCardTypes count] < 1) {
        return @[];
    }
    
    [self.matchedPaymentMethodNonces removeAllObjects];
    if ([type caseInsensitiveCompare:@"card"] == NSOrderedSame) {
        for (BTPaymentMethodNonce *nonce in paymentMethodNoces) {
            for (NSString *card in self.supportedCardTypes) {
                if ([card caseInsensitiveCompare:nonce.type] == NSOrderedSame) {
                    [self.matchedPaymentMethodNonces addObject:nonce];
                }
            }
        }
    } else if ([type caseInsensitiveCompare:@"paypal"] == NSOrderedSame) {
        for (BTPaymentMethodNonce *nonce in paymentMethodNoces) {
            if (nonce.type != nil && [nonce.type caseInsensitiveCompare:@"PayPal"] == NSOrderedSame) {
                [self.matchedPaymentMethodNonces addObject:nonce];
            }
        }
    } else if ([type caseInsensitiveCompare:@"Venmo"] == NSOrderedSame) {
        for (BTPaymentMethodNonce *nonce in paymentMethodNoces) {
            if (nonce.type != nil && [nonce.type caseInsensitiveCompare:@"Venmo"] == NSOrderedSame) {
                [self.matchedPaymentMethodNonces addObject:nonce];
            }
        }
    }
    
    return self.matchedPaymentMethodNonces;
}

- (NSArray *)getMatchedPaymentNonces {
    return self.matchedPaymentMethodNonces;
}

+ (NSString *)PAYMENT_LOADED {
    return @"BTDropInExt.Payment.Loadded";
}

+ (NSString *)VAULTS_LOADED {
    return @"BTDropInExt.Vaults.Loaded";
}

@end
