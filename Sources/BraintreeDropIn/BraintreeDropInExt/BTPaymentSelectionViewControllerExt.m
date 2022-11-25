//
//  BTPaymentSelectionViewControllerExt.m
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

//#import <BraintreeDropIn/BTDropInController.h>
//#import "BTDropInController.h"
#import "BTPaymentSelectionViewControllerExt.h"
#import "BTUIPaymentMethodCollectionViewCell.h"
#import "BTDropInPaymentSelectionCell.h"
#import "BTAPIClient_Internal_Category.h"
#import "BTUIKBarButtonItem_Internal_Declaration.h"
#import "BTVaultedPaymentMethodsTableViewCell.h"
#import "BTPaymentSelectionHeaderView.h"
#import "BTUIKAppearance.h"
#import "BTConfiguration+DropIn.h"
#import "BTPaymentMethodNonce+DropIn.h"

#if __has_include(<Braintree/BraintreeCore.h>) // CocoaPods
#import <Braintree/BraintreeCard.h>
#import <Braintree/BraintreePayPal.h>
#import <Braintree/BraintreeVenmo.h>
#import <Braintree/BraintreeApplePay.h>
#else
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeApplePay/BraintreeApplePay.h>
#endif

#pragma mark - Override begin
#import "BTDropInDefaultExt.h"
#pragma mark - Override end

@interface BTPaymentSelectionViewControllerExt ()
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSArray *matchedPaymentMethodNonces;
@property (nonatomic, assign) BOOL isPaymentLoaded;
@property (nonatomic, assign) BOOL isFirstLoaded;
@end

@implementation BTPaymentSelectionViewControllerExt

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isFirstLoaded = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaymentLoaded:) name:BTDropInDefaultExt.PAYMENT_LOADED object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTDropInDefaultExt.PAYMENT_LOADED object:nil];
}

- (void)loadConfiguration {
    self.isPaymentLoaded = NO;
    [self initNavigation:NO];
    
    [super loadConfiguration];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helpers

- (void)filterPaymentMethodNoces {
    [[BTDropInDefaultExt default] setSupportedCards:self.configuration.supportedCardTypes];
    self.matchedPaymentMethodNonces = [[[BTDropInDefaultExt default] filterPaymentMethodNoces:self.paymentMethodNonces type:self.type] copy];
    
    for (BTPaymentMethodNonce *p in self.matchedPaymentMethodNonces) {
        NSLog(@"filterPaymentMethodNoces type: %@, desc: %@ title: %@ method_type: %ld", p.type, p.paymentDescription,
              [BTUIKViewUtil nameForPaymentMethodType:[BTUIKViewUtil paymentMethodTypeForPaymentInfoType:p.type]],
              (long)[BTUIKViewUtil paymentMethodTypeForPaymentInfoType:p.type]);
    }
    
    [self.paymentOptionsTableView reloadData];
}

// Condition of display add paypal
- (BOOL)paypalLimit {
    if ([self.type caseInsensitiveCompare:@"paypal"] == NSOrderedSame &&
        [self.matchedPaymentMethodNonces count] > 0) {
        return YES;
    }
    return NO;
}

// Display CardForm directly
- (void)presentCardForm {
    if ([self.delegate respondsToSelector:@selector(showCardForm:)]){
        [self.delegate performSelector:@selector(showCardForm:) withObject:self];
    }
}

// Display Venmo directly
- (void)presentVenmo {
    BTVenmoRequest *venmoRequest = self.dropInRequest.venmoRequest;
    if (venmoRequest == nil) {
        venmoRequest = [[BTVenmoRequest alloc] init];
        venmoRequest.vault = true;
    }

    [self showLoadingScreen:YES];
    [self.venmoDriver tokenizeVenmoAccountWithVenmoRequest:venmoRequest completion:^(BTVenmoAccountNonce * _Nullable venmoAccountNonce, NSError * _Nullable error) {
        [self showLoadingScreen:NO];
        if (self.delegate && (venmoAccountNonce != nil || error != nil)) {
            [self.delegate selectionCompletedWithPaymentMethodType:BTDropInPaymentMethodTypeVenmo nonce:venmoAccountNonce error:error];
        }
    }];
}

// Display Paypal directly
- (void)presentPaypal {
    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];

    BTPayPalRequest *payPalRequest = self.dropInRequest.payPalRequest;
    if (payPalRequest == nil) {
        payPalRequest = [[BTPayPalVaultRequest alloc] init];
    }

    [self showLoadingScreen:YES];
    [driver tokenizePayPalAccountWithPayPalRequest:payPalRequest completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        [self showLoadingScreen:NO];
        BOOL shouldReturnError = (error != nil && error.code != BTPayPalDriverErrorTypeCanceled);
        if (self.delegate && (tokenizedPayPalAccount != nil || shouldReturnError)) {
            [self.delegate selectionCompletedWithPaymentMethodType:BTDropInPaymentMethodTypePayPal nonce:tokenizedPayPalAccount error:error];
        }
    }];
}

