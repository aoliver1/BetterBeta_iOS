
#import "Area.h"
#import "AreasViewController.h"
@interface TextEditingViewController : UIViewController  {
	//views to be shown
	UITextView *textView;

    NSString *textValue;	// actual new/edited value
    NSString *editedFieldKey; // aka 'name', 'details', for key-value coding
	NSString *editedFieldName; // aka "The Name Of The Climb"

    LocatableSyncable *objectBeingEdited;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) LocatableSyncable *objectBeingEdited;
@property (nonatomic, retain) NSString *editedFieldName;
@property (nonatomic, retain) NSString *editedFieldKey;

- (IBAction)cancel;
- (IBAction)save;

@end

