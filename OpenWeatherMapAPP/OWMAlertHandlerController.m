#import "OWMAlertHandlerController.h"

@implementation OWMAlertHandlerController

+ (void)displayNetworkErrorAlert {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Ops...Network Error. Please check your Internet connection and try again", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alertView show];
}

@end
