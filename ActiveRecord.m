//
//  ActiveRecord
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 7/22/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveRecord.h"
#import "ObjectiveRecord+Utilities.h"
#import "ActiveRequest.h"


@implementation ActiveRecord : NSManagedObject 

@synthesize delegate = _delegate;
@synthesize remoteDidFinishSelector = _remoteDidFinishSelector;
@synthesize remoteDidFailSelector = _remoteDidFailSelector;

#pragma mark -
#pragma mark Utilities

+ (void) save{
	
	[[self activeManager].managedObjectContext save];
}

+ (ActiveManager *) activeManager{
	
	ActiveManager *manager = [ActiveManager shared];
	[manager.defaultDateParser setDateFormat:[self dateFormat]];
	
	return manager;
}

+ (NSManagedObjectContext *) managedObjectContext {
	
    return [[self activeManager] managedObjectContext];
}

+ (NSString *) entityName {
	
    return $S(@"%@", self);
}

+ (NSEntityDescription *) entityDescription{
	
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[self managedObjectContext]];
}

- (NSMutableDictionary *) properties {
	
    return [self properties:nil withoutObjects:nil];
}

- (NSMutableDictionary *) properties:(NSDictionary *)options {
	
    return [self properties:options withoutObjects:nil];
}

- (NSMutableDictionary *) properties:(NSDictionary *)options withoutObjects:(NSMutableArray *)withouts {
	
    NSArray *only		= [options objectForKey:@"$only"];
    NSArray *except		= [options objectForKey:@"$except"];
    BOOL serializeDates	= [[options objectForKey:@"$serializeDates"] boolValue];
	
    if (withouts == nil)
        withouts = [NSMutableArray array];
    [withouts addObject:self];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSPropertyDescription *prop in [[[self class] entityDescription] properties]) {
        NSString *key = prop.name;
        if ((only == nil || [only containsObject:key]) && (except == nil || ![except containsObject:key])) {
            id value = [self valueForKey:key];
            if (value == nil)
                value = [NSNull null];
			
            // For attributes, simply set the value
            if ([prop isKindOfClass:[NSAttributeDescription class]]) {
                // Serialize dates if serializeDates is set
                if ([value isKindOfClass:[NSDate class]] && serializeDates)
                    value = [[[self class] activeManager].defaultDateParser stringFromDate:value];
								
                [dict setObject:value forKey:key];
            }
			
            // For relationships, recursively branch off properties:ignoringObjects call
            else {
                NSRelationshipDescription *rel = (NSRelationshipDescription *)prop;
                if ([rel isToMany]) {
                    NSSet *relResources = value;
                    NSMutableArray *relArray = [NSMutableArray arrayWithCapacity:[relResources count]];
                    for (ActiveRecord *resource in relResources) {
                        // Only add objects which are not part of the withouts array
                        // (most importantly, ignore objects that have been previously added)
                        if (![withouts containsObject:resource])
                            [relArray addObject:[resource properties:options withoutObjects:withouts]];
                    }
                    [dict setObject:relArray forKey:key];
                }
                else {
                    if (![withouts containsObject:value])
                        [dict setObject:value forKey:key];
                }
            }
        }
    }
    return dict;
}

+ (NSDictionary *) relationshipsByName {
	
    NSDictionary *rels = [[[self activeManager] modelRelationships] objectForKey:self];
    if (rels == nil) {

        rels = [[self entityDescription] relationshipsByName];
        [[[self activeManager] modelRelationships] setObject:rels forKey:self];
    }
    return rels;
}

+ (BOOL) hasRelationships {
	
    return [[self relationshipsByName] count] > 0;
}

+ (NSDictionary *) attributesByName {
	
    NSDictionary *attr = [[[self activeManager] modelAttributes] objectForKey:self];
    if (attr == nil) {

        attr = [[self entityDescription] attributesByName];
        [[[self activeManager] modelAttributes] setObject:attr forKey:self];
    }
    return attr;
}

+ (NSDictionary *) propertiesByName {
		
    NSDictionary *props = [[[self activeManager] modelProperties] objectForKey:self];
    if (props == nil) {
		
        props = [[self entityDescription] propertiesByName];
        [[[self activeManager] modelProperties] setObject:props forKey:self];
    }
	
    return props;
}

