//
//  ActiveManager.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveConnection.h"

@interface ActiveManager : NSObject {
		
	NSManagedObjectContext *_managedObjectContext;
	NSManagedObjectModel *_managedObjectModel;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
			
	BOOL _modelCreated;
	BOOL _resetModel;
	
	NSDateFormatter *_defaultDateParser;
    NSNumberFormatter *_defaultNumberFormatter;
    
    NSMutableDictionary *_entityDescriptions;
    NSMutableDictionary *_modelProperties;
    NSMutableDictionary *_modelRelationships;
    NSMutableDictionary *_modelAttributes;
	
	int _logLevel;
	
	id _connectionClass;
	id _parsingClass;
    id _fixtureParsingClass;
	
	NSString *_baseRemoteURL;
	NSString *_remoteContentType;
	NSString *_remoteContentFormat;
}

@property (nonatomic, retain) NSString *remoteContentFormat;
@property (nonatomic, retain) NSString *remoteContentType;
@property (nonatomic, assign) id parsingClass;
@property (nonatomic, assign) id fixtureParsingClass;
@property (nonatomic, retain) NSString *baseRemoteURL;
@property (nonatomic, assign) id connectionClass;
@property (nonatomic, assign) int logLevel;
@property (nonatomic, retain) NSDateFormatter *defaultDateParser;
@property (nonatomic, retain) NSNumberFormatter *defaultNumberFormatter;
@property (nonatomic, retain) NSMutableDictionary *entityDescriptions;
@property (nonatomic, retain) NSMutableDictionary *modelProperties;
@property (nonatomic, retain) NSMutableDictionary *modelRelationships;
@property (nonatomic, retain) NSMutableDictionary *modelAttributes;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ActiveManager *) shared;

- (void) addRequest:(ActiveRequest *) request;
- (void) addRequest:(ActiveRequest *) request delegate:(id) delegate didParseObjectSelector:(SEL)didParseObjectSelector didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;
- (void) addRequest:(ActiveRequest *) request didParseObjectBlock:(ActiveConnectionDidParseObjectBlock)didParseObjectBlock didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock;
- (void) addRequest:(ActiveRequest *) request toQueue:(dispatch_queue_t)queue didParseObjectBlock:(ActiveConnectionDidParseObjectBlock)didParseObjectBlock didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock;

- (ActiveResult *) addSyncronousRequest:(ActiveRequest *)request;
- (void) addSyncronousRequest:(ActiveRequest *)request delegate:(id) delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;
- (void) addSyncronousRequest:(ActiveRequest *)request didFinishBlock:(ActiveConnectionBlock)didFinishBlock didFailBlock:(ActiveConnectionBlock)didFailBlock;


- (NSData *) serializeObject:(id) object;
- (id) parseString:(NSString *) content;
- (id) parseFixture:(NSString *) content;

- (NSManagedObjectContext *) newManagedObjectContext;
- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *) managedObjectModel;
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;
- (NSString *) applicationDocumentsDirectory;

+ (NSArray *) seedFiles;
- (BOOL) loadAllSeedFiles;
- (BOOL) loadSeedFilesForGroupName:(NSString *) groupName;
- (BOOL) loadSeedFiles:(NSArray *) files groupName:(NSString *) groupName;

@end
