//
//  SyncController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncController.h"
#import "LocatableSyncable.h"
#import "Area.h"
#import "Problem.h"
#import "Beta.h"
#import "BetterBetaCDAppDelegate.h"

//'Private' or internal methods -- this is technically a category, but category with blank name (aka. '()'), you are allowed to implement in the class file
@interface SyncController()

-(void)putNewAndDirty;
-(void)syncAreas;
-(void)syncProblems;
-(void)syncBeta;
-(void)connectRelationships;
-(void)setSyncing:(NSNumber *)syncing;


-(void)clearLocatable:(NSString *)entityName;
-(NSData *) postRequestWithString:(NSString *)urlString;
-(NSData *) postRequestWithString:(NSString *)urlString andData:(NSString *)data;
- (NSString *)urlEncodeValue:(NSString *)str;
@end


@implementation SyncController


@synthesize managedObjectContext, currentStringValue, dateFormatter, problemAreas, areaParents, betaProblems, betaAreas, operationQueue, responseObjectId, puttingLocatableSyncable;

#pragma mark -
#pragma mark Public Methods

- (id)initWithCoordinator:(NSPersistentStoreCoordinator *)theCoordinator{
    if (self = [super init]) {
        if (nil == theCoordinator) {
            @throw( [NSException exceptionWithName:@"InvalidArgumentException" reason:@"-[BackgroundFetcher initWithCoordinator:] was passed a nil coordinator!" userInfo:nil] );
        }
        coordinator = theCoordinator;
        // this retains all the objects we fetch
   //     [managedObjectContext setRetainsRegisteredObjects:YES];
		
		
		// this is the holding zone for relationships parsed from xml
		// they will be used in a 2nd pass over the data
		self.problemAreas = [[NSMutableDictionary alloc] init];
		self.areaParents = [[NSMutableDictionary alloc] init];
		self.betaAreas = [[NSMutableDictionary alloc] init];
		self.betaProblems = [[NSMutableDictionary alloc] init];
		//operationQueue = nil;
		operationQueue = [[NSOperationQueue alloc] init];
		
		[operationQueue setMaxConcurrentOperationCount:1];
        
    }
    return self;
}


-(void)syncAll{
	
	[self setSyncing:[NSNumber numberWithBool:YES]];
	
	NSInvocationOperation *operation = 
	[[NSInvocationOperation alloc] initWithTarget:self 
										 selector:@selector(doSync) 
										   object:nil]; 
	[operationQueue addOperation:operation]; 
	[operation release]; 	
}

#pragma mark -
#pragma mark Private Methods

