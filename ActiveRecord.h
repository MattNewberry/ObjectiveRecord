//
//  ActiveRecord.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 7/22/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveConnection.h"

@class ActiveManager, ActiveResult;

const typedef enum {
    Create = 0,
    Read = 1,
    Update = 2,
    Destroy = 3
} Action;

@interface ActiveRecord : NSManagedObject <ActiveConnectionDelegate>{
	
	id		_delegate;
	SEL		_remoteDidFinishSelector;
	SEL		_remoteDidFailSelector;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL remoteDidFinishSelector;
@property (nonatomic, assign) SEL remoteDidFailSelector;


+ (void) save;
+ (ActiveManager *) activeManager;

+ (ActiveResult *) find:(id) query;
+ (id) findByID:(NSNumber *)itemID;
+ (ActiveResult *) find:(id) query limit:(int) limit;
+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy;
+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy limit:(int)limit;
+ (ActiveResult *) find:(id) query sortBy:(NSString *)sortBy limit:(int)limit fields:(NSArray *)fields;

+ (int) count;
+ (int) count:(NSPredicate *) predicate;
+ (NSNumber *) average:(NSString *) property;
+ (NSNumber *) minimum:(NSString *) property;
+ (NSNumber *) maximum:(NSString *) property;
+ (NSNumber *) sum:(NSString *) property;

+ (id) first;
+ (id) last;
+ (NSArray *) all;
+ (BOOL) exists:(NSNumber *) itemID;

+ (id) create:(id)parameters;
+ (id) create:(id)parameters withOptions:(NSDictionary*)options;
+ (id) build:(id)parameters;
+ (id) build:(id)parameters withOptions:(NSDictionary*)options;
+ (void) removeAll;
- (void) remove;
+ (void) remove:(NSPredicate *) predicate;
- (void) update:(NSDictionary *) data;
- (void) update:(NSDictionary *) data withOptions:(NSDictionary *) options;
+ (void) update:(NSDictionary *)data predicate:(NSPredicate *)predicate;
- (BOOL) shouldUpdateWith:(NSDictionary*)dict;

- (void) push;
- (void) fetch;
+ (void) pull;



/*	Utilities	*/

+ (NSString *) remoteURLForAction:(Action) action;
- (NSString *) resourceURLForAction:(Action) action;
- (NSString *) relationshipURL:(NSString *) relationship forAction:(Action) action;

+ (NSManagedObjectContext *) managedObjectContext;
+ (NSString *) entityName;
+ (NSEntityDescription *) entityDescription;
+ (NSFetchRequest *) fetchRequest;
+ (NSString *) localNameForRemoteField:(NSString*)name;
+ (NSString *) remoteNameForLocalField:(NSString*)name;
+ (NSDictionary *) relationshipsByName;
+ (BOOL) hasRelationships;
+ (NSDictionary *) propertiesByName;
+ (NSDictionary *) attributesByName;
+ (NSPropertyDescription *) propertyDescriptionForField:(NSString*)field inModel:(Class)modelClass;
+ (NSPropertyDescription *) propertyDescriptionForField:(NSString*)field;
- (NSMutableDictionary *) properties:(NSDictionary*)options withoutObjects:(NSMutableArray*)withouts;

+ (NSDictionary *) defaultCreateOptions;
+ (NSDictionary *) defaultCreateOrUpdateOptions;
+ (NSDictionary *) defaultUpdateOptions;

+ (NSString *) localIDField;
+ (NSString *) remoteIDField;
+ (NSString *) defaultSort;
+ (NSString *) createdAtField;
+ (NSString *) updatedAtField;
+ (NSString *) dateFormat;

- (void) didCreate;
+ (BOOL) remoteEnabled;

- (NSData *) toData;

- (NSDictionary *) map;

@end
