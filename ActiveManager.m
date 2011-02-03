//
//  ActiveManager.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveManager.h"
#import "ActiveConnection.h"
#import "NSThread+Blocks.m"

#define OR_CORE_DATE_STORE_TYPE		NSSQLiteStoreType
#define OR_CORE_DATE_STORE_NAME		@"CoreDataStore.sqlite"
#define OR_CORE_DATE_BATCH_SIZE		25
#define kRKManagedObjectContextKey @"RKManagedObjectContext"

static ActiveManager *_shared = nil;

@implementation ActiveManager

@synthesize activeConnection = _activeConnection;
@synthesize remoteContentFormat = _remoteContentFormat;
@synthesize remoteContentType = _remoteContentType;
@synthesize parsingClass = _parsingClass;
@synthesize baseRemoteURL = _baseRemoteURL;
@synthesize connectionClass = _connectionClass;
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
	
	if(self = [super init]){
		
		_requestQueue = [[NSOperationQueue alloc] init];
		self.remoteContentType = @"application/json";
		self.remoteContentFormat = @"json";
	
		self.managedObjectModel = [self managedObjectModel];
		self.persistentStoreCoordinator = [self persistentStoreCoordinator];
		_managedObjectContext = [self newManagedObjectContext];
		
		_defaultDateParser = [[NSDateFormatter alloc] init];
		[_defaultDateParser setTimeZone:[NSTimeZone localTimeZone]];
        
		self.entityDescriptions = [NSMutableDictionary dictionary];
        self.modelProperties = [NSMutableDictionary dictionary];
        self.modelRelationships = [NSMutableDictionary dictionary];
		
		self.logLevel = 2;
	}
	
	return self;
}

- (void) setConnectionClass:(id)activeConnectionClass{
	
	_connectionClass = activeConnectionClass;
}

- (void) addRequest:(ActiveRequest *) request{
	
	[self addRequest:request delegate:request.delegate didParseObjectSelector:request.didParseObjectSelector didFinishSelector:request.didFinishSelector didFailSelector:request.didFailSelector];
}

- (void) addBaseURL:(ActiveRequest *)request{
	
	[request setUrlPath:[[ActiveManager shared].baseRemoteURL stringByAppendingString:request.urlPath]];
}

- (void) addRequest:(ActiveRequest *) request delegate:(id) delegate didParseObjectSelector:(SEL)didParseObjectSelector didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector{
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
				
		id <ActiveConnection> conn = [[[_connectionClass alloc] init] autorelease];
		[conn setResponseDelegate:delegate];
		[conn setDidFinishSelector:didFinishSelector];
		[conn setDidFailSelector:didFailSelector];
		
		[conn send:request];
	});
}

- (void) addRequest:(ActiveRequest *) request didParseObjectBlock:(void(^)(id object))didParseObjectBlock didFinishBlock:(void(^)(ActiveResult *result))didFinishBlock didFailBlock:(void(^)(ActiveResult *result))didFailBlock{
	
	[self addRequest:request toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) didParseObjectBlock:didParseObjectBlock didFinishBlock:didFinishBlock didFailBlock:didFailBlock];
}

- (void) addRequest:(ActiveRequest *) request toQueue:(dispatch_queue_t)queue didParseObjectBlock:(void(^)(id object))didParseObjectBlock didFinishBlock:(void(^)(ActiveResult *result))didFinishBlock didFailBlock:(void(^)(ActiveResult *result))didFailBlock{
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	dispatch_async(queue, ^{
				
		id <ActiveConnection> conn = [[[_connectionClass alloc] init] autorelease];
		[conn setResponseDelegate:request.delegate];
		[conn setDidFailBlock:didFailBlock];
		[conn setDidFinishBlock:didFinishBlock];
		[conn setDidParseObjectBlock:didParseObjectBlock];
		
		[conn send:request];
	});
}

- (ActiveResult *) addSyncronousRequest:(ActiveRequest *)request{
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	return [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
}

- (void) addSyncronousRequest:(ActiveRequest *)request delegate:(id) delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	ActiveResult *result = [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
	
	if(result.error != nil)
		[delegate performSelector:didFinishSelector withObject:result];
	else
		[delegate performSelector:didFailSelector withObject:result];
	
	[pool release];
}

- (void) addSyncronousRequest:(ActiveRequest *)request didFinishBlock:(void(^)(ActiveResult *result))didFinishBlock didFailBlock:(void(^)(ActiveResult *result))didFailBlock{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if([request.urlPath rangeOfString:@"http"].length == 0)
		[self addBaseURL:request];
	
	ActiveResult *result = [[[_connectionClass new] autorelease] performSelector:@selector(sendSyncronously:) withObject:request];
	
	if(result.error != nil)
		[NSThread performBlockOnMainThread:^{
			didFinishBlock(result);
		}];
	else
		[NSThread performBlockOnMainThread:^{
			didFailBlock(result);
		}];
	
	[pool release];
}



- (NSData *) serializeObject:(id)object{
	
	id <ActiveParser> parser = [[[_parsingClass alloc] init] autorelease];
	NSString *string = [parser parseToString:object];
	
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}




/*	Core Data		*/

- (void) managedObjectContextDidSave:(NSNotification *)notification{
		
	[self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
												withObject:notification
											 waitUntilDone:YES];
}

- (void)mergeChanges:(NSNotification *)notification {

	[self performSelectorOnMainThread:@selector(managedObjectContextDidSave:) withObject:notification waitUntilDone:YES];
}

- (NSManagedObjectContext*) newManagedObjectContext{
	
	NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
	[moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[moc setUndoManager:nil];
	[moc setMergePolicy:NSOverwriteMergePolicy];
		
	return moc;
}

- (NSManagedObjectContext*) managedObjectContext {
	
	//Taken from RestKit	
	if ([NSThread isMainThread]) {
		return _managedObjectContext;
		
	} else {
		
		NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
		NSManagedObjectContext *backgroundThreadContext = [threadDictionary objectForKey:kRKManagedObjectContextKey];
		
		if (!backgroundThreadContext) {
			
			backgroundThreadContext = [self newManagedObjectContext];					
			[threadDictionary setObject:backgroundThreadContext forKey:kRKManagedObjectContextKey];			
			[backgroundThreadContext release];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:)
														 name:NSManagedObjectContextDidSaveNotification
													   object:backgroundThreadContext];
		}
		return backgroundThreadContext;
	}
}



- (NSManagedObjectModel*) managedObjectModel {
	if( _managedObjectModel != nil )
		return _managedObjectModel;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Shopify_Mobile" ofType:@"momd"];
	
	if(!path)
		path = [[NSBundle mainBundle] pathForResource:@"Shopify_Mobile" ofType:@"mom"];
	
    NSURL *momURL = [NSURL fileURLWithPath:path];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
	if(!_managedObjectModel)
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
	
	return $D([NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption);
}


- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
	if( _persistentStoreCoordinator != nil ) {
		return _persistentStoreCoordinator;
	}
	
	NSString* storePath = [self storePath];
	NSURL *storeUrl = [self storeUrl];
	
	NSError* error;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								  initWithManagedObjectModel: _managedObjectModel];
	
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
			  options: options
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

- (id)copyWithZone:(NSZone *)zone	{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
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
	[_baseRemoteURL release];

	[_parsingClass release];
	[_remoteContentType release];
	[_remoteContentFormat release];
	[_activeConnection release];

	[super dealloc];
}

@end
