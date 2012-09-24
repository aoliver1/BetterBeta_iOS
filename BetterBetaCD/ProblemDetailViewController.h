
#import <MapKit/MapKit.h>
#import "BetaAddViewController.h"

@class Problem, TextEditingViewController;

@interface ProblemDetailViewController : UITableViewController <BetaAddViewControllerDelegate>{
    Problem *problem;
	MKMapView *mapView;
	UITableViewCell * mapTableViewCell;
    NSManagedObjectContext *addingManagedObjectContext;	 
	
	NSArray* sortedBeta;
}

@property (nonatomic, retain) Problem *problem;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UITableViewCell *mapTableViewCell;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;
@property (nonatomic, retain) NSArray *sortedBeta;

- (void)updateRightBarButtonItemState;

- (void) addBeta;

@end