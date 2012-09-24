

#import "ProblemEditingViewController.h"

@implementation ProblemEditingViewController

@synthesize textField, problemBeingEdited, editedFieldName, editedFieldKey, pickerView, pickedArea, areasArray, managedObjectContext, fetchedResultsController;



#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	// Set the title to the user-visible name of the field.
	self.title = editedFieldName;
	
	// Configure the save and cancel buttons.
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	NSError *error = nil;
	self.managedObjectContext = [problemBeingEdited managedObjectContext];
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
	
	
	areasArray = [fetchedResultsController fetchedObjects];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if(editedFieldKey == @"area"){
		if (problemBeingEdited.area != nil){
			int i = 0;
			for(Area* area in areasArray){
				if([area objectID] == [problemBeingEdited.area objectID])
					break;
				i++;
			}
			[pickerView selectRow:i inComponent:0 animated:NO];
			
		}
        textField.hidden = YES;
		pickerView.hidden = NO;
		pickerView.showsSelectionIndicator = YES;
	}
	else{
        textField.hidden = NO;
		pickerView.hidden = YES;
        textField.text = [problemBeingEdited valueForKey:editedFieldKey];
		textField.placeholder = self.title;
        [textField becomeFirstResponder];
	}
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save {
	
	// Set the action name for the undo operation.
	//NSUndoManager * undoManager = [[(NSManagedObject *)areaBeingEdited managedObjectContext] undoManager];
	//[undoManager setActionName:[NSString stringWithFormat:@"%@", editedFieldName]];
	
	if(editedFieldKey == @"area"){
		[problemBeingEdited setValue:[areasArray objectAtIndex:[pickerView selectedRowInComponent:0]]  forKey:editedFieldKey];
	}
	else
		[problemBeingEdited setValue:textField.text forKey:editedFieldKey];
	
	problemBeingEdited.state = [NSNumber numberWithInt:2]; // for DIRTY
	problemBeingEdited.dateModified = [NSDate date];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel {
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark UIPickerViewDataSource delegate methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [areasArray count];
}


#pragma mark -
#pragma mark UIPickerViewDelegate delegate methods


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [[areasArray objectAtIndex:row] name];
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
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	//    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    





#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [problemBeingEdited release];
    [editedFieldKey release];
    [editedFieldName release];
	[super dealloc];
}


@end

