

#import "BetaAddViewController.h"
#import "Beta.h"

@implementation BetaAddViewController

@synthesize delegate;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
    // Override the DetailViewController viewDidLoad with different navigation bar items and title.
    self.title = @"New Beta";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self action:@selector(save:)] autorelease];
	
	// Set up the undo manager and set editing state to YES.
	//[self setUpUndoManager];
	self.editing = YES;
}




- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
//	[self cleanUpUndoManager];	
}


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)cancel:(id)sender {
	[delegate betaAddViewController:self didFinishWithSave:NO];
}
- (void)save:(id)sender {
	if ([self validateFields])
		[delegate betaAddViewController:self didFinishWithSave:YES];
}

-(BOOL)validateFields{
	
	NSString* error = nil;
	
	NSString* description = [self.beta description];
	NSLog(@"%@",description);
	if ([self.beta.name isEqualToString:@""] || self.beta.name == nil) {
		error = @"Beta has to have a name";
	}
	NSLog(@"%@",description);
	if ([self.beta.path isEqualToString:@""] || [self.beta.details isEqualToString:@""]) {
		error = @"Must have text or media";
	}
	
	if (error != nil) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Saving Error"
							  message: error
							  delegate: self
							  cancelButtonTitle: @"OK"
							  otherButtonTitles: nil];
		
		[alert show];
		[alert release];
		
		return NO;
	}
	
	return YES;
	
}

@end
