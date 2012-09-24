
#import "AreaDetailViewController.h"

@protocol AreaAddViewControllerDelegate;

@interface AreaAddViewController : AreaDetailViewController {
	id <AreaAddViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <AreaAddViewControllerDelegate> delegate;


- (void)cancel:(id)sender;
- (void)save:(id)sender;
- (BOOL)validateFields;

@end


@protocol AreaAddViewControllerDelegate
- (void)areaAddViewController:(AreaAddViewController *)controller didFinishWithSave:(BOOL)save;
@end

