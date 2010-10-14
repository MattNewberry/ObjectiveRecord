//
//  ActiveManager.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveManager : NSObject {
	
	NSOperationQueue *_requestQueue;
	
	NSManagedObjectContext *_managedObjectContext;
	NSManagedObjectModel *_managedObjectModel;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
			
	BOOL _modelCreated;
	BOOL _resetModel;
	
	NSDateFormatter *_defaultDateParser;
    
    NSMutableDictionary *_entityDescriptions;
    NSMutableDictionary *_modelProperties;
    NSMutableDictionary *_modelRelationships;
    NSMutableDictionary *_modelAttributes;
	
	int logLevel;
	
	id _connectionClass;
	id _activeConnection;
	id _parsingClass;
	
	
	NSString *_baseRemoteURL;
	NSString *_remoteContentType;
	NSString *_remoteContentFormat;
}

@property (nonatomic, retain) id activeConnection;
@property (nonatomic, copy) NSString *remoteContentFormat;
@property (nonatomic, copy) NSString *remoteContentType;
@property (nonatomic, assign) id parsingClass;
@property (nonatomic, retain) NSString *baseRemoteURL;
@property (nonatomic, assign) id connectionClass;
@property (nonatomic, assign) int logLevel;
@property (nonatomic, retain) NSDateFormatter *defaultDateParser;
@property (nonatomic, retain) NSMutableDictionary *entityDescriptions;
@property (nonatomic, retain) NSMutableDictionary *modelProperties;
@property (nonatomic, retain) NSMutableDictionary *modelRelationships;
@property (nonatomic, retain) NSMutableDictionary *modelAttributes;
@property (nonatomic, retain) NSOperationQueue *requestQueue;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ActiveManager *) shared;
- (id) initWithManagedObjectContext:(NSManagedObjectContext *) moc;

- (void) addRequest:(ActiveRequest *) request;
- (void) addRequest:(ActiveRequest *) request delegate:(id) delegate didParseObjectSelector:(SEL)didParseObjectSelector didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;
- (void) addRequest:(ActiveRequest *) request didParseObjectBlock:(void(^)(id object))didParseObjectBlock didFinishBlock:(void(^)(ActiveResult *result))didFinishBlock didFailBlock:(void(^)(ActiveResult *result))didFailBlock;

- (ActiveResult *) addSyncronousRequest:(ActiveRequest *)request;
- (void) addSyncronousRequest:(ActiveRequest *)request delegate:(id) delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;
- (void) addSyncronousRequest:(ActiveRequest *)request didFinishBlock:(void(^)(ActiveResult *result))didFinishBlock didFailBlock:(void(^)(ActiveResult *result))didFailBlock;


- (NSData *) serializeObject:(id) object;

- (NSManagedObjectContext *) newManagedObjectContext;
- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *) managedObjectModel;
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;
- (NSString *) applicationDocumentsDirectory;

@end
