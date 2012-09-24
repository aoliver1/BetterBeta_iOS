//
//  Area.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocatableSyncable.h"

@interface Area : LocatableSyncable  {
	
}

@property (nonatomic, retain) Area *parent;
@property (nonatomic, retain) NSSet *problems;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) NSSet *beta;

//@property (nonatomic,  readonly) CLLocationCoordinate2Dcoordinate coordinate;

@end
