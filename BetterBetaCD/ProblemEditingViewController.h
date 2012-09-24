
#import "Problem.h"
#import "Area.h"

@interface ProblemEditingViewController : UIViewController {
	
	UITextField *textField;
	
	UIPickerView* pickerView;
	NSArray *areasArray;
	
    NSString *textValue;	// actual new/edited value
    NSString *editedFieldKey; // aka 'name', 'details', for key-value coding
	NSString *editedFieldName; // aka "The Name Of The Climb"
	
    Area *pickedArea;	
	
    Problem *problemBeingEdited;
	
	// core data stack
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSArray *areasArray;

@property (nonatomic, retain) Area *pickedArea;
@property (nonatomic, retain) Problem *problemBeingEdited;
@property (nonatomic, retain) NSString *editedFieldName;
@property (nonatomic, retain) NSString *editedFieldKey;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel;
- (IBAction)save;

@end

