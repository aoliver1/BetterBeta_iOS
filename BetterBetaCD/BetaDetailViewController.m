

#import <MobileCoreServices/UTCoreTypes.h>
#import "BetaDetailViewController.h"
#import "Beta.h"
#import "TextEditingViewController.h"
#import "MapViewController.h"
#import "AreaDetailViewController.h"
#import "BetterBetaCDAppDelegate.h"

@implementation BetaDetailViewController

@synthesize beta, betaForWhat, showPath, picker;


#pragma mark -
#pragma mark View lifecycle


- (void)loadView{
	
	[super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	self.tableView.backgroundColor = [UIColor blackColor];
	
	self.title = beta.name;
	if(beta.permission)
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if([beta.type intValue] == 4)
		self.showPath = NO;
	else
		self.showPath = YES;
	
	self.tableView.allowsSelectionDuringEditing = YES;
	
}


- (void)viewWillAppear:(BOOL)animated {
    // Redisplay the data.
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    [super setEditing:editing animated:animated];
	
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [self.tableView reloadData];
	
	if (!editing) {
		NSError *error;
		if (![beta.managedObjectContext save:&error]) {
			// Handle the error.
		}
	}
}


- (void)updateRightBarButtonItemState {
	self.navigationItem.rightBarButtonItem.enabled = [beta.permission intValue];
}	


#pragma mark -
#pragma mark Table view data source methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.showPath)
		return 3;
	else
		return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

	return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(self.showPath){
		if(section == 0)
			return @"Title";
		else if(section == 1)
			return @"Beta";
		else if(section == 2){
			if([self.beta.type intValue] == BetaTypeWebPicture)
				return @"The URL";
			else  if([self.beta.type intValue] == BetaTypeDevicePicture)
				return @"The Picture";
			else  if([self.beta.type intValue] == BetaTypeVideo)
				return @"The Video";
		}
		else
			return @"";
	}
		
	else {
		if(section == 0)
			return @"Title";
		else if(section == 1)
			return @"Beta";
		else
			return @"";
	}

	return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 40;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
	
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];
	
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *TextCellIdentifier = @"Cell";
	
	UITableViewCell *cell;
	
		
	cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	if (indexPath.section == 0){
		cell.imageView.image = nil;
		cell.textLabel.text = beta.name;
	}
	else if (indexPath.section == 1){
		cell.imageView.image = nil;
		cell.textLabel.text = beta.details;
	}
	else if (indexPath.section == 2){
		cell.backgroundView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		cell.textLabel.text = @"Choose Picture";
	}
	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.editing){
		
		switch (indexPath.section) {
			case 0: {
				TextEditingViewController *controller = [[TextEditingViewController alloc] init];
				controller.objectBeingEdited = self.beta;
				controller.editedFieldKey = @"name";
				controller.editedFieldName = NSLocalizedString(@"beta_name", @"display name for name");
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			} break;
			case 1: {
				TextEditingViewController *controller = [[TextEditingViewController alloc] init];
				controller.objectBeingEdited = self.beta;
				controller.editedFieldKey = @"details";
				controller.editedFieldName = NSLocalizedString(@"beta_details", @"display name for author");
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			} break;
			case 2: {
				
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle: @"Camera or Library?"
									  message: nil
									  delegate: self
									  cancelButtonTitle: @"Cancel"
									  otherButtonTitles: @"Use Camera", @"Pick from Library", nil];
				
				[alert show];
				[alert release];
			} break;
		}
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == 0) {
		return;
	}
	
	else if(buttonIndex == 0) {
		self.picker = [[[UIImagePickerController alloc] init] autorelease];
		self.picker.delegate = self;
		self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:picker animated:YES];
	}
	else if(buttonIndex == 2) {
		self.picker = [[[UIImagePickerController alloc] init] autorelease];
		self.picker.delegate = self;
		self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:picker animated:YES];
	}
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
		
	}
	if([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
		
	}
	
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resignFirstResponder];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
//	[dateFormatter release];
    self.beta = nil;
    [super dealloc];
}

@end

