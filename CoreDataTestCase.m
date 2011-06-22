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
	[_activeManager setParsingClass:[YAJLParsing class]];
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
                            [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]] retain]; 

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
