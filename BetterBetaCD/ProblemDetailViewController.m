#import <QuartzCore/QuartzCore.h>

#import "ProblemDetailViewController.h"
#import "AreaDetailViewController.h"
#import "Problem.h"
#import "Area.h"
#import "TextEditingViewController.h"
#import "BetaDetailViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"
#import "BetterBetaCDAppDelegate.h"
#import "AreasViewController.h"

@implementation ProblemDetailViewController

@synthesize problem, mapView, mapTableViewCell, addingManagedObjectContext, sortedBeta;

#pragma mark -
#pragma mark View lifecycle

-(void)mapThis{
	MapViewController *mapViewController = [[MapViewController alloc] init];
	mapViewController.problems = [NSArray arrayWithObject:self.problem];	
	[self.navigationController pushViewController:mapViewController animated:YES];
	[mapViewController release];
}


- (void)loadView {
    [super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	
	self.tableView.backgroundColor = [UIColor blackColor];
	
	self.mapTableViewCell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	
	self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 166)] autorelease];
	self.mapView.layer.cornerRadius = 8;
	self.mapView.showsUserLocation = YES;
	[self.mapTableViewCell.contentView addSubview:self.mapView];
	
	self.title = problem.name;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	// Add Pin for Area
	[mapView addAnnotation:self.problem];
	[mapView setCenterCoordinate:problem.coordinate animated:NO];
	
	// Set Zoom Level
	MKCoordinateSpan span;
	MKCoordinateRegion region;
	region.center=problem.coordinate;
	span.latitudeDelta=1.5;
	span.longitudeDelta=1.5;
	region.span=span;
	[mapView setRegion:region animated:FALSE];
	//mapView.delegate = self;
	[mapView setUserInteractionEnabled:NO];
	
}

- (void)viewWillAppear:(BOOL)animated {
    // Redisplay the data.
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
	
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [self.tableView reloadData];
	
	/*
	 When editing starts, create and set an undo manager to track edits. Then register as an observer of undo manager change notifications, so that if an undo or redo operation is performed, the table view can be reloaded.
	 When editing ends, de-register from the notification center and remove the undo manager, and save the changes.
	 */
	if (!editing) {
		NSError *error;
		if (![problem.managedObjectContext save:&error]) {
			// Handle the error.
		}
	}
}

- (void)updateRightBarButtonItemState {
	self.navigationItem.rightBarButtonItem.enabled = [problem validateForUpdate:NULL];
}	


