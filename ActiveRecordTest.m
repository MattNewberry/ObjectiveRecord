//
//  ActiveRecordTest.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/4/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "CoreDataTestCase.h"
#import "ObjectiveRecord.h"
#import "Order.h"
#import "OrderItem.h"

@interface ActiveRecordTest : CoreDataTestCase{	}
@end

@implementation ActiveRecordTest

- (void) setUp{
    
    [super setUp];
    [_activeManager loadSeedFiles:$A(@"Order.json") groupName:nil];
}

- (void) tearDown{
    
    [Order removeAll];
}

- (void) testShouldLoadSeedData{
    
    STAssertTrue([_activeManager loadAllSeedFiles], @"Failed to seed files");
    STAssertEquals([Order count], 2, @"Failed to seed files");
}

- (void) testShouldLoadHashedSeedData{
    
    [Order removeAll];
    STAssertTrue([_activeManager loadSeedFiles:$A(@"Order_Hash.json") groupName:nil], @"Failed to seed files");
    STAssertEquals([Order count], 2, @"Failed to seed files");
}

- (void) testShouldLoadHashedSeedDataByGroup{
    
    [Order removeAll];
    STAssertTrue([_activeManager loadSeedFiles:$A(@"Order_Hash.json") groupName:@"matt"], @"Failed to seed files");
    STAssertEquals([Order count], 1, @"Failed to seed files");
}

- (void) testShouldLoadSeedsBasedUponClassName{
    
    [Order removeAll];
    [Order seed];
    STAssertEquals([Order count], 2, @"Failed to seed files");
}

- (void) testShouldLoadSeedsBasedUponClassNameAndGroupName{
    
    [Order removeAll];
    [Order seedGroup:@"matt"];
    STAssertEquals([Order count], 1, @"Failed to seed files");
}

- (void) testShouldReturnNameWithoutRelationship{
	
	STAssertEqualObjects([Order entityName], @"Order", @"Failed to match entity name");
	STAssertEqualObjects([OrderItem entityName], @"Item", @"Failed to match entity name");
}

- (void) testShouldCountAllRecords{

	STAssertEquals([Order count], 2, @"Count not equal");
}


- (void) testShouldCountAllRecordsWithPredicate{
	
	STAssertEquals([Order count:$P(@"id = 1")], 1, @"Count not equal with predicate");
}



- (void) testShouldCreateNewRecordFromDictionary{

	Order *order = [Order create:[_testData objectAtIndex:0]];
	
	STAssertTrue([order isInserted], @"Record failed to be inserted");
}

- (void) testShouldCreateNewRecordWithRelationships{
	
	Order *order = [Order first];
	
	STAssertEquals( (int) [order.items count], 2, @"Did not properly create relationships");
}

- (void) testShouldUpdateExistingRecordFromDictionary{
	
	Order *order = [Order create:nil];
	[Order save];
	
	NSDictionary *updatedData = [NSDictionary dictionaryWithObject:@"Cody Fauser" forKey:@"name"];
	[order update:updatedData];
	
	STAssertTrue([order isUpdated], @"Record failed to update");
}




- (void) testShouldFindAllRecords{
			
	STAssertEquals((int) [[Order all] count], 2, @"Failed to return all results");
}

- (void) testShouldFindRecordByID{
		
	STAssertNotNil([Order findByID:$I(1)], @"Failed to find by ID");
}

- (void) testShouldSumProperty{
			
	STAssertEquals([[Order sum:@"price"] floatValue], (float) 2099.97, @"Failed to sum properly");
}

- (void) testShouldFindMaxProperty{
		
	STAssertEquals([[Order maximum:@"price"] floatValue], (float) 1499.98, @"Failed to find maximum property");
}

- (void) testShouldFindMinProperty{
		
	STAssertEquals([[Order minimum:@"price"] floatValue], (float) 599.99, @"Failed to find minimum property");
}

- (void) testShouldFindAvgProperty{
		
	STAssertEquals([[Order average:@"price"] floatValue], (float) 1049.985, @"Failed to find minimum property");
}

- (void) testShouldReturnFirstRecord{
	
	STAssertEquals([[[Order first] id] intValue], 2, @"Failed to find first record"); 
}

- (void) testShouldReturnLastRecord{
	
	STAssertEquals([[[Order last] id] intValue], 1, @"Failed to find first record"); 
}

- (void) testShouldVerifyRecordExists{
	
	STAssertTrue([Order exists:$I(1)], @"Failed to verify record exists");
}

- (void) testShouldVerifyRecordDoesNotExist{
	
	STAssertFalse([Order exists:$I(5)], @"Failed to verify record does not exist");
}



- (void) testShouldRemoveRecord{
	
	Order *order = [Order create:nil];
	[Order save];
	
	[order remove];
	
	STAssertTrue([order isDeleted], @"Record failed to be removed");
}

- (void) testShouldRemoveAllRecords{
		
	[Order removeAll];
	
	STAssertEquals([Order count], 0, @"Did not remove all records");
}

- (void) testShouldRemoveAllFromPredicate{
					
	[Order remove:$P(@"id = 1")];
	
	STAssertEquals([Order count], 1, @"Did not remove record based on a predicate");
}


- (void) testShouldReturnURLForClass{
	
	STAssertEqualObjects([Order remoteURLForAction:Read], @"orders.json", @"Failed to return proper URL");
}

- (void) testShouldReturnURLForRecord{
	
	Order *order = [Order first];

	STAssertEqualObjects([order resourceURLForAction:Read], @"orders/2.json", @"Failed to return proper resource URL");
}

- (void) testShouldReturnURLForRelationshipRecord{
	
	Order *order = [Order last];
	OrderItem *item = [order.items anyObject];

	STAssertEqualObjects([item resourceURLForAction:Read], @"orders/1/items/1.json", @"Failed to return proper relationship URL");
}

- (void) testShouldReturnObjectForURL{
	
	Order *order = [Order last];
	
	STAssertEqualObjects([order relationshipForURLPath:@"orders/1/items.json"], @"items", @"Failed to return object for URL");
	STAssertNil([order relationshipForURLPath:@"orders/1.json"], @"Failed to return nil for relationship url");
}

- (void) testConnectionDidFinishForRelationship{
	
	Order *order = [Order last];
	[order removeItems:order.items];
	[order save];
	
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"items" ofType:@"json"];
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *items = [content yajl_JSON];
	
	ActiveResult *result = [[ActiveResult alloc] initWithResults:items];
	result.urlPath = @"orders/1/items.json";
	
	[order connectionDidFinish:result];
	
	STAssertEquals((int)[order.items count], 1, @"Failed to add relationship items properly");
		
	[result release];
}

- (void) testShouldReturnProperRelationshipForURL{
	
	Order *order = [Order last];
	NSLog(@"%@", [order relationshipForURLPath:@"http://mndcreative.myshopify.com/admin/orders/1/items/1.json"]);
	STAssertEqualObjects([order relationshipForURLPath:@"http://mndcreative.myshopify.com/admin/orders/1/items/1.json"], @"items", @"Failed to return proper relationship for URL");
}


@end
