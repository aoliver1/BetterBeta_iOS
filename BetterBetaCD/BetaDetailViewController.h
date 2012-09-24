
#import <MapKit/MapKit.h>

@class Beta, TextEditingViewController;

@interface BetaDetailViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    Beta *beta;
	NSString *betaForWhat;
	UIImagePickerController* picker;
	BOOL showPath;
}

@property (nonatomic, retain) Beta *beta;
@property (nonatomic, retain) NSString *betaForWhat;
@property (nonatomic, retain) UIImagePickerController* picker;
@property (assign) BOOL showPath;

- (void)updateRightBarButtonItemState;

@end