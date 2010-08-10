//
//  ActiveManager.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveManager.h"
#import "ActiveConnection.h"

#define OR_CORE_DATE_STORE_TYPE		NSSQLiteStoreType
#define OR_CORE_DATE_STORE_NAME		@"CoreData.sqlite"
#define OR_CORE_DATE_BATCH_SIZE		25

static ActiveManager *_shared;

@implementation ActiveManager

@synthesize baseURL = _baseURL;
@synthesize connectionClass = _connectionClass;
@synthesize defaultDateFormat = _defaultDateFormat;
@synthesize logLevel;
@synthesize defaultDateParser = _defaultDateParser;
@synthesize entityDescriptions = _entityDescriptions;
@synthesize modelProperties = _modelProperties;
@synthesize modelRelationships = _modelRelationships;
@synthesize modelAttributes = _modelAttributes;
@synthesize requestQueue = _requestQueue;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (ActiveManager *) shared{
	
	if(_shared == nil)
		_shared = [[ActiveManager alloc] init];
	
	return _shared;
}

- (id) init{
	
	return [self initWithManagedObjectContext:nil];
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext *) moc{
	
	if(self = [super init]){
		
		self.requestQueue = [[NSOperationQueue alloc] init];
		
		self.managedObjectContext = moc == nil ? [self managedObjectContext] : moc;
		self.persistentStoreCoordinator = moc == nil ? [self persistentStoreCoordinator] : [moc persistentStoreCoordinator];
		self.managedObjectModel = moc == nil ? [self managedObjectModel] : [[moc persistentStoreCoordinator] managedObjectModel];
		
		self.defaultDateParser = [[NSDateFormatter alloc] init];
        [self.defaultDateParser setDateFormat:self.defaultDateFormat];
        
		self.entityDescriptions = [NSMutableDictionary dictionary];
        self.modelProperties = [NSMutableDictionary dictionary];
        self.modelRelationships = [NSMutableDictionary dictionary];
		
		self.logLevel = 2;
	}
	
	return self;
}

- (void) addRequest:(ActiveRequest *) request{
	
	id conn = [_connectionClass new];
	
	[request setUrlPath:[_baseURL stringByAppendingString:request.urlPath]];
	
	NSInvocationOperation <ActiveConnection> *operation = [[NSInvocationOperation alloc] initWithTarget:conn selector:@selector(send:) object:request];	
	[_requestQueue addOperation:operation];
	[operation release];
	[conn release];
}


- (void) setBaseURL:(NSString *) url{
	
	_baseURL = @"";
	
	if([url rangeOfString:@"http://"].location == NSNotFound)
		_baseURL = @"http://";
	
	_baseURL = [_baseURL stringByAppendingString:url];
	
	if(![[_baseURL substringWithRange:NSMakeRange([_baseURL length] - 1, 1)] isEqual:@"/"])
		_baseURL = [_baseURL stringByAppendingString:@"/"];
}


/*	Core Data		*/

- (NSManagedObjectContext*) managedObjectContext {
	if( _managedObjectContext != nil ) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator: coordinator];
		[_managedObjectContext setUndoManager:nil];
		[_managedObjectContext setRetainsRegisteredObjects:YES];
	}
	return _managedObjectContext;
}


- (NSManagedObjectModel*) managedObjectModel {
	if( _managedObjectModel != nil ) {
		return _managedObjectModel;
	}
	_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	return _managedObjectModel;
}


- (NSString*) storePath {
	return [[self applicationDocumentsDirectory]
			stringByAppendingPathComponent: OR_CORE_DATE_STORE_NAME];
}


- (NSURL*) storeUrl {
	return [NSURL fileURLWithPath:[self storePath]];
}


- (NSDictionary*) migrationOptions {
	return nil;
}


- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
	if( _persistentStoreCoordinator != nil ) {
		return _persistentStoreCoordinator;
	}
	
	NSString* storePath = [self storePath];
	NSURL *storeUrl = [self storeUrl];
	
	NSError* error;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								  initWithManagedObjectModel: [self managedObjectModel]];
	
	NSDictionary* options = [self migrationOptions];
	
	// Check whether the store already exists or not.
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL exists = [fileManager fileExistsAtPath:storePath];
	
	if(!exists ) {
		_modelCreated = YES;
	} else {
		if( _resetModel ||
		   [[NSUserDefaults standardUserDefaults] boolForKey:@"erase_all_preference"] ) {
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"erase_all_preference"];
			[fileManager removeItemAtPath:storePath error:nil];
			_modelCreated = YES;
		}
	}
	
	if (![_persistentStoreCoordinator
		  addPersistentStoreWithType: OR_CORE_DATE_STORE_TYPE
		  configuration: nil
		  URL: storeUrl
		  options: options
		  error: &error
		  ]) {
		// We couldn't add the persistent store, so let's wipe it out and try again.
		[fileManager removeItemAtPath:storePath error:nil];
		_modelCreated = YES;
		
		if (![_persistentStoreCoordinator
			  addPersistentStoreWithType: OR_CORE_DATE_STORE_TYPE
			  configuration: nil
			  URL: storeUrl
			  options: nil
			  error: &error
			  ]) {
			// Something is terribly wrong here.
		}
	}
	
	return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)dealloc{
	[_requestQueue release];
	[_managedObjectContext release];
	[_managedObjectModel release];
	[_persistentStoreCoordinator release];

	[_defaultDateParser release];
	[_entityDescriptions release];
	[_modelProperties release];
	[_modelRelationships release];
	[_modelAttributes release];
	[_defaultDateFormat release];
	[_baseURL release];

	[super dealloc];
}

@end
