//
//  RootViewController.m
//  BetterBeta
//
//  Created by Andrew Oliver on 4/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainMenuViewController.h"
#import "ProblemsViewController.h"
#import "BetasViewController.h"
#import "SyncController.h"
#import "AreasViewController.h"
#import "MapViewController.h"
#import "Area.h"
#import "BetterBetaCDAppDelegate.h"

@implementation MainMenuViewController

@synthesize fetchedResultsController, managedObjectContext, addingManagedObjectContext, mapTableViewCell, mapView;

- (void)loadView {
    [super loadView];

	self.title = @"Main Menu";
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	self.tableView.backgroundColor = [UIColor blackColor];
	
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)] autorelease];
	[headerView setBackgroundColor:[UIColor clearColor]];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, self.tableView.bounds.size.width - 10, 18)] autorelease];
	label.text = @"Welcome to Better Beta!";
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];

	label.font = [UIFont fontWithName:@"Helvetica" size:20.0];;
	label.textAlignment = UITextAlignmentCenter;
	
	[headerView addSubview:label];
	self.tableView.tableHeaderView = headerView; 
	
	syncController = [[SyncController alloc] initWithCoordinator:[managedObjectContext persistentStoreCoordinator]];
	
	self.mapTableViewCell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	
	self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	self.mapView.layer.cornerRadius = 8;
	mapView.delegate = self;
	mapView.showsUserLocation = YES;
	
	[mapView setUserInteractionEnabled:NO];
	[self.mapTableViewCell.contentView addSubview:self.mapView];

	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSError *error;
	NSEntityDescription *entityArea =[NSEntityDescription entityForName:@"Area"	inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %d", 1];
	[request setPredicate:predicate];
	[request setEntity:entityArea];
	NSArray *earthArea = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSLog(@"there are %i areas to show", [earthArea count]);
	if ([earthArea count] == 0)
		[syncController syncAll];
	else {
		Area* theEarth = (Area*)[earthArea objectAtIndex:0];
		NSSet* areasToShow = theEarth.children;
		for (Area* area in areasToShow){
			[mapView addAnnotation:area];
		}
	}

	
	
	BetterBetaCDAppDelegate * delegate = [[UIApplication sharedApplication] delegate];
	[self setToolbarItems:[NSArray arrayWithObjects:[delegate syncingBarItem], [delegate progressBarItem], nil]];
	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(mergeChanges:)
			   name:NSManagedObjectContextDidSaveNotification
			 object:nil];
	
	
	
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
}


- (void)mergeChanges:(NSNotification*)notification {
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;	
	}
	else {
		return 3;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0){
		return 165;
	}
	else {
		return 44;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MainMenuItem";
	static NSString *CellIdentifierMap = @"MapCell";
	UITableViewCell *cell;
	
	if (indexPath.section == 0){
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMap];
		if (cell == nil) {
			cell = mapTableViewCell;
		}
		return cell;
	}
	
	else {
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		if (indexPath.row == 0)
			cell.textLabel.text = @"Climbing Areas";
		else if (indexPath.row == 1)
			cell.textLabel.text = @"Rock Climbs";
		else if (indexPath.row == 2)
			cell.textLabel.text = @"Synchronize";
		return cell;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if([(BetterBetaCDAppDelegate *)[[UIApplication sharedApplication] delegate] isSyncing]){	
		
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Please Wait"
							  message:@"Please wait until sync is complete"
							  delegate:self 
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
		
	else{
		if(indexPath.section == 0){
			MapViewController *mapViewController = [[MapViewController alloc] init];
			
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			NSError *error;
			NSEntityDescription *entityArea =[NSEntityDescription entityForName:@"Area"	inManagedObjectContext:managedObjectContext];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %d", 1];
			[request setPredicate:predicate];
			[request setEntity:entityArea];
			NSArray *areaArray = [managedObjectContext executeFetchRequest:request error:&error];
			if([areaArray count] == 1){
				Area *earthArea = [areaArray objectAtIndex:0];
				mapViewController.areas = earthArea.children;
			}
			[self.navigationController pushViewController:mapViewController animated:YES];
			[mapViewController release];
			[request release];
		}
		else {
			
			if(indexPath.row == 0){
				AreasViewController *areasViewController = [[AreasViewController alloc] init];
				NSManagedObjectContext * context = self.managedObjectContext;
				[areasViewController setManagedObjectContext:context];
				//areasViewController.managedObjectContext = context;
				
				[self.navigationController pushViewController:areasViewController animated:YES];
				[areasViewController release];
			}
			if(indexPath.row == 1){
				ProblemsViewController *problemsViewController = [[ProblemsViewController alloc] init];
				NSManagedObjectContext * context = self.managedObjectContext;
				[problemsViewController setManagedObjectContext:context];
				
				[self.navigationController pushViewController:problemsViewController animated:YES];
				[problemsViewController release];
			}
			else if(indexPath.row == 2){
				//syncController.managedObjectContext = managedObjectContext;
		//		[self.navigationController setValue:[NSNumber numberWithBool:YES] forKey:@"syncing"];
			//	[UIApplication 
				[syncController syncAll];
				
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
			}
		}
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	else {
		MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
		annView.animatesDrop=TRUE;
		return annView;	
	}
}

- (void) syncComplete{
	[self.mapView removeAnnotations:[self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]]];

	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSError *error;
	NSEntityDescription *entityArea =[NSEntityDescription entityForName:@"Area"	inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %d", 1];
	[request setPredicate:predicate];
	[request setEntity:entityArea];
	NSArray *earthArea = [managedObjectContext executeFetchRequest:request error:&error];

	Area* theEarth = (Area*)[earthArea objectAtIndex:0];
	NSSet* areasToShow = theEarth.children;
	for (Area* area in areasToShow){
		[self.mapView addAnnotation:area];
	}
}

- (void)dealloc {
	self.mapView = nil;
	self.mapTableViewCell = nil;
    [super dealloc];

}


@end