-(void)doSync{

	self.managedObjectContext = [[NSManagedObjectContext alloc] init];
	[self.managedObjectContext setPersistentStoreCoordinator:coordinator];
	self.managedObjectContext.undoManager = nil;
	
	[self putNewAndDirty];
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.10] waitUntilDone:NO];
	[self syncAreas];
	[managedObjectContext save:nil];
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.25] waitUntilDone:NO];
	[self syncProblems];
	[managedObjectContext save:nil];
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.5] waitUntilDone:NO];
	[self syncBeta];
	[managedObjectContext save:nil];
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.75] waitUntilDone:NO];
	[self connectRelationships];
	[managedObjectContext save:nil];
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	[managedObjectContext release];
	
	[self performSelectorOnMainThread:@selector(setSyncing:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

-(void)setSyncing:(NSNumber *)syncing{
	[(BetterBetaCDAppDelegate *)[[UIApplication sharedApplication] delegate] setSyncing:[syncing boolValue]];
}

-(void)setProgress:(NSNumber *)progress{
	[[(BetterBetaCDAppDelegate *)[[UIApplication sharedApplication] delegate] progressBar] setProgress:[progress floatValue]];
}

-(void)putNewAndDirty{
	// put all areas that have type == new and type == dirty
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSError *error = nil;
	NSEntityDescription *entityArea =[NSEntityDescription entityForName:@"Area"	inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state != %d", 0];  // TODO MAKE GLOBAL INT CONSTANTS
	[request setPredicate:predicate];
	[request setEntity:entityArea];
	NSArray *newAndDirtyAreasArray = [managedObjectContext executeFetchRequest:request error:&error];
	
	for(Area * area in newAndDirtyAreasArray){
		NSString *areaPostString;
		if([area.masterId intValue] == 0){ // NEW object
			areaPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&parent_id=%@&user=%@",
							  [self urlEncodeValue:area.name],
							  [self urlEncodeValue:area.details],
							  [self urlEncodeValue:[area.longitude stringValue]],
							  [self urlEncodeValue:[area.latitude stringValue]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:area.dateAdded]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:area.dateModified]],
							  [self urlEncodeValue:[area.parent.masterId stringValue]],
							  [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]]];
		}
		else{ // dirty/edited
			areaPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&parent_id=%@&user=%@&master_id=%@",
							  [self urlEncodeValue:area.name],
							  [self urlEncodeValue:area.details],
							  [self urlEncodeValue:[area.longitude stringValue]],
							  [self urlEncodeValue:[area.latitude stringValue]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:area.dateAdded]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:area.dateModified]],
							  [self urlEncodeValue:[area.parent.masterId stringValue]],
							  [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]],
							  [self urlEncodeValue:[area.masterId stringValue]]];
		}
		
		NSLog(@"%@", areaPostString);
		NSData* result = [self postRequestWithString:@"http://www.betterbeta.info/add_update_area.php" andData:areaPostString];		 		
		NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
		
		self.puttingLocatableSyncable = [NSNumber numberWithBool:YES];
		
		[parser setDelegate:self];
		[parser parse];
		[parser release];
		
		area.state = [NSNumber numberWithInt:0];
		if(self.responseObjectId != nil)
			area.masterId = self.responseObjectId;
		
		self.responseObjectId = nil;
		self.puttingLocatableSyncable = [NSNumber numberWithBool:NO];
		
		
	}
//	[managedObjectContext save:nil];
	[request release]; // fetch request for new and dirty areas

	//PROBLEMS
	
	NSFetchRequest *problemsRequest = [[NSFetchRequest alloc] init];
	error = nil;
	NSEntityDescription *entityProblem =[NSEntityDescription entityForName:@"Problem" inManagedObjectContext:managedObjectContext];
	predicate = [NSPredicate predicateWithFormat:@"state != %d", 0];  // TODO MAKE GLOBAL INT CONSTANTS
	[problemsRequest setPredicate:predicate];
	[problemsRequest setEntity:entityProblem];
	NSArray *newAndDirtyProblemsArray = [managedObjectContext executeFetchRequest:problemsRequest error:&error];
	
	for(Problem * problem in newAndDirtyProblemsArray){
		NSString *problemPostString;
		if([problem.masterId intValue] == 0){ // NEW object
			problemPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&area_id=%@&user=%@",
								 [self urlEncodeValue:problem.name],
								 [self urlEncodeValue:problem.details],
								 [self urlEncodeValue:[problem.longitude stringValue]],
								 [self urlEncodeValue:[problem.latitude stringValue]],
								 [self urlEncodeValue:[self.dateFormatter stringFromDate:problem.dateAdded]],
								 [self urlEncodeValue:[self.dateFormatter stringFromDate:problem.dateModified]],
								 [self urlEncodeValue:[problem.area.masterId stringValue]],
								 [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]]];
			NSLog(@"%@", problemPostString);
			
		}
		else{ // dirty/edited
			problemPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&area_id=%@&user=%@&master_id=%@",
								 [self urlEncodeValue:problem.name],
								 [self urlEncodeValue:problem.details],
								 [self urlEncodeValue:[problem.longitude stringValue]],
								 [self urlEncodeValue:[problem.latitude stringValue]],
								 [self urlEncodeValue:[self.dateFormatter stringFromDate:problem.dateAdded]],
								 [self urlEncodeValue:[self.dateFormatter stringFromDate:problem.dateModified]],
								 [self urlEncodeValue:[problem.area.masterId stringValue]],
								 [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]],
								 [self urlEncodeValue:[problem.masterId stringValue]]];
			NSLog(@"%@", problemPostString);
		}
		
		
		NSData* result = [self postRequestWithString:@"http://www.betterbeta.info/add_update_problem.php" andData:problemPostString];		 		
		NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
		
		self.puttingLocatableSyncable = [NSNumber numberWithBool:YES];
		
		[parser setDelegate:self];
		[parser parse];
		[parser release];
		
		problem.state = [NSNumber numberWithInt:0];
		if(self.responseObjectId != nil)
			problem.masterId = self.responseObjectId;
		
		self.responseObjectId = nil;
		self.puttingLocatableSyncable = [NSNumber numberWithBool:NO];
		
		
	}