#pragma mark -
#pragma mark Table view data source methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 4)
		return 165;

	else {
		
		NSString *cellText = @"";
		
		if(indexPath.section == 0){
			cellText = problem.name;
		}
		else if(indexPath.section == 1){
			cellText = problem.details;
		}
		else if (indexPath.section == 2){
			cellText = [problem.area name];
		}
		else if (indexPath.section == 3){
			cellText = @"V4++";
		}

		else if (indexPath.section == 5){
			if(indexPath.row < [problem.beta count])
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.editing) {
		return 5;
	}
	else {
		return 6;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"Name";
	else if(section == 1)
		return @"Details";
	else if(section == 2)
		return @"Area";
	else if(section == 3)
		return @"Rating";
	else if(section == 4)
		return @"Location";
	else if(section == 5)
		return @"Beta";
	else
		return @"";
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
 	if(section == 0)
		return 1;
	else if(section == 1)
		return 1;
	else if(section == 2)
		return 1;
	else if(section == 3)
		return 1;
	else if(section == 4)
		return 1;
	else if(section == 5){
		self.sortedBeta = nil;
		return [problem.beta count] + 1;
	}
	else
		return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifierMap = @"MapCell";
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell;
	if (indexPath.section == 4){
		
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
	
	if(indexPath.section == 0){
		cell.imageView.image = nil;
		cell.textLabel.text = problem.name;
	}
	else if(indexPath.section == 1){
		cell.imageView.image = nil;
		cell.textLabel.text = problem.details;
	}
	else if (indexPath.section == 2){
		cell.imageView.image = nil;
		cell.textLabel.text = [problem.area name];
	}
	else if (indexPath.section == 3){
		cell.imageView.image = nil;
		cell.textLabel.text = @"V4++";
	}
	else if (indexPath.section == 5){
		if(indexPath.row < [problem.beta count]){
			
			if (self.sortedBeta == nil){
				
				NSSortDescriptor *nameDescriptor =
				[[[NSSortDescriptor alloc]
				  initWithKey:@"name"
				  ascending:YES
				  selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
				
				NSArray* descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
				self.sortedBeta = [[problem.beta allObjects] sortedArrayUsingDescriptors:descriptors];
			
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
		
    return cell;
}

/**
 Manage row selection: If a row is selected, create a new editing view controller to edit the property associated with the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section <= 4){
		if (self.editing) {
			switch (indexPath.section) {
				case 0: {
					TextEditingViewController *controller = [[TextEditingViewController alloc] init];
					controller.objectBeingEdited = self.problem;
					controller.editedFieldKey = @"name";
					controller.editedFieldName = NSLocalizedString(@"problem", @"display name for name");
					[self.navigationController pushViewController:controller animated:YES];
					[controller release];
				} break;
				case 1: {
					TextEditingViewController *controller = [[TextEditingViewController alloc] init];
					controller.objectBeingEdited = self.problem;
					controller.editedFieldKey = @"details";
					controller.editedFieldName = NSLocalizedString(@"details", @"display name for details");
					[self.navigationController pushViewController:controller animated:YES];
					[controller release];
				} break;
				case 2: {
					
					AreasViewController* parentAreaViewController = [[AreasViewController alloc] init];
					parentAreaViewController.managedObjectContext = [self.problem managedObjectContext];
					parentAreaViewController.isPicking = YES;
					parentAreaViewController.problemBeingEdited = self.problem;
					[self.navigationController pushViewController:parentAreaViewController animated:YES];
					[parentAreaViewController release];
				} break;
				case 3: {
					TextEditingViewController *controller = [[TextEditingViewController alloc] init];
					controller.objectBeingEdited = self.problem;
					controller.editedFieldKey = @"rating";
					controller.editedFieldName = NSLocalizedString(@"area_parent", @"display name for author");
					[self.navigationController pushViewController:controller animated:YES];
					[controller release];
					//			controller.areasArray = self.areasArray;
				} break;
				case 4: {
					MapViewController *mapViewController = [[MapViewController alloc] init];
					mapViewController.objectBeingEdited = self.problem;
					mapViewController.editing = YES;
					[self.navigationController pushViewController:mapViewController animated:YES];
					[mapViewController release];
					
					return;
				} break;
					
			}
			return;
		}
		else if(indexPath.section == 2){
			if([[problem.area masterId] intValue] != 1){
				AreaDetailViewController *areaDetailViewController = [[AreaDetailViewController alloc] init];
				Area *selectedArea = problem.area;
				areaDetailViewController.area = selectedArea;
				[self.navigationController pushViewController:areaDetailViewController animated:YES];
				[areaDetailViewController release];
			}
		}else if(indexPath.section == 4){ // Map
			MapViewController *mapViewController = [[MapViewController alloc] init];
			mapViewController.problems = [NSSet setWithObject:self.problem];
			[self.navigationController pushViewController:mapViewController animated:YES];
			[mapViewController release];
		}
		
	}
	
	else if (indexPath.section == 5){  //Beta
		
		if (indexPath.row < [problem.beta count]){
			WebViewController *webViewController = [[WebViewController alloc] init];
			Beta *selectedBeta = [self.sortedBeta	objectAtIndex:indexPath.row];
			
			webViewController.beta = selectedBeta;
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
		else{
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


// add beta

- (void) addBeta{
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Add Beta"
						  message: @"What Type of Beta?:"
						  delegate: self
						  cancelButtonTitle: @"Text Blurb"
						  otherButtonTitles: @"Web Pic", @"Phone Pic", @"YouTube Vid", nil];
	
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	
	if(buttonIndex == 0){
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5 ] animated:YES];
		return; //cancel
	}
	
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingManagedObjectContext setPersistentStoreCoordinator:[[problem managedObjectContext] persistentStoreCoordinator]];
	
	Beta* newBeta =  (Beta *)[NSEntityDescription insertNewObjectForEntityForName:@"Beta" inManagedObjectContext:addingContext];
	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newBeta.masterId = tempNum; // MASTER_ID is 0 for new beta
	newBeta.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newBeta.permission = tempNum;
	newBeta.state = tempNum; // NEW == 1
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithFloat:0.0];
	newBeta.latitude = self.problem.latitude;
	newBeta.longitude = self.problem.longitude;
	[tempNum release];
	
	newBeta.dateAdded = [NSDate date];
	newBeta.dateModified = [NSDate date];

	if (buttonIndex == 1)
		newBeta.type = [NSNumber numberWithInt:1];
	else if (buttonIndex == 2)
		newBeta.type = [NSNumber numberWithInt:2];
	else if (buttonIndex == 3)
		newBeta.type = [NSNumber numberWithInt:3];
	else if(buttonIndex == 4)
		newBeta.type = [NSNumber numberWithInt:4];  //TEXT BLURB
	
	newBeta.problem = (Problem *)[addingContext objectWithID:[self.problem objectID]];

	BetaAddViewController *betaAddViewController = [[BetaAddViewController alloc] init];
	betaAddViewController.betaForWhat = @"Problem";
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
	
	NSManagedObjectContext *context = [self.problem managedObjectContext];
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
	[self.tableView reloadData];
}



- (BOOL)canBecomeFirstResponder {
	return YES;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resignFirstResponder];
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
 
	self.mapView = nil;
	self.mapTableViewCell = nil;
	self.addingManagedObjectContext = nil;
    self.problem = nil;
	self.sortedBeta = nil;
    
	[super dealloc];
}

@end

