//
//  RootViewController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "AreaAddViewController.h"
#import "Problem.h"

@interface AreasViewController : UITableViewController <NSFetchedResultsControllerDelegate, AreaAddViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	NSFetchedResultsController*	fetchedResultsController;
	NSManagedObjectContext*		managedObjectContext;
    NSManagedObjectContext*		addingAreaManagedObjectContext;	   
	
    UISearchBar*				searchBar;
	NSArray	*					filteredListContent;
    BOOL						searchIsActive;	
	
	BOOL						isPicking;
    Area *						areaBeingEdited;
	Problem*					problemBeingEdited;
}

@property (nonatomic, retain) NSArray *filteredListContent;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingAreaManagedObjectContext;
@property (nonatomic) BOOL searchIsActive;

@property (nonatomic) BOOL isPicking;
@property (nonatomic, retain) Area *areaBeingEdited;
@property (nonatomic, retain) Problem *problemBeingEdited;
@property (nonatomic, retain) UISearchBar* searchBar;

- (IBAction) addArea;

@end

