
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AreaDetailViewController.h"
#import "ProblemDetailViewController.h"
#import "Area.h"
#import "Problem.h"
#import "TextEditingViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"
#import "BetterBetaCDAppDelegate.h"
#import "AreaAddViewController.h"
#import "ProblemAddViewController.h"
#import "BetaAddViewController.h"

@implementation AreaDetailViewController

@synthesize area, mapView, mapTableViewCell, addingManagedObjectContext, sortedBeta, sortedChildAreas, sortedProblems;

#pragma mark -
#pragma mark View lifecycle


- (void)loadView {
    [super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	
	self.tableView.backgroundColor = [UIColor blackColor];
	
	self.mapTableViewCell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	
	self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	self.mapView.layer.cornerRadius = 8;
	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self; 
	[self.mapTableViewCell.contentView addSubview:self.mapView];
	
	// Configure the title, title bar, and table view.
	self.title = area.name;
	
	if(area.permission)
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.tableView.allowsSelectionDuringEditing = YES;
	
	[mapView addAnnotations:[self.area.problems allObjects]];
	[mapView addAnnotation:self.area];
	[mapView setCenterCoordinate:area.coordinate animated:NO];
	
	// Set Zoom Level
	MKCoordinateSpan span;
	MKCoordinateRegion region;
	region.center=area.coordinate;

	if([area.longitude intValue] && [area.latitude intValue]){
		if ([mapView.annotations count] > 2) {
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
		else {
			span.latitudeDelta=.03;
			span.longitudeDelta=.03;
			region.span=span;
			self.mapView.region = region;
		}

	}
	else{
		span.latitudeDelta=180;
		span.longitudeDelta=180;
		region.span=span;
		[mapView setRegion:region animated:FALSE];
	}
	
	//[mapView setDelegate:self];
	[mapView setUserInteractionEnabled:NO];
	
}

- (void)viewDidUnload {
	self.mapView = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    // Redisplay the data.
    [self.tableView reloadData];
	if(self.editing){
		[self.mapView removeAnnotation:self.area];
		[self.mapView addAnnotation:self.area];
		[self.mapView setCenterCoordinate:area.coordinate animated:NO];
	}
	[self updateRightBarButtonItemState];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    [super setEditing:editing animated:animated];
	
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [self.tableView reloadData];
	
	if (!editing) {
		NSError *error;
		
		if (![area.managedObjectContext save:&error]) {
			// Handle the error.
		}
	}
}

- (void)updateRightBarButtonItemState {
	self.navigationItem.rightBarButtonItem.enabled = [area.permission intValue];
}	

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if(!self.editing){
		return 7;
	}
	else
		return 4;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 3)
		return 165;
	
	else {
		
		NSString *cellText = @"";
		
		if(indexPath.section == 0){
			cellText = area.name;
		}
		else if(indexPath.section == 1){
			cellText = area.details;
		}
		else if (indexPath.section == 2){
			cellText = [area.parent name];
		}
		
		if (indexPath.section == 4){
			if (indexPath.row < [area.children count])
				cellText = [[sortedChildAreas objectAtIndex:indexPath.row] name];
			else
				cellText = @"Add A Sub Area";
		}
		else if (indexPath.section == 5){
			if(indexPath.row < [area.problems count])
				cellText = [[sortedProblems objectAtIndex:indexPath.row] name];
			else
				cellText = @"Add A Climb";
		}
		else if (indexPath.section == 6){
			if(indexPath.row < [area.beta count])
				cellText = [[sortedBeta objectAtIndex:indexPath.row] name];
			else
				cellText = @"Add Beta";
		}
		
		if ([cellText length] == 0) {
			cellText = @"blah";
		}
		
		UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		return labelSize.height + 20;
	}
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 40;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"Area Name";
	else if(section == 1)
		return @"Details";
	else if(section == 2)
		return @"Parent Area";
	else if(section == 3)
		return @"Location";
	
	if(!self.editing){
		if(section == 4)
			return @"Sub-Areas";
		else if(section == 5)
			return @"Climbs";
		else if(section == 6)
			return @"Beta";
	}
	
	return @"";
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
	
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];
	
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section  == 0)
		return 1;
	if(section  == 1)
		return 1;
	if(section  == 2)
		return 1;
	if(section  == 3)
		return 1;
	if(!self.editing){
		if(section == 4){
			self.sortedChildAreas = nil;
			return [area.children count] + 1;
		}
		else if(section == 5){
			self.sortedProblems = nil;
			return [area.problems count] + 1;
		}
		else if(section == 6){
			self.sortedBeta = nil;
			return [area.beta count] + 1;
		}
	}

	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifierMap = @"MapCell";
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell;
	
	if (indexPath.section == 3){
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMap];
		if (cell == nil) {
			cell = mapTableViewCell;
		}
	}
	else{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.numberOfLines = 0;
			cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
		}
	}
	
	if (indexPath.section == 0){
		cell.imageView.image = nil;
		cell.textLabel.text = area.name;
	}
	else if (indexPath.section == 1){
		cell.imageView.image = nil;
		cell.textLabel.text = area.details;
	}
	else if (indexPath.section == 2){
		cell.imageView.image = nil;
		cell.textLabel.text = area.parent.name;
	}
	if(!self.editing){
		
		if (indexPath.section == 4){
			cell.imageView.image = nil;
			if (indexPath.row < [area.children count]){
				
				if (self.sortedChildAreas == nil){
					
					NSSortDescriptor *nameDescriptor =
					[[[NSSortDescriptor alloc]
					  initWithKey:@"name"
					  ascending:YES
					  selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
					
					NSArray* descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
					self.sortedChildAreas = [[area.children allObjects] sortedArrayUsingDescriptors:descriptors];
				}
				
				Area* theArea = [self.sortedChildAreas objectAtIndex:indexPath.row];
				cell.textLabel.text = theArea.name;
			}
			else
				cell.textLabel.text = @"Add A Sub Area";
		}
		else if (indexPath.section == 5){
			cell.imageView.image = nil;
			if(indexPath.row < [area.problems count]){
				
				if (self.sortedProblems == nil){
					
					NSSortDescriptor *nameDescriptor =
					[[[NSSortDescriptor alloc]
					  initWithKey:@"name"
					  ascending:YES
					  selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
					
					NSArray* descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
					self.sortedProblems = [[area.problems allObjects] sortedArrayUsingDescriptors:descriptors];
					
				}
				
				Problem* problem = [self.sortedProblems objectAtIndex:indexPath.row];
				cell.textLabel.text = problem.name;
				
				
			}
			else
				cell.textLabel.text = @"Add A Climb";
		}
		else if (indexPath.section == 6){
			
			
			
			if(indexPath.row < [area.beta count]){
				
				
				if (self.sortedBeta == nil){
					
					NSSortDescriptor *nameDescriptor =
					[[[NSSortDescriptor alloc]
					  initWithKey:@"name"
					  ascending:YES
					  selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
					
					NSArray* descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
					self.sortedBeta = [[area.beta allObjects] sortedArrayUsingDescriptors:descriptors];
					
				}
				
				Beta* beta = [self.sortedBeta objectAtIndex:indexPath.row];
				cell.textLabel.text = beta.name;
				if([beta.type intValue] == 1)
					cell.imageView.image = [[UIImage imageNamed:@"camera_icon.png"]retain];
				else if([beta.type intValue] == 3)
					cell.imageView.image = [[UIImage imageNamed:@"video_icon.png"]retain];
			}
			else{
				cell.textLabel.text = @"Add Beta";
			}
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section <= 3){
		if (self.editing){
			switch (indexPath.section) {
				case 0: {
					TextEditingViewController *controller = [[TextEditingViewController alloc] init];
					controller.objectBeingEdited = self.area;
					controller.editedFieldKey = @"name";
					controller.editedFieldName = NSLocalizedString(@"area_name", @"display name for name");
					[self.navigationController pushViewController:controller animated:YES];
					[controller release];
				} break;
				case 1: {
					TextEditingViewController *controller = [[TextEditingViewController alloc] init];
					controller.objectBeingEdited = self.area;
					controller.editedFieldKey = @"details";
					controller.editedFieldName = NSLocalizedString(@"area_details", @"display name for author");
					[self.navigationController pushViewController:controller animated:YES];
					[controller release];
				} break;
				case 2: {
					AreasViewController* parentAreaViewController = [[AreasViewController alloc] init];
					parentAreaViewController.managedObjectContext = [self.area managedObjectContext];
					parentAreaViewController.isPicking = YES;
					parentAreaViewController.areaBeingEdited = self.area;
					[self.navigationController pushViewController:parentAreaViewController animated:YES];
					[parentAreaViewController release];
					
				} break;
				case 3: {
					MapViewController *mapViewController = [[MapViewController alloc] init];
					mapViewController.objectBeingEdited = self.area;
					mapViewController.editing = YES;
					[self.navigationController pushViewController:mapViewController animated:YES];
					[mapViewController release];
					
					return;
				} break;
			}
			
		}
		else if(indexPath.section == 2){  // parent area
			if([[area.parent masterId] intValue] != 1){  // if earth, ignore the touch 
				AreaDetailViewController *areaDetailViewController = [[AreaDetailViewController alloc] init];
				Area *selectedArea = area.parent;
				areaDetailViewController.area = selectedArea;
				[self.navigationController pushViewController:areaDetailViewController animated:YES];
				[areaDetailViewController release];
			}
		}
		else if(indexPath.section == 3){ // Map
			MapViewController *mapViewController = [[MapViewController alloc] init];
			mapViewController.areas = [NSSet setWithObject:self.area];
			mapViewController.problems = self.area.problems;
		//	mapViewController.editing = YES;
			[self.navigationController pushViewController:mapViewController animated:YES];
			[mapViewController release];
		}
	}
	
	else if(indexPath.section == 4){ // sub areas
		
		if (indexPath.row < [area.children count]){
			AreaDetailViewController *areaDetailViewController = [[AreaDetailViewController alloc] init];
			Area *selectedArea = [sortedChildAreas objectAtIndex:indexPath.row];				
			areaDetailViewController.area = selectedArea;
			[self.navigationController pushViewController:areaDetailViewController animated:YES];
			[areaDetailViewController release];
		}
		else{
			[self addArea];
		}
	}
	
	else if (indexPath.section == 5){ // problems
		
		if (indexPath.row < [area.problems count]){
			ProblemDetailViewController *problemDetailViewController = [[ProblemDetailViewController alloc] init];
			Problem *selectedProblem = [sortedProblems objectAtIndex:indexPath.row];		
			problemDetailViewController.problem = selectedProblem;
			[self.navigationController pushViewController:problemDetailViewController animated:YES];
			[problemDetailViewController release];
		}
		else{
			[self addProblem];
		}
	}
	else if (indexPath.section == 6){ // beta
		
		if (indexPath.row < [area.beta count]){
			WebViewController *webViewController = [[WebViewController alloc] init];
			Beta *selectedBeta = [sortedBeta	objectAtIndex:indexPath.row];
			
			webViewController.beta = selectedBeta;
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
		else
		{
			[self addBeta];
		}
	}	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

//adding area code:

#pragma mark -
#pragma mark Adding an Area

- (IBAction)addArea {
	
    AreaAddViewController *areaAddViewController = [[AreaAddViewController alloc] init];
	areaAddViewController.delegate = self;
	
	// Create a new managed object context for the new area
	// -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;	
	[addingManagedObjectContext setPersistentStoreCoordinator:[[area managedObjectContext] persistentStoreCoordinator]];
	
	Area*newArea =  (Area *)[NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:addingContext];
	
	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newArea.masterId = tempNum; // MASTER_ID is 0 for new areas
	newArea.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newArea.permission = tempNum;
 	newArea.state = tempNum; // NEW == 1
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithFloat:0.0];
	newArea.latitude = area.latitude;
	newArea.longitude = area.longitude;
	[tempNum release];
	
	newArea.dateAdded = [NSDate date];
	newArea.dateModified = [NSDate date];
	
	newArea.parent = (Area *)[addingContext objectWithID:[self.area objectID]];
	
	areaAddViewController.area = newArea;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:areaAddViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[areaAddViewController release];
	[addingContext release];
	[navController release];
}

- (void)areaAddViewController:(AreaAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
	
}



// add problem


#pragma mark -
#pragma mark Adding an Problem

- (IBAction)addProblem {
	
    ProblemAddViewController *problemAddViewController = [[ProblemAddViewController alloc] init];
	problemAddViewController.delegate = self;
	
	// Create a new managed object context for the new problem -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingManagedObjectContext setPersistentStoreCoordinator:[[area managedObjectContext] persistentStoreCoordinator]];
	
	Problem *newProblem =  (Problem *)[NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:addingContext];
	
	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newProblem.masterId = tempNum;
	newProblem.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newProblem.permission = tempNum;
	
	newProblem.state = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithFloat:0.0];
	newProblem.latitude = self.area.latitude;
	newProblem.longitude = self.area.longitude;
	[tempNum release];
	
	newProblem.dateAdded = [NSDate date];
	newProblem.dateModified = [NSDate date];

	newProblem.area = (Area *)[addingContext objectWithID:[self.area objectID]];
	
	problemAddViewController.problem =newProblem;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:problemAddViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[problemAddViewController release];
	[navController release];
	[addingContext release];
	
}

- (void)problemAddViewController:(ProblemAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];

}




#pragma mark -
#pragma mark Adding Beta

- (void) addBeta{
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Add Beta"
						  message: @"What Type of Beta?:"
						  delegate: self
						  cancelButtonTitle: @"Cancel"
						  otherButtonTitles: @"Web Pic", @"Phone Pic", @"YouTube Vid", @"Text Blurb", nil];
	
	[alert show];
	[alert release];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
		
	
	if(buttonIndex == 0){
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:6 ] animated:YES];
		return; //cancel
	}
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingManagedObjectContext setPersistentStoreCoordinator:[[area managedObjectContext] persistentStoreCoordinator]];
	
	Beta* newBeta =  (Beta *)[NSEntityDescription insertNewObjectForEntityForName:@"Beta" inManagedObjectContext:addingContext];
	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newBeta.masterId = tempNum; // MASTER_ID is 0 for new beta
	newBeta.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newBeta.permission = tempNum;
	newBeta.state = tempNum; // NEW == 1
	[tempNum release];

	newBeta.latitude = self.area.latitude;
	newBeta.longitude = self.area.longitude;
	[tempNum release];
	
	newBeta.dateAdded = [NSDate date];
	newBeta.dateModified = [NSDate date];
	
	if (buttonIndex == 1)
		newBeta.type = [NSNumber numberWithInt:1];
	else if (buttonIndex == 2)
		newBeta.type = [NSNumber numberWithInt:2];
	else if (buttonIndex == 3)
		newBeta.type = [NSNumber numberWithInt:3];
	else if (buttonIndex == 4)
		newBeta.type = [NSNumber numberWithInt:4];
	

	newBeta.problem = 0;
	newBeta.area = (Area *)[addingContext objectWithID:[self.area objectID]];
	BetaAddViewController *betaAddViewController = [[BetaAddViewController alloc] init];
	betaAddViewController.betaForWhat = @"Area";
	betaAddViewController.delegate = self;
	betaAddViewController.beta = newBeta;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:betaAddViewController];
	[self.navigationController presentModalViewController:navController animated:YES];
	
	[betaAddViewController release];
	[navController release];
		
}


- (void)betaAddViewController:(BetaAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
	
}

- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	
	NSManagedObjectContext *context = [self.area managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Map Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	else {
		MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
		
		if ([annotation isKindOfClass:[Problem class]]){
			annView.pinColor = MKPinAnnotationColorGreen;
		}
		if ([annotation isKindOfClass:[Area class]]){
			annView.pinColor = MKPinAnnotationColorRed;
		}
		
		return annView;	
	}
	
	return nil;	
}




#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.mapTableViewCell = nil;
	self.area = nil;
	self.mapView.delegate = nil;
	self.mapView = nil;
	self.sortedBeta = nil;
	self.sortedProblems = nil;
	self.sortedChildAreas = nil;
	self.addingManagedObjectContext = nil;
    [super dealloc];
}

@end

