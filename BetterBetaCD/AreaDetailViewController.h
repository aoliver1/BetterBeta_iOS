
#import <MapKit/MapKit.h>
#import "BetaAddViewController.h"
#import "ProblemAddViewController.h"

@class Area, TextEditingViewController;

@interface AreaDetailViewController : UITableViewController	<BetaAddViewControllerDelegate, ProblemAddViewControllerDelegate, MKMapViewDelegate>	{
    Area *area;
	MKMapView *mapView;
	UITableViewCell * mapTableViewCell;
    NSManagedObjectContext *addingManagedObjectContext;	
	NSArray* sortedBeta;
	NSArray* sortedChildAreas;
	NSArray* sortedProblems;
}

@property (nonatomic, retain) Area *area;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UITableViewCell *mapTableViewCell;

@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

@property (nonatomic,retain) NSArray* sortedProblems;
@property (nonatomic,retain) NSArray* sortedChildAreas;
@property (nonatomic,retain) NSArray* sortedBeta;

- (void)updateRightBarButtonItemState;
- (void)addArea;
- (void)addProblem;
- (void)addBeta;
@end

