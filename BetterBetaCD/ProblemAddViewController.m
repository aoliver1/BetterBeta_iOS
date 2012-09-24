

#import "ProblemAddViewController.h"
#import "Problem.h"
#import "Area.h"
@implementation ProblemAddViewController

@synthesize delegate;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
    self.title = @"New Problem";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self action:@selector(save:)] autorelease];
	self.editing = YES;
}


- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Save and cancel operations

- (void)cancel:(id)sender {
	[delegate problemAddViewController:self didFinishWithSave:NO];
}

- (void)save:(id)sender {
	if ([self validateFields])
		[delegate problemAddViewController:self didFinishWithSave:YES];
}

-(BOOL)validateFields{
	
	NSString* error = nil;
	
	NSString* description = [self.problem.area description];
	NSLog(@"%@",description);
	if ([self.problem.name isEqualToString:@""] || self.problem.name == nil) {
		error = @"Problem has to have a name";
	}
	
	if (self.problem.latitude == nil || [self.problem.latitude intValue] == 0 && [self.problem.longitude intValue] == 0) {
		error = @"You must pick a location for this problem";
		
	}
	
	if (self.problem.area == nil || [self.problem.area.masterId intValue] == 1) {
		error = @"Problem must belong to an area";
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
		//placeholder to override detail view controller
}

@end
