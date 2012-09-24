

#import "BetaEditingViewController.h"

@implementation BetaEditingViewController

@synthesize textField, betaBeingEdited, editedFieldName, editedFieldKey, pickerView, pickedArea, pickedProblem, areasArray, problemsArray, managedObjectContext, fetchedResultsController;


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
	
	
	if(editedFieldKey == @"area"){
		self.managedObjectContext = [betaBeingEdited managedObjectContext];
		if (![[self fetchedResultsController] performFetch:&error]) {
			// Handle the error...
		}
		areasArray = [fetchedResultsController fetchedObjects];
	}
	else if(editedFieldKey == @"problem"){
		self.managedObjectContext = [betaBeingEdited managedObjectContext];
		if (![[self fetchedResultsController] performFetch:&error]) {
			// Handle the error...
		}
		problemsArray = [fetchedResultsController fetchedObjects];
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if(editedFieldKey == @"area"){
		if (betaBeingEdited.area != nil){
			int i = 0;
			for(Area* area in areasArray){
				if([area objectID] == [betaBeingEdited.area objectID])
					break;
				i++;
			}
			[pickerView selectRow:i inComponent:0 animated:NO];
			
		}
        textField.hidden = YES;
		pickerView.hidden = NO;
		pickerView.showsSelectionIndicator = YES;
	}
	else if(editedFieldKey == @"problem"){
		if (betaBeingEdited.problem != nil){
			int i = 0;
			for(Problem* problem in problemsArray){
				if([problem objectID] == [betaBeingEdited.problem objectID])
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
		pickerView.hidden = YES;
        textField.text = [betaBeingEdited valueForKey:editedFieldKey];
		textField.placeholder = self.title;
        [textField becomeFirstResponder];
	}
}


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save {
	
	// Set the action name for the undo operation.
	//NSUndoManager * undoManager = [[(NSManagedObject *)betaBeingEdited managedObjectContext] undoManager];
	//[undoManager setActionName:[NSString stringWithFormat:@"%@", editedFieldName]];
	
	if(editedFieldKey == @"area"){
		[betaBeingEdited setValue:[areasArray objectAtIndex:[pickerView selectedRowInComponent:0]]  forKey:editedFieldKey];
	}
	else if(editedFieldKey == @"problem"){
		[betaBeingEdited setValue:[problemsArray objectAtIndex:[pickerView selectedRowInComponent:0]]  forKey:editedFieldKey];
	}
	else
		[betaBeingEdited setValue:textField.text forKey:editedFieldKey];
	
	betaBeingEdited.state = [NSNumber numberWithInt:2]; // for DIRTY
	betaBeingEdited.dateModified = [NSDate date];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel {
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark FetchedResultsController Delegate Methods


#pragma mark -
#pragma mark UIPickerViewDataSource delegate methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(editedFieldKey == @"area")
		return [areasArray count];
	else if (editedFieldKey == @"problem")
		return [problemsArray count];
	else 
		return 0;
}


#pragma mark -
#pragma mark UIPickerViewDelegate delegate methods


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	
	if(editedFieldKey == @"area")
		return [[areasArray objectAtIndex:row] name];
	else if(editedFieldKey == @"problem")
		return [[problemsArray objectAtIndex:row] name];
	else 
		return 0;
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity;
	if(editedFieldKey == @"area")
		entity= [NSEntityDescription entityForName:@"Area" inManagedObjectContext:managedObjectContext];
	else if(editedFieldKey == @"problem")
		entity= [NSEntityDescription entityForName:@"Problem" inManagedObjectContext:managedObjectContext];
		
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	
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
	//  [dateAddedDatePicker release];
    [betaBeingEdited release];
    [editedFieldKey release];
    [editedFieldName release];
	[super dealloc];
}


@end

