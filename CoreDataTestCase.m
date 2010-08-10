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

@implementation CoreDataTestCase

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize testData = _testData;


- (void) setUp{
		    		
	ActiveManager *manager = [ActiveManager shared];
	[manager setManagedObjectContext:[self managedObjectContext]];
	
	_testData = [self loadTestData];
	
	[self loadTestRecords];
}

- (NSArray *) loadTestData{
	
	/*
	 [{"id":1, "name":"Matthew Newberry", "created_at":"2010-05-30T18:18:00+01:00", "price":599.99, "items":[{"id":1, "name":"iPhone 4", "price":599.99, "qty":1}]},{"id":2, "name":"Tobias Lütke", "created_at":"2010-05-30T18:18:00+01:00", "price":1499.98, "items":[{"id":2,"name":"iPhone 4", "price":599.99, "qty":1},{"id":3,"name":"iPad", "price":899.99, "qty":1}]}]
	 */
	
	return $A($D(@"1", @"id", @"Matthew Newberry", @"name", @"2010-05-30T18:18:00+01:00", @"created_at", @"599.99", @"price", $A($D(@"1", @"id", @"iPhone 4", @"name", @"599.99", @"price", @"1", @"qty")), @"items"), $D(@"2", @"id", @"Tobias Lütke", @"name", @"2010-05-30T18:18:00+01:00", @"created_at", @"1499.98", @"price", $A($D(@"2", @"id", @"iPhone 4", @"name", @"599.99", @"price", @"1", @"qty"),$D(@"3", @"id", @"iPad", @"name", @"899.99", @"price", @"1", @"qty")), @"items"));
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
