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
	NSString *_defaultDateFormat;
    
    NSMutableDictionary *_entityDescriptions;
    NSMutableDictionary *_modelProperties;
    NSMutableDictionary *_modelRelationships;
    NSMutableDictionary *_modelAttributes;
	
	int logLevel;
	
	id _connectionClass;
	
	NSString *_baseURL;
}

@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, assign) id connectionClass;
@property (nonatomic, retain) NSString *defaultDateFormat;
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

- (NSManagedObjectContext*) managedObjectContext;
- (NSManagedObjectModel*) managedObjectModel;
- (NSPersistentStoreCoordinator*) persistentStoreCoordinator;
- (NSString *) applicationDocumentsDirectory;

@end
