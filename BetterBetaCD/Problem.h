//
//  Problem.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocatableSyncable.h"

@class Area;



@interface Problem : LocatableSyncable {

}
@property (nonatomic, retain) Area *area;
@property (nonatomic, retain) NSSet *beta;
@property (nonatomic, retain) NSNumber *rating;

@end