+ (NSPropertyDescription *) propertyDescriptionForField:(NSString *)field inModel:(Class)modelClass {
	
    return [[modelClass propertiesByName] objectForKey:field];
}

+ (NSPropertyDescription *) propertyDescriptionForField:(NSString *)field {
	
    return [self propertyDescriptionForField:field inModel:self];
}

+ (NSString *) localNameForRemoteField:(NSString *)name {
    return name;
}

+ (NSString *) remoteNameForLocalField:(NSString *)name {
    return name;
}


#pragma mark -
#pragma mark Finding

+ (NSArray *) all{
	
	ActiveResult *result = [self find:nil];

	return [NSArray arrayWithArray:[result objects]];
}

+ (id) first{
	
	ActiveResult *result = [self find:nil sortBy:nil limit:1 fields:nil];
	
	return [result object];
}

+ (id) last{
	
	NSRange sortRange = [[[self defaultSort] lowercaseString] rangeOfString:@"desc"];
	NSString *sortDir = sortRange.location == NSNotFound ? @"desc" : @"asc";
	
	
	ActiveResult *result = [self find:nil sortBy:[[self defaultSort] stringByReplacingCharactersInRange:sortRange withString:sortDir]];
	
	return [result object];
}

+ (BOOL) exists:(NSNumber *)itemID{
		
	return [self findByID:itemID] == nil ? NO : YES;
}

+ (id) findByID:(NSNumber *) itemID{
	
	if([self propertyDescriptionForField:[self localIDField]] == nil)
		return nil;
	
	ActiveResult *result = [self find:$P($S(@"%@ = %i", [self localIDField], [itemID intValue]))];

	return [result object];
}

+ (ActiveResult *) find:(id) query{
    
    return [self find:query sortBy:nil limit:0 fields:nil];
}

+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy{
	
	return [self find:query sortBy:sortBy limit:0 fields:nil];
}

+ (ActiveResult *) find:(id) query limit:(int) limit{
	
	return [self find:query sortBy:nil limit:limit fields:nil];
}

+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy limit:(int)limit{
    
	return [self find:query sortBy:sortBy limit:limit fields:nil];
}

+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy limit:(int)limit fields:(NSArray *)fields{
	
    NSFetchRequest *fetch = [self fetchRequest];
	[fetch setEntity:[self entityDescription]];
	[fetch setPredicate:[ActiveSupport predicateFromObject:query]];
	[fetch setPropertiesToFetch:fields];
	[fetch setFetchBatchSize:20];
	
	if(sortBy != nil)
		[fetch setSortDescriptors:[ActiveSupport sortDescriptorsFromString:sortBy]];
		
	if(limit > 0)
		[fetch setFetchLimit:limit];
	
	NSError *error;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	ActiveResult *result = [[[ActiveResult alloc] initWithResults:results] autorelease];

	return result; 
}


#pragma mark -
#pragma mark Utilities
+ (NSFetchRequest *) fetchRequest{
	
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[self entityDescription]];
	[fetch setSortDescriptors:[ActiveSupport sortDescriptorsFromString:[self defaultSort]]];
	return fetch;
}

+ (int) count{
	
	return [self count:nil];
}

+ (int) count:(NSPredicate *) predicate{
	
	NSFetchRequest *fetch = [self fetchRequest];
	[fetch setPredicate:predicate];
	
	return [[self managedObjectContext] countForFetchRequest:fetch error:nil];
}

+ (NSNumber *) sum:(NSString *)property{
	
	ActiveResult *result = [self find:nil sortBy:nil limit:0 fields:$A(property)];
	
	return [[result objects] valueForKeyPath:$S(@"@sum.%@", property)];
}

+ (NSNumber *) minimum:(NSString *)property{
	
	ActiveResult *result = [self find:nil sortBy:nil limit:0 fields:$A(property)];
	
	return [[result objects] valueForKeyPath:$S(@"@min.%@", property)];
}

+ (NSNumber *) maximum:(NSString *)property{
	
	ActiveResult *result = [self find:nil sortBy:nil limit:0 fields:$A(property)];
	
	return [[result objects] valueForKeyPath:$S(@"@max.%@", property)];
}

