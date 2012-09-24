//
//  RootViewController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BetasViewController.h"
#import "WebViewController.h"
#import "BetterBetaCDAppDelegate.h"

@implementation BetasViewController

@synthesize fetchedResultsController, managedObjectContext, addingBetaManagedObjectContext, newBeta;


- (void)loadView {
    [super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	
	// Set up the edit and add buttons.
	//   self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
	self.title = @"Beta";
	// Configure the add button.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBeta)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	betaForWhat = @"";
	
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
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BetasCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	
	//NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	
	Beta* beta = [fetchedResultsController objectAtIndexPath:indexPath];

	cell.textLabel.text = beta.name;
	if([beta.type intValue] == 1)
		cell.imageView.image = [[UIImage imageNamed:@"camera_icon.png"]retain];
	else if([beta.type intValue] == 3)
		cell.imageView.image = [[UIImage imageNamed:@"video_icon.png"]retain];
		
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	
	
	WebViewController *webViewController = [[WebViewController alloc] init];
    Beta *selectedBeta = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	webViewController.beta = selectedBeta;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
	
	
	
	
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
    // The table view should not be re-orderable.
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Beta" inManagedObjectContext:managedObjectContext];
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
#pragma mark Adding an Beta

- (IBAction)addBeta {
	

	
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Add Beta"
						  message: @"Is This Beta For A:"
						  delegate: self
						  cancelButtonTitle: @"Problem"
						  otherButtonTitles: @"Area", nil];
	
	[alert show];
	[alert release];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(betaForWhat == @""){
		if(buttonIndex == 0)//Problem
			betaForWhat = @"Problem";
		else
			betaForWhat = @"Area";
	
		//Launch 2nd Alert View
		
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Add Beta"
							  message: @"What Type of Beta?:"
							  delegate: self
							  cancelButtonTitle: @"Text Blurb"
							  otherButtonTitles: @"Web Pic", @"Phone Pic", @"YouTube Vid", nil];
		
		[alert show];
		[alert release];
	
	}
	else{
			
		NSManagedObjectContext *addingBetaContext = [[NSManagedObjectContext alloc] init];
		self.addingBetaManagedObjectContext = addingBetaContext;
		[addingBetaManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
		
		self.newBeta =  (Beta *)[NSEntityDescription insertNewObjectForEntityForName:@"Beta" inManagedObjectContext:addingBetaContext];
		NSNumber * tempNum =[[NSNumber alloc] initWithInt:0];
		newBeta.masterId = tempNum; // MASTER_ID is 0 for new beta
		newBeta.idType = tempNum;
		[tempNum release];
		
		tempNum = [[NSNumber alloc] initWithInt:1];
		newBeta.permission = tempNum;
		newBeta.state = tempNum; // NEW == 1
		[tempNum release];
		
		tempNum = [[NSNumber alloc] initWithFloat:0.0];
		newBeta.latitude = tempNum;
		newBeta.longitude = tempNum;
		[tempNum release];
		
		newBeta.dateAdded = [NSDate date];
		newBeta.dateModified = [NSDate date];
		
		if(buttonIndex == 0)
			newBeta.type = [NSNumber numberWithInt:4];  //TEXT BLURB
		else if (buttonIndex == 1)
			newBeta.type = [NSNumber numberWithInt:1];
		else if (buttonIndex == 2)
			newBeta.type = [NSNumber numberWithInt:2];
		else if (buttonIndex == 3)
			newBeta.type = [NSNumber numberWithInt:3];
		
		newBeta.problem = 0;
		newBeta.area = 0;
		BetaAddViewController *betaAddViewController = [[BetaAddViewController alloc] init];
		betaAddViewController.betaForWhat = betaForWhat;
		betaAddViewController.delegate = self;
		betaAddViewController.beta = self.newBeta;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:betaAddViewController];
		[self.navigationController presentModalViewController:navController animated:YES];
		
		[betaAddViewController release];
		[navController release];
		
		betaForWhat = @""; //reset in case of cancel and adding multiple betas
	}
}

- (void)betaAddViewController:(BetaAddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingBetaManagedObjectContext];
		
		NSError *error;
		if (![addingBetaManagedObjectContext save:&error]) {
			// Handle the error.
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingBetaManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingBetaManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}


- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
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

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end

