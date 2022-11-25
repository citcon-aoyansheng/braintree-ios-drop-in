//
//  BTDropInDefaultExt.h
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInDefaultExt : NSObject

+ (nonnull instancetype)default;

- (void)setSupportedCards:(NSArray *)supportedCardTypes;

/**
 * @Brief Filter original array of payment methods. You have to set supported cards at first.
 *
 * @Param paymentMethodNoces is original array of payment methods. The object type of this array is instance of BTPaymentMethodNonce.
 * @Param type is special type such as "card", "paypal", "venmo" etc.
 *
 * @return An array of matched specified type
 */
- (NSArray *)filterPaymentMethodNoces:(NSArray *)paymentMethodNoces
                                 type:(NSString *)type;

/**
 * @Brief Get an array of last filtered matches.
 *
 * @return An array of matches obtained from the last call to filterPaymentMethodNoces
 */
- (NSArray *)getMatchedPaymentNonces;

+ (NSString *)PAYMENT_LOADED;
+ (NSString *)VAULTS_LOADED;


@end

NS_ASSUME_NONNULL_END
