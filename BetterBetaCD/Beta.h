//
//  Media.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

enum BetaType {
	BetaTypeWebPicture = 1,
	BetaTypeDevicePicture = 2,
	BetaTypeVideo = 3,
	BetaTypeText = 4
};

#import <Foundation/Foundation.h>
#import "LocatableSyncable.h"

@class Area, Problem;

@interface Beta : LocatableSyncable {

}
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) Area *area;
@property (nonatomic, retain) Problem *problem;
@end
