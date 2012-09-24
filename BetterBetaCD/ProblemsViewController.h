//
//  RootViewController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "ProblemAddViewController.h"

@interface ProblemsViewController : UITableViewController <NSFetchedResultsControllerDelegate, ProblemAddViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSManagedObjectContext *addingProblemManagedObjectContext;	

    UISearchBar *searchBar;
	id pickerDelegate;
	NSArray			*filteredListContent;	
    BOOL			searchIsActive;	
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingProblemManagedObjectContext;

@property (nonatomic, retain) UISearchBar *searchBar;

@property (nonatomic, retain) NSArray *filteredListContent;
@property (nonatomic, retain) id pickerDelegate;

@property (nonatomic) BOOL searchIsActive;


- (IBAction) addProblem;

@end
