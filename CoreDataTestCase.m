//
//  CoreDataTestCase.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/5/10.
//  Copyright (c) 2010 Shopify. All rights reserved.
//

#import "CoreDataTestCase.h"
#import "ActiveSupport.h"
#import "ActiveManager.h"
#import "Order.h"
#import "NSURLConnector.h"
#import "YAJLParsing.h"


@implementation CoreDataTestCase

@synthesize activeManager = _activeManager;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize testData = _testData;

- (void) setUp{
		    		
	_activeManager = [ActiveManager shared];
	[_activeManager setManagedObjectContext:[self managedObjectContext]];
	
	[_activeManager setConnectionClass:[NSURLConnector class]];
	[_activeManager setParsingClass:[YAJLParsing class]];
	
	_testData = [self loadTestData];
	
	[self loadTestRecords];
}

- (NSArray *) loadTestData{
	
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"orders" ofType:@"json"];
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	return [content yajl_JSON];
}

- (void) loadTestRecords{
	
	[Order create:[_testData objectAtIndex:0]];
	[Order create:[_testData objectAtIndex:1]];
	[Order save];
}


- (NSManagedObjectContext *) managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:
						   [NSArray arrayWithObject:[NSBundle bundleWithIdentifier:@"com.jadedpixel.shopify"]]] retain]; 

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return _persistentStoreCoordinator;
}

@end
