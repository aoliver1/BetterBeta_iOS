//
//  RootViewController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ProblemsViewController.h"
#import "Problem.h"
#import "BetterBetaCDAppDelegate.h"
#import "Beta.h"

@implementation ProblemsViewController

@synthesize fetchedResultsController, managedObjectContext, addingProblemManagedObjectContext, 
									filteredListContent, searchIsActive, pickerDelegate, searchBar;


- (void)loadView {
    [super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
    
	
	self.tableView.backgroundColor = [UIColor blackColor];
	self.title = @"Climbs";
	
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.tableView.bounds];
    [searchBar sizeToFit]; // Get the default height for a search bar.
    self.searchBar.delegate = self;
	self.searchBar.showsCancelButton = YES; 
	self.searchBar.barStyle = UIBarStyleBlackTranslucent;
	
    self.tableView.tableHeaderView = searchBar;
	
	UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];  
	
	[self performSelector:@selector(setSearchDisplayController:) withObject:searchDisplayController];
	
    [searchDisplayController setDelegate:self];  
    [searchDisplayController setSearchResultsDataSource:self];  
    [searchDisplayController setSearchResultsDelegate:self];
    [searchDisplayController release];  
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
	
	// Configure the add button.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProblem)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
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
	Problem *problem = nil;
	if (self.searchIsActive)
		problem = (Problem*)[[self filteredListContent] objectAtIndex:[indexPath row]];
	else
		problem = (Problem*)[fetchedResultsController objectAtIndexPath:indexPath];
	
	
	@try {
		problem.name;
	}
	@catch (NSException * e) {
		[fetchedResultsController performFetch:nil];
	}
	
	if ([problem.beta count] > 0) {
		Beta* beta = [[problem.beta allObjects] objectAtIndex:0];
		if([beta.type intValue] == 1)
			cell.imageView.image = [[UIImage imageNamed:@"camera_icon.png"]retain];
		else if([beta.type intValue] == 3)
			cell.imageView.image = [[UIImage imageNamed:@"video_icon.png"]retain];
	}
	else {
		cell.imageView.image = nil;
	}

		
	cell.textLabel.text = problem.name;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProblemsCell";
    
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
	
	ProblemDetailViewController *problemDetailViewController = [[ProblemDetailViewController alloc] init];
	Problem *selectedProblem;
	
	if (self.searchIsActive)
		selectedProblem = [[self filteredListContent] objectAtIndex:[indexPath row]];
	else
		selectedProblem = [fetchedResultsController objectAtIndexPath:indexPath];
	
	problemDetailViewController.problem = selectedProblem;
	[self.navigationController pushViewController:problemDetailViewController animated:YES];
	[problemDetailViewController release];
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
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
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
#pragma mark Adding an Problem

- (IBAction)addProblem {
	
    ProblemAddViewController *problemAddViewController = [[ProblemAddViewController alloc] init];
	problemAddViewController.delegate = self;
	
	// Create a new managed object context for the new problem -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingProblemContext = [[NSManagedObjectContext alloc] init];
	self.addingProblemManagedObjectContext = addingProblemContext;
	[addingProblemManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
	
	Problem *newProblem =  (Problem *)[NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:addingProblemContext];
	
	NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
	newProblem.masterId = tempNum;
	newProblem.idType = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithInt:1];
	newProblem.permission = tempNum;
	
	newProblem.state = tempNum;
	[tempNum release];
	
	tempNum = [[NSNumber alloc] initWithFloat:0.0];
	newProblem.latitude = tempNum;
	newProblem.longitude = tempNum;
	[tempNum release];
	
	newProblem.dateAdded = [NSDate date];
	newProblem.dateModified = [NSDate date];
	
	//FETCH EARTH AS DEFAULT AREA
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Area" inManagedObjectContext:addingProblemContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId == %d", 1];  // 1== EARTH, need to set as static somewhere
	[fetchRequest setPredicate:predicate];
	NSArray *arrayWithEarth = [addingProblemContext executeFetchRequest:fetchRequest error:&error];
	
	newProblem.area = [arrayWithEarth objectAtIndex:0];
	
	problemAddViewController.problem =newProblem;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:problemAddViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[problemAddViewController release];
	[navController release];
	[addingProblemContext release];
}

- (void)problemAddViewController:(ProblemAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingProblemManagedObjectContext];
		
		NSError *error;
		if (![addingProblemManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingProblemManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingProblemManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}


- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	[[fetchedResultsController managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];	
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Fetched results controller

/**
 Delegate method of NSFethcedResultsController to respond to additions, removals and so on.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// Reload the table view, provided that the controller is not in editing state.
	if (!self.editing) {
		[self.tableView reloadData];
	}
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




- (void)dealloc {
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
	self.addingProblemManagedObjectContext = nil;
	self.searchBar = nil;
	self.filteredListContent = nil;
	self.pickerDelegate = nil;
    [super dealloc];
}


@end

