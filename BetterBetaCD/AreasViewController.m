
//
//  RootViewController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AreasViewController.h"
#import "Area.h"
#import "BetterBetaCDAppDelegate.h"

@implementation AreasViewController

@synthesize fetchedResultsController, 
managedObjectContext, 
addingAreaManagedObjectContext,
filteredListContent,
searchIsActive,
isPicking,
areaBeingEdited,
problemBeingEdited,
searchBar;




- (void)loadView {
    [super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	
	self.tableView.backgroundColor = [UIColor blackColor];
	
	if (isPicking) {
		self.title = @"Choose an Area";
	}
	else {
		self.title = @"Areas";
	}
	
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.tableView.bounds];
    [searchBar sizeToFit]; // Get the default height for a search bar.
    self.searchBar.delegate = self;
	self.searchBar.showsCancelButton = YES; 
	self.searchBar.tintColor = [UIColor blackColor];
	
    self.tableView.tableHeaderView = searchBar;
	
	UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];  
	
	[self performSelector:@selector(setSearchDisplayController:) withObject:searchDisplayController];
	
    [searchDisplayController setDelegate:self];  
    [searchDisplayController setSearchResultsDataSource:self];  
    [searchDisplayController setSearchResultsDelegate:self];
    [searchDisplayController release];  
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
	
	if(isPicking){
		UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];		
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	}
	else {
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addArea)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
	}
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	
}

-(void) goBack{
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
    if (isPicking && (problemBeingEdited != nil || (areaBeingEdited != nil && areaBeingEdited.parent.masterId != [NSNumber numberWithInt:1]) )) {
		
		int row = -1;
		for (int i = 0; i < [fetchedResultsController.fetchedObjects count] ; i++) {
			if (areaBeingEdited != nil && [[fetchedResultsController.fetchedObjects objectAtIndex:i] isEqual:areaBeingEdited.parent]) {
				row = i;
				break;
			}
			else if (problemBeingEdited != nil && [[fetchedResultsController.fetchedObjects objectAtIndex:i] isEqual:problemBeingEdited.area]) {
				row = i;
				break;
			}
		}
		
		if (row >= 0) {
			NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
			[[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
			[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:row];
		}
       
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.searchIsActive) {
		return [self.filteredListContent count];
	}
	
	NSInteger numberOfRows = 0;
	
	if ([[fetchedResultsController sections] count] > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		numberOfRows = [sectionInfo numberOfObjects];
	}
	
	return numberOfRows;
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Area *theArea = nil;
	if (self.searchIsActive)
		theArea = (Area*)[[self filteredListContent] objectAtIndex:[indexPath row]];
	else
		theArea = (Area*)[fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%i)", [theArea valueForKey:@"name"], [theArea.problems count]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AreasCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.isPicking) {
		
		Area *selectedArea = nil;
		
		if (self.searchIsActive)
			selectedArea = [[self filteredListContent] objectAtIndex:[indexPath row]];
		else
			selectedArea = [fetchedResultsController objectAtIndexPath:indexPath];
		
		if (areaBeingEdited != nil) {
			[areaBeingEdited setValue:selectedArea forKey:@"parent"];
			areaBeingEdited.state = [NSNumber numberWithInt:2]; // for DIRTY
			areaBeingEdited.dateModified = [NSDate date];
			
		}
		else if (problemBeingEdited != nil){
			[problemBeingEdited setValue:selectedArea forKey:@"area"];
			problemBeingEdited.state = [NSNumber numberWithInt:2]; // for DIRTY
			problemBeingEdited.dateModified = [NSDate date];
			
			
		}
		[self.navigationController popViewControllerAnimated:YES];
		
	}
	else {
		
		AreaDetailViewController *areaDetailViewController = [[AreaDetailViewController alloc] init];
		Area *selectedArea = nil;

		if (self.searchIsActive)
			selectedArea = [[self filteredListContent] objectAtIndex:[indexPath row]];
		else
			selectedArea = [fetchedResultsController objectAtIndexPath:indexPath];
		
		areaDetailViewController.area = selectedArea;
		
		[self.navigationController pushViewController:areaDetailViewController animated:YES];
		[areaDetailViewController release];

	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    NSString *cellText = [[managedObject valueForKey:@"name"] description];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 20;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		[tableView reloadData];
		//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Area" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId != %d", 1];
	[fetchRequest setPredicate:predicate];
	
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

#pragma mark -
#pragma mark Adding an Area

- (void)addArea {
	
    AreaAddViewController *areaAddViewController = [[AreaAddViewController alloc] init];
	areaAddViewController.delegate = self;
	
	// Create a new managed object context for the new area -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingAreaContext = [[NSManagedObjectContext alloc] init];
	self.addingAreaManagedObjectContext = addingAreaContext;	
	[addingAreaManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
	
	Area*newArea =  (Area *)[NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:addingAreaContext];

	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newArea.masterId = tempNum; // MASTER_ID is 0 for new areas
	newArea.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newArea.permission = tempNum;
 	newArea.state = tempNum; // NEW == 1
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithFloat:0.0];
	newArea.latitude = tempNum;
	newArea.longitude = tempNum;
	[tempNum release];
	
	newArea.dateAdded = [NSDate date];
	newArea.dateModified = [NSDate date];
	
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Area" inManagedObjectContext:addingAreaContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId == %d", 1];  // 1== EARTH, need to set as static somewhere
	[fetchRequest setPredicate:predicate];
	NSArray *arrayWithEarth = [addingAreaContext executeFetchRequest:fetchRequest error:&error];
	
	newArea.parent = [arrayWithEarth objectAtIndex:0];

	areaAddViewController.area =newArea;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:areaAddViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[areaAddViewController release];
	[addingAreaContext release];
	[navController release];
}

- (void)areaAddViewController:(AreaAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingAreaManagedObjectContext];
		
		NSError *error;
		if (![addingAreaManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingAreaManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingAreaManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}


- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	[[fetchedResultsController managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark FetchedResultsController Delegate Methods

/**
 Delegate method of NSFethcedResultsController to respond to additions, removals and so on.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// Reload the table view, provided that the controller is not in editing state.
	//if (!self.editing) {
		[self.tableView reloadData];
//	}
}


#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect bounds = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    CGPoint center = [[[notification userInfo] objectForKey:UIKeyboardCenterEndUserInfoKey] CGPointValue];
    
    // We need to compute the keyboard and table view frames in window-relative coordinates
    CGRect keyboardFrame = CGRectMake(round(center.x - bounds.size.width/2.0), round(center.y - bounds.size.height/2.0), bounds.size.width, bounds.size.height);
    CGRect tableViewFrame = [self.tableView.window convertRect:self.tableView.frame fromView:self.tableView.superview];
    
    // And then figure out where they overlap
    CGRect intersectionFrame = CGRectIntersection(tableViewFrame, keyboardFrame);
    
    // This assumes that no one else cares about the table view's insets...
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, intersectionFrame.size.height, 0);
    [self.tableView setContentInset:insets];
    [self.tableView setScrollIndicatorInsets:insets];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // This assumes that no one else cares about the table view's insets...
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
	self.filteredListContent = [[[self fetchedResultsController] fetchedObjects] filteredArrayUsingPredicate:predicate];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:
	  [self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
	
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	self.searchIsActive = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	self.searchIsActive = NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
	    
    if (searchBar.delegate == self) {
        searchBar.delegate = nil;
    }
	
	self.areaBeingEdited = nil;
	self.problemBeingEdited = nil;
	self.filteredListContent = nil;
	self.searchBar = nil;
	
    [super dealloc];
}


@end


