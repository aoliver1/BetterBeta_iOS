
#import "Area.h"
#import "Beta.h"
#import "Problem.h"
@interface BetaEditingViewController : UIViewController < /* NSFetchedResultsControllerDelegate,*/ UIPickerViewDataSource, UIPickerViewDelegate> {
	//views to be shown
	UITextField *textField;
	
	UIPickerView* pickerView;
	UIPickerView* problemPickerView;
	NSArray *areasArray;
	NSArray *problemsArray;
	
    NSString *textValue;	// actual new/edited value
    NSString *editedFieldKey; // aka 'name', 'details', for key-value coding
	NSString *editedFieldName; // aka "The Name Of The Climb"
	
    Area *pickedArea;	
    Problem *pickedProblem;	
	
    Beta *betaBeingEdited;
	
	// core data stack
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSArray *areasArray;
@property (nonatomic, retain) NSArray *problemsArray;

@property (nonatomic, retain) Area *pickedArea;
@property (nonatomic, retain) Problem *pickedProblem;
@property (nonatomic, retain) Beta *betaBeingEdited;
@property (nonatomic, retain) NSString *editedFieldName;
@property (nonatomic, retain) NSString *editedFieldKey;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel;
- (IBAction)save;

@end

