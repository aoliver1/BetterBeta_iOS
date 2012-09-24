//
//  MapController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocatableSyncable.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {

	IBOutlet MKMapView *mapView;
	NSSet *problems;
	NSSet *areas;
	NSSet *betas;
	LocatableSyncable * objectBeingEdited;
	CLLocation* inCaseOfCancel;

}

@property (nonatomic, assign) MKMapView *mapView;
@property (nonatomic, retain) LocatableSyncable * objectBeingEdited;
@property (nonatomic, retain) NSSet *problems;
@property (nonatomic, retain) NSSet *areas;
@property (nonatomic, retain) NSSet *betas;
@property (nonatomic, retain) CLLocation* inCaseOfCancel;

@end