+ (NSNumber *) average:(NSString *)property{
	
	ActiveResult *result = [self find:nil sortBy:nil limit:0 fields:$A(property)];
	
	return [[result objects] valueForKeyPath:$S(@"@avg.%@", property)];
}


#pragma mark -
#pragma mark Create / Update

- (NSDictionary *) map{
	
	// Subclass to map fields
	return [NSDictionary dictionary];
}

+ (id) create:(id)parameters {
    return [self create:parameters withOptions:[self defaultCreateOptions]];
}

+ (id) create:(id)parameters withOptions:(NSDictionary *)options {
    if ([parameters isKindOfClass:[NSArray class]]) {

        NSMutableArray *resources = [NSMutableArray arrayWithCapacity:[parameters count]];
        for (id item in parameters)
            [resources addObject:[self create:item withOptions:options]];
		
        return resources;
    }
    else {
		
        ActiveRecord *resource = [[self alloc] initWithEntity:[self entityDescription] 
							   insertIntoManagedObjectContext:[self managedObjectContext]];
        [resource update:parameters withOptions:options];
		
        id doTimestamp = [options objectForKey:@"timestamp"];
        if (doTimestamp == nil || [doTimestamp boolValue] == YES) {
            SEL createdAtSel = NSSelectorFromString([self createdAtField]);
            if ([resource respondsToSelector:createdAtSel])
                [resource setValue:[NSDate date] forKey:[self createdAtField]];
        }
        
        if ([[self class] activeManager].logLevel > 1) {
            NSLog(@"Created new %@", self);
            if ([[self class] activeManager].logLevel > 4)
                NSLog(@"=> %@", resource);
        }
        
        [resource didCreate];
		
        return [resource autorelease];
    }
}

+ (id) build:(id)parameters {
	
    return [self build:parameters withOptions:[self defaultCreateOptions]];
}

+ (id) build:(id)parameters withOptions:(NSDictionary *)options {

	id resource;
	
    if ([parameters isKindOfClass:self])
        return parameters;
	
    else if ([parameters isKindOfClass:[NSArray class]]) {

        NSMutableArray *resources = [NSMutableArray arrayWithCapacity:[parameters count]];
        for (id item in parameters)
            [resources addObject:[self build:item withOptions:options]];
		
        return resources;
    }
    
    else if ([parameters isKindOfClass:[NSDictionary class]]) {

        id resourceId = [parameters objectForKey:[self remoteIDField]];
        
        if (resourceId != nil) {            
			
            if ([self exists:$I([resourceId intValue])]){
				
                resource = [self findByID:$I([resourceId intValue])];
                
                BOOL shouldUpdate = [resource shouldUpdateWith:parameters];
                if (shouldUpdate) {
                    [resource update:parameters withOptions:options];
                }
                else {
                    if ([[self class] activeManager].logLevel > 1)
                        NSLog(@"Skipping update of %@ with id %@ because it is already up-to-date", 
							  [resource class], [resource valueForKey:[self localIDField]]);
                }
            }
        }
        
        resource = [self create:parameters withOptions:options];
    }
	
	return resource;
}

- (id) update:(NSDictionary *)data{
	
	return [self update:data withOptions:nil];
}