//	[managedObjectContext save:nil];
	[problemsRequest release]; // fetch request for new and dirty problems
	
	//BETA
	
	NSFetchRequest *betaRequest = [[NSFetchRequest alloc] init];
	error = nil;
	NSEntityDescription *entityBeta =[NSEntityDescription entityForName:@"Beta"	inManagedObjectContext:managedObjectContext];
	predicate = [NSPredicate predicateWithFormat:@"state != %d", 0];  // TODO MAKE GLOBAL INT CONSTANTS
	[betaRequest setPredicate:predicate];
	[betaRequest setEntity:entityBeta];
	NSArray *newAndDirtyBetasArray = [managedObjectContext executeFetchRequest:betaRequest error:&error];
	
	for(Beta * beta in newAndDirtyBetasArray){
		NSString *betaPostString;
		if([beta.masterId intValue] == 0){ // NEW object
			betaPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&problem_id=%@&area_id=%@&path=%@&type=%@&user=%@",
							  [self urlEncodeValue:beta.name],
							  [self urlEncodeValue:beta.details],
							  [self urlEncodeValue:[beta.longitude stringValue]],
							  [self urlEncodeValue:[beta.latitude stringValue]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:beta.dateAdded]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:beta.dateModified]],
							  [self urlEncodeValue:[beta.problem.masterId stringValue]],
							  [self urlEncodeValue:[beta.area.masterId stringValue]],
							  [self urlEncodeValue:beta.path],
							  [self urlEncodeValue:[beta.type stringValue]],
							  [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]]];
		}
		else{ // dirty/edited
			betaPostString = [NSString stringWithFormat:@"name=%@&details=%@&longitude=%@&latitude=%@&date_added=%@&date_modified=%@&problem_id=%@&area_id=%@&path=%@&type=%@&user=%@&master_id=%@",
							  [self urlEncodeValue:beta.name],
							  [self urlEncodeValue:beta.details],
							  [self urlEncodeValue:[beta.longitude stringValue]],
							  [self urlEncodeValue:[beta.latitude stringValue]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:beta.dateAdded]],
							  [self urlEncodeValue:[self.dateFormatter stringFromDate:beta.dateModified]],
							  [self urlEncodeValue:[beta.problem.masterId stringValue]],
							  [self urlEncodeValue:[beta.area.masterId stringValue]],
							  [self urlEncodeValue:beta.path],
							  [self urlEncodeValue:[beta.type stringValue]],
							  [self urlEncodeValue:[[UIDevice currentDevice] uniqueIdentifier]],
							  [self urlEncodeValue:[beta.masterId stringValue]]];
		}
		
		betaPostString = [betaPostString stringByReplacingOccurrencesOfString:@"(null)" withString:@"0"]; 
		//NSLog(betaPostString);
		NSData* result = [self postRequestWithString:@"http://www.betterbeta.info/add_update_media.php" andData:betaPostString];		 		
		NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
		
		self.puttingLocatableSyncable = [NSNumber numberWithBool:YES];
		
		[parser setDelegate:self];
		[parser parse];
		[parser release];
		
		beta.state = [NSNumber numberWithInt:0];
		if(self.responseObjectId != nil)
			beta.masterId = self.responseObjectId;
		
		self.responseObjectId = nil;
		self.puttingLocatableSyncable = [NSNumber numberWithBool:NO];
		
		
	}
	
	[betaRequest release]; 
	
	
}
-(void)syncAreas{
	
	
	NSData* result = [self postRequestWithString:	[NSString stringWithFormat:@"http://www.betterbeta.info/areas.php?user=%@", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
	
	[self clearLocatable:@"Area"];
	
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	
	//somehow notify to say areas sync'd
	
	
	
}
-(void)syncProblems{
	// put all areas that have type == new and type == dirty
		
	NSData* result = [self postRequestWithString:	[NSString stringWithFormat:@"http://www.betterbeta.info/problems.php?user=%@", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
	
	//IF (post was successfull)
	[self clearLocatable:@"Problem"];
	
	
    [parser setDelegate:self];
	[parser parse];
	[parser release];
	
}
-(void)syncBeta{
	

	
	NSData* result = [self postRequestWithString:	[NSString stringWithFormat:@"http://www.betterbeta.info/media.php?user=%@", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:result];
	
	//IF (result successfull)
	[self clearLocatable:@"Beta"];
	
	
    [parser setDelegate:self];
	[parser parse];
	[parser release];
}



-(void)connectRelationships{
	
	
//	Area* earthArea = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityArea =[NSEntityDescription entityForName:@"Area"	inManagedObjectContext:managedObjectContext];
	NSEntityDescription *entityProblem =[NSEntityDescription entityForName:@"Problem"	inManagedObjectContext:managedObjectContext];
	NSEntityDescription *entityBeta =[NSEntityDescription entityForName:@"Beta"	inManagedObjectContext:managedObjectContext];

	NSError *error = nil;
	Area *parentArea;
	Area *childArea;
	Problem *childProblem;
	Problem *parentProblem;
	Beta *childBeta;
	
	[request setEntity:entityArea];
	
	for(NSNumber * key in areaParents){
		parentArea = nil;
		childArea = nil;
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %@", key];
		[request setPredicate:predicate];
		NSArray *areaArray = [managedObjectContext executeFetchRequest:request error:&error];
		
		childArea = [areaArray objectAtIndex:0];
		
		if([key intValue] == 1){
			parentArea.children = [parentArea.children setByAddingObject:parentArea];
		}
		else{
			NSString * parentId = [areaParents objectForKey:key];
			predicate = [NSPredicate predicateWithFormat:@"masterId = %@", parentId];
			[request setPredicate:predicate];
			
			NSArray *parentArray = [managedObjectContext executeFetchRequest:request error:&error];
			
			if ([parentArray count] == 0) {
				NSLog(@"Parent area does not exist in connectRelationships, area missing parent has id: %d", [key intValue]);
			}
			else {
				
				parentArea = [parentArray objectAtIndex:0];
				
				if(parentArea != nil && childArea != nil){
					parentArea.children = [parentArea.children setByAddingObject:childArea];
					[managedObjectContext save:nil];
				}
				else
					NSLog(@"Parent or Child Area is NIL in import!");
			}

		}
	}
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.80] waitUntilDone:NO];
	
	for(NSNumber * key in problemAreas){
		parentArea = nil;
		childProblem = nil;
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %@", key];
		[request setPredicate:predicate];
		[request setEntity:entityProblem];
		NSArray *areaArray = [managedObjectContext executeFetchRequest:request error:&error];
		
		childProblem = [areaArray objectAtIndex:0];
		
		NSString * parentId = [problemAreas objectForKey:key];
		predicate = [NSPredicate predicateWithFormat:@"masterId = %@", parentId];
		[request setPredicate:predicate];
		[request setEntity:entityArea];
		
		NSArray *parentArray = [managedObjectContext executeFetchRequest:request error:&error];
		
		parentArea = [parentArray objectAtIndex:0];
		
		if(parentArea != nil && childProblem != nil){
			parentArea.problems = [parentArea.problems setByAddingObject:childProblem];
			[managedObjectContext save:nil];
		}
		else
			NSLog(@"Parent Area or Child Problem is NIL in import!");
	}
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.85] waitUntilDone:NO];
	
	for(NSNumber * key in betaAreas){
		parentArea = nil;
		childBeta = nil;
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %@", key];
		[request setPredicate:predicate];
		[request setEntity:entityBeta];
		NSArray *betaArray = [managedObjectContext executeFetchRequest:request error:&error];
		
		childBeta = [betaArray objectAtIndex:0];
		
		NSString * parentId = [betaAreas objectForKey:key];
		predicate = [NSPredicate predicateWithFormat:@"masterId = %@", parentId];
		[request setPredicate:predicate];
		[request setEntity:entityArea];
		
		NSArray *parentArray = [managedObjectContext executeFetchRequest:request error:&error];
		
		parentArea = [parentArray objectAtIndex:0];
		
		if(parentArea != nil && childBeta != nil){
			parentArea.beta = [parentArea.beta setByAddingObject:childBeta];
			[managedObjectContext save:nil];
		}
		else
			NSLog(@"Parent Area or Child Beta is NIL in import!");
	}
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.95] waitUntilDone:NO];
	for(NSNumber * key in betaProblems){
		parentProblem = nil;
		childBeta = nil;
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterId = %@", key];
		[request setPredicate:predicate];
		[request setEntity:entityBeta];
		NSArray *betaArray = [managedObjectContext executeFetchRequest:request error:&error];
		childBeta = [betaArray objectAtIndex:0];
		
		NSString * parentId = [betaProblems objectForKey:key];
		predicate = [NSPredicate predicateWithFormat:@"masterId = %@", parentId];
		[request setPredicate:predicate];
		[request setEntity:entityProblem];
		NSArray *parentArray = [managedObjectContext executeFetchRequest:request error:&error];
		parentProblem = [parentArray objectAtIndex:0];
		
		if(parentProblem != nil && childBeta != nil){
			parentProblem.beta = [parentProblem.beta setByAddingObject:childBeta];
			[managedObjectContext save:nil];
		}
		else
			NSLog(@"Parent Area or Child Beta is NIL in import!");
	}
	[request release];
	
}


