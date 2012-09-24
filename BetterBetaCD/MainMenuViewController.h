//
//  RootViewController.h
//  BetterBeta
//
//  Created by Andrew Oliver on 4/29/09//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SyncController.h"

@interface MainMenuViewController : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate>{
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;	    
    NSManagedObjectContext *addingManagedObjectContext;	    
	SyncController *syncController;
	
	MKMapView *mapView;
	UITableViewCell * mapTableViewCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UITableViewCell *mapTableViewCell;

-(void)syncComplete;

@end
