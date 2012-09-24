//
//  LocatableSyncable.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>



@interface LocatableSyncable : NSManagedObject <MKAnnotation> {

}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *dateAdded;
@property (nonatomic, retain) NSDate *dateModified;
@property (nonatomic, retain) NSString *details;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *masterId;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSNumber *permission;
@property (nonatomic, retain) NSNumber *idType;
@property (nonatomic, retain) NSNumber *state;

@end