#pragma mark -
#pragma mark Helper Methods

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

-(NSData *) postRequestWithString:(NSString *)urlString{
	
	NSURL *url = [NSURL URLWithString:urlString ];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"POST"];
	NSURLResponse* response;
	NSError* error;
	
	return [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	
}
-(NSData *) postRequestWithString:(NSString *)urlString andData:(NSString *)data{
	
	NSURL *url = [NSURL URLWithString:urlString ];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	[req setHTTPMethod:@"POST"];
	NSURLResponse* response;
	NSError* error = nil;
	[req setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData* result = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	
	if (!error)
		return result;
	
	else{
		NSLog(@"Error in post Request");
		return result;
	}
//	return [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	
	//TODO handle error
	
}

-(void) clearLocatable:(NSString *)entityName{
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:entityName inManagedObjectContext:managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription]; 
	NSError *errors = nil;
	NSArray *locatables = [managedObjectContext executeFetchRequest:request error:&errors];
	[request release];
	
	if(locatables != nil){
		int arrayCount = [locatables count];
		NSAutoreleasePool *pool =  [[NSAutoreleasePool alloc] init];
		for (int i = 0; i < arrayCount; i++) {
			[managedObjectContext deleteObject:[locatables objectAtIndex:i]];
		}
		[pool release];
//		[managedObjectContext save:nil];
	}
}




