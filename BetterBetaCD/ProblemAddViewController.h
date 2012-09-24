
#import "ProblemDetailViewController.h"


@protocol ProblemAddViewControllerDelegate;


@interface ProblemAddViewController : ProblemDetailViewController {
	id <ProblemAddViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <ProblemAddViewControllerDelegate> delegate;

- (void)cancel:(id)sender;
- (void)save:(id)sender;
- (BOOL)validateFields;
@end


@protocol ProblemAddViewControllerDelegate
- (void)problemAddViewController:(ProblemAddViewController *)controller didFinishWithSave:(BOOL)save;
@end

