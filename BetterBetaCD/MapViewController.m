//
//  MapController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "MapViewController.h"
#import "Area.h"
#import "Problem.h"
#import "Beta.h"
#import "DDAnnotationView.h"
#import "AreaDetailViewController.h"
#import "ProblemDetailViewController.h"

@implementation MapViewController

@synthesize mapView, areas, problems, betas,objectBeingEdited, inCaseOfCancel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)loadView {
    [super loadView];
	
	self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;
	self.mapView.mapType = MKMapTypeHybrid;
	[self.view addSubview:self.mapView];
	
	if(self.isEditing){
		self.title = @"Editing Location";
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
												  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
													target:self action:@selector(cancel)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
												   initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
													target:self action:@selector(save)] autorelease];

		self.inCaseOfCancel = [[CLLocation alloc] initWithLatitude:objectBeingEdited.coordinate.latitude 
														 longitude:objectBeingEdited.coordinate.longitude];
		MKCoordinateSpan span;
		MKCoordinateRegion region;
		region.center=objectBeingEdited.coordinate;
		if([objectBeingEdited.longitude floatValue] != 0 && [objectBeingEdited.latitude floatValue] != 0){
			span.latitudeDelta=.0015;
			span.longitudeDelta=.0015;
		}
		else{
			span.latitudeDelta=180;
			span.longitudeDelta=180;
		}
		
		if (self.objectBeingEdited.name == nil) {
			self.objectBeingEdited.name = @"New";
		}
		
		NSLog(@"entering editing location with lat: %@ and lon: %@", self.objectBeingEdited.latitude, self.objectBeingEdited.longitude);
		region.span=span;
		[mapView setRegion:region animated:FALSE];
		[mapView addAnnotation:objectBeingEdited];
		
	}
	else{ //not editing
		
		if ([areas count] > 0)
		{
			for (Area* area in areas){
				[mapView addAnnotation:area];
			}
		}
		if ([problems count] > 0){
			for (Problem* problem in problems){
				[mapView addAnnotation:problem];
			}
		}
		
		if ([betas count] > 0){
			for (Beta* beta in betas){
				[mapView addAnnotation:beta];
			}
		}
		
		
		MKCoordinateSpan span;
		MKCoordinateRegion region;
		
		// only one area, either adding or just showing it
		if (areas.count == 1 && problems.count == 0) {
			
			Area* area = [[areas allObjects] objectAtIndex:0];
			
			if([area.longitude floatValue] == 0 && [area.latitude floatValue] == 0){
				
				span.latitudeDelta=180;
				span.longitudeDelta=180;
				region.center=area.coordinate;
				region.span = span;
				[mapView setRegion:region animated:FALSE];
			}
	
			else {
				span.latitudeDelta=5;
				span.longitudeDelta=5;
				region.span = span;
				region.center=area.coordinate;
				[mapView setRegion:region animated:FALSE];
			}
		}
		
		else if (areas.count == 0 && problems.count == 1){
			
			Problem* problem = [[problems allObjects] objectAtIndex:0];
			span.latitudeDelta=5;
			span.longitudeDelta=5;
			region.span = span;
			region.center=problem.coordinate;
			[mapView setRegion:region animated:FALSE];
		}
		
		else if ([mapView.annotations count] > 2) { // including user location annotation
			MKMapRect flyTo = MKMapRectNull;
			for (id <MKAnnotation> annotation in mapView.annotations) {
				if (![annotation isKindOfClass:[MKUserLocation class]]) {
					MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
					MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
					if (MKMapRectIsNull(flyTo)) {
						flyTo = pointRect;
					} else {
						flyTo = MKMapRectUnion(flyTo, pointRect);
					}
				}
			}
			[mapView setVisibleMapRect:flyTo animated:NO];
			self.mapView.mapType = MKMapTypeHybrid;
		}
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	if (self.isEditing) {
		
		MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
		
		if (draggablePinView) {
			draggablePinView.annotation = annotation;
		} else {
			// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
			draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
			
			if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
				// draggablePinView is DDAnnotationView on iOS 3.
			} else {
				// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
			}
		}		
		return draggablePinView;
	}
	
	else {
		MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
		
		if ([annotation isKindOfClass:[Problem class]]){
			annView.pinColor = MKPinAnnotationColorGreen;
		}
		if ([annotation isKindOfClass:[Area class]]){
			annView.pinColor = MKPinAnnotationColorRed;
		}
		
		UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
		annView.rightCalloutAccessoryView = advertButton;
		
	//	annView.animatesDrop=TRUE;
		annView.canShowCallout = YES;
	//	annView.calloutOffset = CGPointMake(-5, 5);
		return annView;	
	}

	return nil;	
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	
	LocatableSyncable* theAnnotation = (LocatableSyncable*) view.annotation;
	
	if ([theAnnotation isKindOfClass:[Area class]]) {
		AreaDetailViewController *areaDetailViewController = [[AreaDetailViewController alloc] init];
		areaDetailViewController.area = (Area*)theAnnotation;
		[self.navigationController pushViewController:areaDetailViewController animated:YES];
		[areaDetailViewController release];
	}
	if ([theAnnotation isKindOfClass:[Problem class]]) {
		ProblemDetailViewController *problemDetailViewController = [[ProblemDetailViewController alloc] init];
		problemDetailViewController.problem = (Problem*)theAnnotation;
		[self.navigationController pushViewController:problemDetailViewController animated:YES];
		[problemDetailViewController release];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	 self.mapView = nil;
}

#pragma mark -
#pragma mark Save and cancel operations for Editing mode.

- (IBAction)save {
	
	NSLog(@"saving editing location with lat: %@ and lon: %@", self.objectBeingEdited.latitude, self.objectBeingEdited.longitude);
	self.objectBeingEdited.state = [NSNumber numberWithInt:2];//DIRTY
	if ([self.objectBeingEdited.name isEqualToString:@"New"]) {
		self.objectBeingEdited.name = @"";
	}
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel {
    // Don't pass current value to the edited object, just pop.
	self.objectBeingEdited.latitude = [NSNumber numberWithDouble:self.inCaseOfCancel.coordinate.latitude];
	self.objectBeingEdited.longitude = [NSNumber numberWithDouble:self.inCaseOfCancel.coordinate.longitude];
	
	if ([self.objectBeingEdited.name isEqualToString:@"New"]) {
		self.objectBeingEdited.name = @"";
	}
	NSLog(@"cancelling editing location with lat: %@ and lon: %@", self.objectBeingEdited.latitude, self.objectBeingEdited.longitude);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	self.mapView.delegate = nil;
	self.mapView = nil;
	self.objectBeingEdited = nil;
	self.areas = nil;
	self.problems = nil;
	self.betas = nil;
	
	//	[mapView release];
    [super dealloc];
}

@end
