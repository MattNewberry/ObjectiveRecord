//
//  CoreDataTestCase.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/5/10.
//  Copyright (c) 2010 Shopify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

@class ActiveManager;

@interface CoreDataTestCase : SenTestCase {

    NSManagedObjectContext *_managedObjectContext;
	NSManagedObjectModel *_managedObjectModel;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;  
	
	NSArray *_testData;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSArray *testData;

- (NSArray *) loadTestData;
- (void) loadTestRecords;

@end
