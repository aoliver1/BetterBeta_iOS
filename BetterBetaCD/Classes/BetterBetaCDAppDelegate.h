//
//  BetterBetaCDAppDelegate.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include "MainMenuViewController.h"

@interface BetterBetaCDAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
	
	UIBarButtonItem * syncingBarItem;
	UIBarButtonItem * progressBarItem;
	
	UIProgressView * progressBar;
	
	MainMenuViewController* mainMenuViewController;

	BOOL syncing;
}

- (IBAction)saveAction:sender;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) UIBarButtonItem * syncingBarItem;
@property (nonatomic, retain) UIBarButtonItem * progressBarItem;
@property (nonatomic, retain) UIProgressView * progressBar;
@property (nonatomic, retain) MainMenuViewController* mainMenuViewController;

@property (nonatomic, assign, getter=isSyncing) BOOL syncing;

@end

