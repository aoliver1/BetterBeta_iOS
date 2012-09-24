

#import "TextEditingViewController.h"

@implementation TextEditingViewController

@synthesize textView, objectBeingEdited, editedFieldName, editedFieldKey;


#pragma mark -
#pragma mark View lifecycle


-( void) loadView{
	
	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,320.0, 200)];
	self.textView.font = [UIFont fontWithName:@"Helvetica" size:17.0];
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 436.0)];
	[self.view addSubview:self.textView];
	
	// Configure the save and cancel buttons.
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	textView.text = [objectBeingEdited valueForKey:editedFieldKey];
	[textView becomeFirstResponder];
}


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save {

	[objectBeingEdited setValue:textView.text forKey:editedFieldKey];
		
	objectBeingEdited.state = [NSNumber numberWithInt:2]; // for DIRTY
	objectBeingEdited.dateModified = [NSDate date];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel {
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}
	
#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  //  [dateAddedDatePicker release];
    [objectBeingEdited release];
    [editedFieldKey release];
    [editedFieldName release];
	[super dealloc];
}


@end

