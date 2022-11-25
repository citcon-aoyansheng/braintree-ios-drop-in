//
//  BTVaultManagementViewControllerExt.m
//  BraintreeDropIn
//
//  Created by long.zhao on 3/8/22.
//

#import "BTVaultManagementViewControllerExt.h"
#import "BTDropInDefaultExt.h"
#import "BTPaymentMethodNonce+DropIn.h"
#import <BraintreeDropIn/BTDropInPaymentSelectionCell.h>
#import "BTAPIClient_Internal_Category.h"

#import <Braintree/BraintreeCard.h>
#import <Braintree/BraintreeCore.h>

@interface BTVaultManagementViewControllerExt ()
@property (nonatomic, assign) NSString *type;
@property (nonatomic, strong) NSArray *matchedPaymentMethodNonces;
@end

@implementation BTVaultManagementViewControllerExt

NSString *const BTGraphQLDeletePaymentMethodFromSingleUseToken2 = @""
"mutation DeletePaymentMethodFromSingleUseToken($input: DeletePaymentMethodFromSingleUseTokenInput!) {"
"  deletePaymentMethodFromSingleUseToken(input: $input) {"
"    clientMutationId"
"  }"
"}";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient type:(NSString *)type request:(BTDropInRequest *)request {
    self.type = type;
    return [self initWithAPIClient:apiClient request:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVaultLoaded:) name:BTDropInDefaultExt.VAULTS_LOADED object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTDropInDefaultExt.VAULTS_LOADED object:nil];
}

#pragma mark - UI SEL

- (void)onVaultLoaded:(NSNotification *)notification {
    [self filterPaymentMethodNoces];
}

#pragma mark - Helpers

- (void)filterPaymentMethodNoces {
    NSLog(@"type: %@", self.type);
    self.matchedPaymentMethodNonces = [[[BTDropInDefaultExt default] filterPaymentMethodNoces:self.paymentMethodNonces type:self.type] copy];
}

#pragma mark - Override

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"BTDropInPaymentSelectionCell";

    BTDropInPaymentSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    BTPaymentMethodNonce *paymentMethod = self.matchedPaymentMethodNonces[indexPath.row];
    BTDropInPaymentMethodType option = [BTUIKViewUtil paymentMethodTypeForPaymentInfoType:paymentMethod.type];

    cell.detailLabel.text = paymentMethod.paymentDescription;
    cell.label.text = [BTUIKViewUtil nameForPaymentMethodType:option];
    cell.iconView.paymentMethodType = option;
    cell.type = option;

    NSLog(@"tableView cellForRowAtIndexPath: %ld", indexPath.row);
    return cell;
}

- (void)tableView:(__unused UITableView *)tableView commitEditingStyle:(__unused UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BTPaymentMethodNonce *paymentMethod = self.matchedPaymentMethodNonces[indexPath.row];
        // Empty table data and show loading while waiting for success/failure callback
        self.paymentMethodNonces = @[];
        [self.paymentOptionsTableView reloadData];
        [self showLoadingScreen:YES];
        NSDictionary *parameters = @{
                                     @"operationName": @"DeletePaymentMethodFromSingleUseToken",
                                     @"query": BTGraphQLDeletePaymentMethodFromSingleUseToken2,
                                     @"variables": @{
                                             @"input": @{ @"singleUseTokenId" : paymentMethod.nonce }
                                             }
                                     };
        [self.apiClient POST:@""
                  parameters:[parameters copy]
                    httpType:BTAPIClientHTTPTypeGraphQLAPI
                  completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error)
         {
             [self loadConfiguration];
             if (error) {
                 [self.apiClient sendAnalyticsEvent:@"ios.dropin2.manager.delete.failed"];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:BTDropInLocalizedString(THERE_WAS_AN_ERROR) preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction *alertAction = [UIAlertAction actionWithTitle:BTDropInLocalizedString(TOP_LEVEL_ERROR_ALERT_VIEW_OK_BUTTON_TEXT) style:UIAlertActionStyleDefault handler:nil];
                     [alertController addAction: alertAction];
                     [self presentViewController:alertController animated:YES completion:nil];
                 });
             } else {
                 [self.apiClient sendAnalyticsEvent:@"ios.dropin2.manager.delete.succeeded"];
             }
         }];
    }
}

#pragma mark - Override UITableViewDataSource

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    NSLog(@"matchedPaymentMethodNonces %ld", [self.matchedPaymentMethodNonces count]);
    return [self.matchedPaymentMethodNonces count];
}

@end
