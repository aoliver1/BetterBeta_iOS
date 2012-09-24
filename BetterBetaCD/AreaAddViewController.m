

#import "AreaAddViewController.h"
#import "Area.h"

@implementation AreaAddViewController

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
    // Override the DetailViewController viewDidLoad with different navigation bar items and title.
    self.title = @"New Area";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
            target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
            target:self action:@selector(save:)] autorelease];
	
	// Set up the undo manager and set editing state to YES.
	self.editing = YES;
}


- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
}


#pragma mark -
#pragma mark Save and cancel operations

- (void)cancel:(id)sender {
	[delegate areaAddViewController:self didFinishWithSave:NO];
}


- (void)save:(id)sender {
	if ([self validateFields])
		[delegate areaAddViewController:self didFinishWithSave:YES];
}

-(BOOL)validateFields{
	
	NSString* error = nil;
	
	NSString* description = [self.area description];
	NSLog(@"%@",description);
	if ([self.area.name isEqualToString:@""] || self.area.name == nil) {
		error = @"Area has to have a name";
	}
	
	if (self.area.latitude == nil || [self.area.latitude intValue] == 0 && [self.area.longitude intValue] == 0) {
		error = @"You must pick a location for this area";
		
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