- (id) update:(NSDictionary *) data withOptions:(NSDictionary *) options{
	
	NSMutableDictionary *dict	= [NSMutableDictionary dictionary];
	NSDictionary *map			= [self map];
		
	for(NSString *key in [data keyEnumerator]){
		
		NSString *mappedKey = [[map allKeys] indexOfObject:key] == NSNotFound ? key : [map objectForKey:key];
		[dict setObject:[data objectForKey:key] forKey:[mappedKey stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
	}
			
	// Loop through and apply fields in dictionary (if they exist on the object)
    for (NSString *field in [dict allKeys]) {
		
        // Get local field name (by default, this is the same as the remote name)
        // If this is an ID field, use remote/localIdField methods; otherwise, localNameForRemoteField
        NSString *localField = nil;
        if ([field isEqualToString:[[self class] remoteIDField]])
            localField = [[self class] localIDField];
        else
            localField = [[self class] localNameForRemoteField:field];
        
        NSPropertyDescription *propertyDescription = [[self class] propertyDescriptionForField:localField inModel:[self class]];

        if (propertyDescription != nil) {
            id value = [dict objectForKey:field];
            
            // If property is a relationship, do some cascading object creation/updation
            if ([propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
				
                // Get relationship class from core data info
                NSRelationshipDescription *relationshipDescription = (NSRelationshipDescription *)propertyDescription;
                Class relationshipClass = NSClassFromString([[relationshipDescription destinationEntity] managedObjectClassName]);
                id newRelatedResources;
                id existingRelatedResources = [self valueForKey:localField];
								
                // ===== Get related resources from value ===== //
				NSDictionary *relationshipOptions = [options objectForKey:relationshipClass];
				
                // If the value is a dictionary or array, use it to create or update an resource                
                if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                    newRelatedResources = [relationshipClass build:value];
                    if ([newRelatedResources isKindOfClass:[NSArray class]])
                        newRelatedResources = [NSMutableSet setWithArray:newRelatedResources];
                }
                
                // Otherwise, if the value is a resource itself, use it directly
                else if ([value isKindOfClass:relationshipClass])
                    newRelatedResources = value;
				
                // ===== Apply related resources to self ===== //
                
                NSString *rule = [relationshipOptions objectForKey:@"rule"];
                
                // To-many relationships
                if ([relationshipDescription isToMany]) {
                    
                    // If rule is to add, append new objects to existing
                    if ([rule isEqualToString:@"append"])
                        newRelatedResources = [existingRelatedResources setByAddingObjectsFromSet:newRelatedResources];
					
                    // If relationship rule is destroy, destroy all old resources that aren't in the new set
                    else if ([rule isEqualToString:@"destroy"]) {
                        NSSet *danglers = [existingRelatedResources difference:newRelatedResources];
                        for (id dangler in danglers)
                            [dangler remove];
                    }
                    
                    // Default action is to replace the set with no further reprecussions (old resources will still persist)
                    [self setValue:newRelatedResources forKey:localField];
                }
                
                // Singular relationships
                else {
                    // Only process if the new value is different from the current value
                    if (![newRelatedResources isEqual:existingRelatedResources]) {
                        
                        // Set new value
                        [self setValue:newRelatedResources forKey:localField];
                        
                        // If relationship rule is destroy, get rid of the old resource
                        if ([rule isEqualToString:@"destroy"])
                            [existingRelatedResources remove];
                    }
                }
            }
            
            // If it's an attribute, just assign the value to the object (unless the object is up-to-date)
            else if ([propertyDescription isKindOfClass:[NSAttributeDescription class]]) {                
                
                //if ([[self class] activeManager].logLevel > 4)
                  //  NSLog(@"[%@] Setting remote field: %@, local field: %@, value: %@", [self class], field, localField, value);
                
                // Check if value is NSNull, which should be set as nil on fields (since NSNull is just used as a collection placeholder)
                if ([value isEqual:[NSNull null]])
                    [self setValue:nil forKey:localField];
				
                else {
                    // Perform additional processing on value based on attribute type
                    switch ([(NSAttributeDescription *)propertyDescription attributeType]) {
							
                        case NSDateAttributeType:
                            if (value != nil && [value isKindOfClass:[NSString class]]){
								
							}
                                value = [[[self class] activeManager].defaultDateParser dateFromString:value];
                            break;
							
						case NSInteger16AttributeType:
						case NSInteger32AttributeType:
						case NSInteger64AttributeType:
							value = $I([value intValue]);
							break;
						
						case NSFloatAttributeType:
						case NSDecimalAttributeType:
							value = $F([value floatValue]);
							break;
						
						case NSDoubleAttributeType:
							value = [NSNumber numberWithDouble:[value doubleValue]];
							break;
						
						case NSBooleanAttributeType:
							value = [NSNumber numberWithBool:[value boolValue]];
							break;
                    }
					
                    [self setValue:value forKey:localField];
                }
            }
        }
    }
	
	return self;
}

+ (id) update:(NSDictionary *)data predicate:(NSPredicate *)predicate{
	
	ActiveResult *results = [self find:predicate];
	
	for(id row in [results objects]){
	
		[row update:data];
	}
	
	return self;
}

- (BOOL) shouldUpdateWith:(NSDictionary *)dict {
	
    SEL updatedAtSel = NSSelectorFromString([[self class] updatedAtField]);
	
    if ([self respondsToSelector:updatedAtSel]) {
		
        NSDate *updatedAt = (NSDate *)[self performSelector:updatedAtSel];
		
        if (updatedAt != nil) {
			
            NSString *dictUpdatedAtString = [dict objectForKey:[[self class] updatedAtField]];
			
            if (dictUpdatedAtString != nil) {
				
                NSDate *dictUpdatedAt = [[[self class] activeManager].defaultDateParser dateFromString:dictUpdatedAtString];
				
                if (updatedAt != nil) {
                    return [updatedAt compare:dictUpdatedAt] == NSOrderedAscending;
                }
            }
        }
    }
	
    return YES;
}

#pragma mark -
#pragma mark Remove

+ (void) removeAll{

	[self remove:nil];
}

+ (void) remove:(NSPredicate *) predicate{
	
	ActiveResult *results = [self find:predicate];
	
	for(id row in [results objects]){
		
		[row remove];
	}
}

- (void) remove{
	
	[[self managedObjectContext] deleteObject:self];
}




#pragma mark -
#pragma mark Remote

+ (NSString *) remoteURLForAction:(Action)action{
	
	return [[[[self entityName] lowercaseString] underscore] pluralForm];
}

- (NSString *) resourceURLForAction:(Action)action{
	
	return $S(@"%@/%i", [[self class] remoteURLForAction:action], [[self valueForKey:[[self class] localIDField]] intValue]);
}

- (NSString *) relationshipURL:(NSString *) relationship forAction:(Action) action{
	
	return $S(@"%@/%@", [self resourceURLForAction:action], relationship);
}

- (void) fetch{
	
	ActiveRequest *request = [ActiveRequest new];
	[request setUrlPath:[self resourceURLForAction:Read]];
	[request setHttpMethod:@"GET"];
	[request setDelegate:[self class]];

	[[[self class] activeManager] addRequest:request];	
	[request release];
}

- (void) push{
	
	ActiveRequest *request = [ActiveRequest new];
	[request setUrlPath:[self resourceURLForAction:Update]];
	[request setDelegate:[self class]];
	
	[request setHttpMethod:@"POST"];
	
	if([self isUpdated])
		[request setHttpMethod:@"PUT"];
	else if([self isDeleted])
		[request setHttpMethod:@"DELETE"];
	
	if(![self isDeleted])
		[request setHttpBody:[[[self class] activeManager] serializeObject:[self properties:$D([NSNumber numberWithBool:YES], @"$serializeDates")]]];
		
	[[[self class] activeManager] addRequest:request];
	[request release];
}

+ (void) pull{
	
	ActiveRequest *request = [ActiveRequest new];
	[request setUrlPath:[self remoteURLForAction:Read]];
	[request setDelegate:self];
	
	[[self activeManager] addRequest:request];
	[request release];
}


#pragma mark -
#pragma mark Remote Delegate

+ (void) connectionDidFinish:(ActiveResult *) result{
	
	for(ActiveRecord *record in [result objects])
		[self build:record];
	
	[self save];
}

+ (void) connectionDidFail:(ActiveResult *) result{
	
	NSLog(@"Connection Failed: %@", [result error]);
}





#pragma mark -
#pragma mark Settings


+ (NSString *) localIDField{
	
	return @"id";
}

+ (NSString *) remoteIDField{
	
	return @"id";
}

+ (NSString *) defaultSort{
	
	return @"id DESC";
}

+ (NSString *) createdAtField{
	
	return @"created_at";
}

+ (NSString *) updatedAtField{
	
	return @"updated_at";
}

+ (NSString *) dateFormat{

	return @"yyyy-MM-dd'T'HH:mm:ssZZZ";
}

+ (BOOL) remoteEnabled{
	
	return YES;
}


- (void) didCreate {}

+ (NSDictionary *) defaultCreateOptions { return nil; }

+ (NSDictionary *) defaultCreateOrUpdateOptions { return [self defaultCreateOptions]; }

+ (NSDictionary *) defaultUpdateOptions { return nil; }


- (void) dealloc{
		
	[super dealloc];
}

@end


