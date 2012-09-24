//
//  LocatableSyncable.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocatableSyncable.h"


@implementation LocatableSyncable

@dynamic name;
@dynamic dateAdded;
@dynamic dateModified;
@dynamic details;
@dynamic latitude;
@dynamic longitude;
@dynamic masterId;
@dynamic user;
@dynamic permission;
@dynamic idType;
@dynamic state;


- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D temp;
	
	temp.latitude = [self.latitude doubleValue];
	temp.longitude = [self.longitude doubleValue];
	
	return temp;     
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
	
	self.longitude = [NSNumber numberWithDouble:newCoordinate.longitude];
	self.latitude = [NSNumber numberWithDouble:newCoordinate.latitude];
}

- (NSString *)title{
	return self.name;
}

- (NSString *)subtitle{
	return self.details;
}




@end
