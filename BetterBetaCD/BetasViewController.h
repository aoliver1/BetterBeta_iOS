//
//  RootViewController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "BetaAddViewController.h"

@interface BetasViewController : UITableViewController <NSFetchedResultsControllerDelegate, BetaAddViewControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSManagedObjectContext *addingBetaManagedObjectContext;
	Beta * newBeta;
	BOOL didSelectAreaOrProblem;
	NSString *betaForWhat;
	NSInteger *betaType;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingBetaManagedObjectContext;
@property (nonatomic, retain) Beta * newBeta;
- (IBAction) addBeta;

@end
