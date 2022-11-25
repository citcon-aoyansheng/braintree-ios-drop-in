//
//  BTDropInControllerExt.h
//  BraintreeDropIn
//
//  Created by long.zhao on 3/3/22.
//

#import <BraintreeDropIn/BraintreeDropIn.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInControllerExt : BTDropInController

- (nullable instancetype)initWithAuthorization:(NSString *)authorization
                                          type:(NSString*)type
                                       request:(BTDropInRequest *)request
                                       handler:(nullable BTDropInControllerHandler)handler;

@end

NS_ASSUME_NONNULL_END
