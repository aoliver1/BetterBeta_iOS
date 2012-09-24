//
//  SyncController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocatableSyncable;

@interface SyncController : NSObject <NSXMLParserDelegate> {
	//temp objects
	LocatableSyncable * locatableSyncable;  //Area, Problem, or Beta
	NSMutableString * currentStringValue;  //String value of xml response
	NSNumber * responseObjectId;
	NSNumber * puttingLocatableSyncable;
	
	NSPersistentStoreCoordinator *coordinator;
	
	NSDateFormatter *dateFormatter;
    
	NSManagedObjectContext *managedObjectContext;	  
    
	//NSMutableArray *objectIDsFetched;  
	
	NSOperationQueue * operationQueue;

	// NSMutableDictionary will provide key/value pairing.  maybe use the current core data object as 'value' and string parent/area/problem id as key, then sort by keys and fetch those just once.  Will the pointer to the core data oject still be valid? 
	NSMutableDictionary *problemAreas;
	NSMutableDictionary *areaParents;
	NSMutableDictionary *betaProblems;
	NSMutableDictionary *betaAreas;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableString *currentStringValue;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) NSMutableDictionary *problemAreas;
@property (nonatomic, retain) NSMutableDictionary *areaParents;
@property (nonatomic, retain) NSMutableDictionary *betaProblems;
@property (nonatomic, retain) NSMutableDictionary *betaAreas;

@property (nonatomic, retain) NSOperationQueue *operationQueue;


@property (nonatomic, retain) NSNumber *responseObjectId;
@property (nonatomic, retain) NSNumber *puttingLocatableSyncable;


- (id)initWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;


-(void)syncAll;
@end
