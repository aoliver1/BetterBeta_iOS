
#import "BetaDetailViewController.h"


@protocol BetaAddViewControllerDelegate;


@interface BetaAddViewController : BetaDetailViewController {
	id <BetaAddViewControllerDelegate> delegate;
	}

@property (nonatomic, assign) id <BetaAddViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (BOOL)validateFields;

@end


@protocol BetaAddViewControllerDelegate
- (void)betaAddViewController:(BetaAddViewController *)controller didFinishWithSave:(BOOL)save;
@end

