//
//  ActiveManagerTest.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/3/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveManager.h"

@interface ActiveManagerTest : SenTestCase{	

	ActiveManager *_activeManager;
}

@end

@implementation ActiveManagerTest

- (void) setUp{
	
	_activeManager = [ActiveManager shared];
}

- (void) testShouldVerifyBaseUrl{
	
	[_activeManager setBaseURL:@"mndcreative.com"];
	STAssertEqualObjects(_activeManager.baseURL, @"http://mndcreative.com/", @"Failed to format url");
	
	[_activeManager setBaseURL:@"http://mndcreative.com"];
	STAssertEqualObjects(_activeManager.baseURL, @"http://mndcreative.com/", @"Failed to format url");
	
	[_activeManager setBaseURL:@"http://mndcreative.com/"];
	STAssertEqualObjects(_activeManager.baseURL, @"http://mndcreative.com/", @"Failed to format url");
}

@end