#pragma mark -
#pragma mark Parser Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	/*
		New Entity, instantiate and get ready to populate
	 */
	
	if ( [elementName isEqualToString:@"area"]) {
		locatableSyncable = [[NSEntityDescription
							  insertNewObjectForEntityForName:@"Area"
							  inManagedObjectContext:self.managedObjectContext] retain];
        return;
    }
	if ( [elementName isEqualToString:@"problem"]) {
		locatableSyncable = [[NSEntityDescription
							  insertNewObjectForEntityForName:@"Problem"
							  inManagedObjectContext:self.managedObjectContext] retain];
        return;
    }
	if ( [elementName isEqualToString:@"media"]) {
		locatableSyncable = [[NSEntityDescription
							  insertNewObjectForEntityForName:@"Beta"
							  inManagedObjectContext:self.managedObjectContext] retain];
        return;
    }
	
	/*
	 LocatableSyncable objects have these in common
	 */
	
	else if ( [elementName isEqualToString:@"id"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain] ;		
        return;
    }
	else if ( [elementName isEqualToString:@"name"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain] ;		
        return;
    }
	else if ( [elementName isEqualToString:@"date_added"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"date_modified"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"details"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"latitude"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"longitude"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"user"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	else if ( [elementName isEqualToString:@"permission"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	/*
	 Area Specific	 
	 */
	
	else if ( [elementName isEqualToString:@"parent_id"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }

	/*
	 Problem/Media Specific	 
	 */
	
	else if ( [elementName isEqualToString:@"area_id"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	/*
	 Media Specific
	 */
	
	else if ( [elementName isEqualToString:@"problem_id"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	else if ( [elementName isEqualToString:@"type"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	else if ( [elementName isEqualToString:@"path"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	
	
	/*
	 Upload Specific
	 */
	
	
	else if ( [elementName isEqualToString:@"success"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	else if ( [elementName isEqualToString:@"reason"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	else if ( [elementName isEqualToString:@"id"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	
	
	else{
		[currentStringValue release];
		currentStringValue = nil;	
	}
	
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
    if (self.currentStringValue) 
		[self.currentStringValue appendString:string];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//need to differentiate id from item vs id from " put/update to server response "
	
	if ( [elementName isEqualToString:@"id"]) {
		if ([self.puttingLocatableSyncable intValue]){
			NSNumber * idNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];	
			self.responseObjectId = idNum;
			[idNum release];
			self.puttingLocatableSyncable = [NSNumber numberWithBool: NO];
		}
		else{
			NSNumber * idNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];	
			locatableSyncable.masterId = idNum;
			[idNum release];
		}
        return;			
    }
	
	else if ( [elementName isEqualToString:@"name"]) {
		locatableSyncable.name =  [currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
        return;
    }
	else if ( [elementName isEqualToString:@"date_added"]) {
		locatableSyncable.dateAdded = [self.dateFormatter dateFromString:currentStringValue];
        return;			
    }
	else if ( [elementName isEqualToString:@"date_modified"]) {		
		locatableSyncable.dateModified = [self.dateFormatter dateFromString:currentStringValue];
        return;
	}	
	else if ( [elementName isEqualToString:@"latitude"]) {
		NSNumber * latNum = [[NSNumber alloc] initWithFloat:[currentStringValue floatValue]];
		locatableSyncable.latitude = latNum;
		[latNum release];
		return;
    }
	else if ( [elementName isEqualToString:@"longitude"]) {
		NSNumber * lonNum = [[NSNumber alloc] initWithFloat:[currentStringValue floatValue]];
		locatableSyncable.longitude = lonNum;
        [lonNum release];
		return;
    }
	if ( [elementName isEqualToString:@"details"]) {
		locatableSyncable.details =  [currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
        return;
    }
	else if ( [elementName isEqualToString:@"user"]) {
		locatableSyncable.user = currentStringValue;
        return;
    }
	else if ( [elementName isEqualToString:@"permission"]) {
		NSNumber * permissionNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		locatableSyncable.permission = permissionNum;
		[permissionNum release];
		return;
    }
	
	/*
	 Area Specific	 
	 */
	
	else if ( [elementName isEqualToString:@"parent_id"]) {
		
		NSNumber * parentNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		[areaParents setObject:[parentNum stringValue] forKey:locatableSyncable.masterId];
		[parentNum release];
        return;
    }
	
	/*
	 Problem/Media Specific	 
	 */
	
	else if ( [elementName isEqualToString:@"area_id"]) {
		
		
		NSNumber * areaNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];

		if ([areaNum intValue] > 0){
			if ([locatableSyncable isMemberOfClass:[Problem class]])
				[problemAreas setObject:currentStringValue	forKey:locatableSyncable.masterId];
			else if ([locatableSyncable isMemberOfClass:[Beta class]])
				[betaAreas setObject:[areaNum stringValue] forKey:locatableSyncable.masterId];
		}
		[areaNum release];
        return;
    }
	
	/*
	 Media Specific
	 */
	
	else if ( [elementName isEqualToString:@"problem_id"]) {
		NSNumber * problemNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		if([problemNum intValue] > 0)
			[betaProblems setObject:[problemNum stringValue] forKey:locatableSyncable.masterId];
		[problemNum release];
        return;
	}
	
	else if ( [elementName isEqualToString:@"type"]) {
		NSNumber * typeNum =[[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		((Beta *)locatableSyncable).type = typeNum;
		[typeNum release];
        return;
    }
	
	else if ( [elementName isEqualToString:@"path"]) {
		
		
		((Beta *)locatableSyncable).path = [currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return;
    }
	
	
	
	/*
	 Upload Specific
	 */
	
	
	else if ( [elementName isEqualToString:@"success"]) {
		NSNumber * problemNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		if([problemNum intValue] > 0)
			[betaProblems setObject:[problemNum stringValue] forKey:locatableSyncable.masterId];
		[problemNum release];
        return;
		
    }
	
	else if ( [elementName isEqualToString:@"reason"]) {
		[currentStringValue release];
		currentStringValue = [[NSMutableString string] retain];		
        return;
    }
	
	else if ( [elementName isEqualToString:@"id"]) {
		NSNumber * problemNum = [[NSNumber alloc] initWithInt:[currentStringValue intValue]];
		if([problemNum intValue] > 0)
			[betaProblems setObject:[problemNum stringValue] forKey:locatableSyncable.masterId];
		[problemNum release];
        return;
		
    }
	
	
	
	/*
	 
	 Object Management
	 
	 */
	
	if ( [elementName isEqualToString:@"area"]  ||  [elementName isEqualToString:@"problem"] ||  [elementName isEqualToString:@"media"]) {
		NSNumber * idType = [[NSNumber alloc] initWithInt:1];
		locatableSyncable.idType = idType; // IdType.MASTER == 1, IdType.Local == 0
		[idType release];
		
		NSNumber * state = [[NSNumber alloc] initWithInt:0];
		locatableSyncable.state = state; //CLEAN == 0, NEW == 1, DIRTY == 2
		[state release];
		
//		[managedObjectContext save:nil];
		[locatableSyncable release];
    }
}


- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString{
}

#pragma mark -
#pragma mark Date Formatter

- (NSDateFormatter *)dateFormatter {	
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	}
	return dateFormatter;
}

#pragma mark -
#pragma mark Memory management

-(void) dealloc{
	[super dealloc];
	[managedObjectContext release];
	[currentStringValue release];
	[dateFormatter release];
	[areaParents release];
	[problemAreas release];
	[betaAreas release];
	[betaProblems release];
	[operationQueue release];
}

@end