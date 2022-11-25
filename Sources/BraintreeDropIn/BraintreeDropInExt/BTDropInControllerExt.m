//
//  BTDropInControllerExt.m
//  BraintreeDropIn
//
//  Created by long.zhao on 3/3/22.
//

#import "BTDropInControllerExt.h"
#import "BTCardFormViewController.h"
#import "BTPaymentSelectionViewControllerExt.h"
#import "BTVaultManagementViewControllerExt.h"
#import "BTDropInDefaultExt.h"

@interface BTDropInControllerExt ()

@property (nonatomic, copy) NSString *type;

@end

@implementation BTDropInControllerExt

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

#pragma mark - Override
- (nullable instancetype)initWithAuthorization:(NSString *)authorization
                                          type:(NSString *)type
                                       request:(BTDropInRequest *)request
                                       handler:(BTDropInControllerHandler)handler {
    _type = type;
    return [self initWithAuthorization:authorization request:request handler:handler];
}

- (void)setUpChildViewControllers {
    self.paymentSelectionViewController = [[BTPaymentSelectionViewControllerExt alloc] initWithAPIClient:self.apiClient type:self.type request:self.dropInRequest];
    self.paymentSelectionViewController.delegate = (id<BTPaymentSelectionViewControllerDelegate, BTDropInControllerDelegate, BTViewControllerPresentingDelegate>)self;
    self.paymentSelectionNavigationController = [[UINavigationController alloc] initWithRootViewController:self.paymentSelectionViewController];
    self.paymentSelectionNavigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentSelectionNavigationController.view.hidden = YES;

    [self.contentClippingView addSubview:self.paymentSelectionNavigationController.view];
}

- (void)editPaymentMethods:(__unused id)sender {
    if ([[[BTDropInDefaultExt default] getMatchedPaymentNonces] count] < 1) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:@"No vault payment methods" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [vc addAction:act];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    BTVaultManagementViewController* vaultManagementViewController = [[BTVaultManagementViewControllerExt alloc] initWithAPIClient:self.apiClient type:self.type request:self.dropInRequest];
    vaultManagementViewController.delegate = ( id<BTDropInControllerDelegate> )self;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:vaultManagementViewController];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        navController.modalPresentationStyle = UIModalPresentationPageSheet;
    } else {
        navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:navController animated:YES completion:nil];
}

@end
