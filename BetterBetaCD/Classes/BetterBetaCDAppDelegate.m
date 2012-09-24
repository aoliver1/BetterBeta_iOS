//
//  BetterBetaCDAppDelegate.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BetterBetaCDAppDelegate.h"
#import "MainMenuViewController.h"


@implementation BetterBetaCDAppDelegate

@synthesize window, navigationController, syncing, syncingBarItem, progressBarItem, progressBar, mainMenuViewController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	UIWindow *myWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window = myWindow;
	[myWindow release];
	
	self.mainMenuViewController = [[[MainMenuViewController alloc] init] autorelease];
	
	mainMenuViewController.managedObjectContext = self.managedObjectContext;
	[navigationController setToolbarHidden:YES];
	
	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:mainMenuViewController] autorelease];

	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	UILabel * syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
	syncLabel.text = @"Syncing";
	syncLabel.textColor = [UIColor redColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	self.syncingBarItem = [[[UIBarButtonItem alloc] initWithCustomView:syncLabel] autorelease];
	[syncLabel release];
	
	self.progressBar = [[[UIProgressView alloc] initWithFrame:CGRectMake(0, 20, 230, 10)] autorelease];
	self.progressBarItem = [[UIBarButtonItem alloc] initWithCustomView:progressBar];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}


- (void) setSyncing:(BOOL)nowSyncing{
	if (syncing && nowSyncing == NO) {
		[mainMenuViewController syncComplete];
	}
	syncing = nowSyncing;
	[navigationController setToolbarHidden:!syncing animated:YES];
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
	//	[managedObjectContext setRetainsRegisteredObjects:YES];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"BetterBeta.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
//	[toolbar release];
	[window release];
	[super dealloc];
}


@end

