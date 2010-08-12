//
//  ActiveConnectionTest.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "CoreDataTestCase.h"
#import "Order.h"


@interface ActiveConnectionTest : CoreDataTestCase{	
	
	
}

@end

@implementation ActiveConnectionTest

- (void) setUp{
	
	[super setUp];
	
	[_activeManager setBaseURL:@"mndcreative.myshopify.com/admin/"];
}

- (void) testShouldValidateRequest{

	[[Order first] push];
}


@end