// Display ApplePay directly
- (void)presentApplePay {
    if (self.delegate) {
        [self.delegate selectionCompletedWithPaymentMethodType:BTDropInPaymentMethodTypeApplePay nonce:nil error:nil];
    }
}

// Display add matched payment method view
- (void)presentPayment {
    if (!self.isPaymentLoaded) {
        return;
    }
    
    if ([self.type caseInsensitiveCompare:@"card"] == NSOrderedSame) {
        [self presentCardForm];
    } else if ([self.type caseInsensitiveCompare:@"paypal"] == NSOrderedSame) {
        [self presentPaypal];
    } else if ([self.type caseInsensitiveCompare:@"venmo"] == NSOrderedSame) {
        [self presentVenmo];
    }
}

// Automatical display
- (void)autoPresent {
    if (self.isPaymentLoaded && self.isFirstLoaded) {
        self.isFirstLoaded = NO;
        
        if ([self.matchedPaymentMethodNonces count] < 1) {
            [self presentPayment];
        }
        return;
    }
}

#pragma mark - Notification SEL

- (void)onPaymentLoaded:(NSNotification *)notification {
    [self filterPaymentMethodNoces];
    
    self.isPaymentLoaded = YES;
    [self initNavigation:YES];
    
    [self autoPresent];
}

#pragma mark - UI edit

- (void)initNavigation:(BOOL)show {
    if (!show || [self paypalLimit]) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    if (!self.isPaymentLoaded) {
        return;
    }
    if (self.navigationItem.rightBarButtonItem != nil) {
        return;
    }
    
    // Add right button
    self.navigationItem.rightBarButtonItem = [[BTUIKBarButtonItem alloc] initWithTitle:BTDropInLocalizedString(NEW_ACTION) style:UIBarButtonItemStylePlain target:self action:@selector(onAddPayment:)];
}

#pragma mark - UI SEL
- (void)onAddPayment:(id)sender {
    [self presentPayment];
}

#pragma mark - Override
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient
                             type:(NSString *)type
                          request:(BTDropInRequest *)request {
    _type = type;
    return [self initWithAPIClient:apiClient request:request];
}

#pragma mark - Override UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.matchedPaymentMethodNonces count] > 0) {
        static NSString *identifier = @"BTVaultedPaymentMethodsTableViewCell";

        BTVaultedPaymentMethodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.paymentMethodNonces = self.matchedPaymentMethodNonces;
        cell.delegate = (id<BTVaultedPaymentMethodsTableViewCellDelegate>)self;
        return cell;
    }
    return nil;
}

#pragma mark - Override UITableViewDataSource

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0 && [self.matchedPaymentMethodNonces count] > 0) {
//        return 1;
        count = 1;
    }
    return count;
}

@end
