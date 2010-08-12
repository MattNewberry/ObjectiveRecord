//
//  ActiveMockConnection.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveMockConnection.h"


@implementation ActiveMockConnection

@synthesize request = _request;
@synthesize delegate = _delegate;
@synthesize didFinishSelector = _didFinishSelector;
@synthesize didFailSelector = _didFailSelector;

- (void) send:(ActiveRequest *)request{
	
	
}

- (void) mockPOST{
	
}

- (void) mockGET{
	
}

- (void) mockPUT{
	
}

- (void) mockDELETE{
	
}



- (void)dealloc
{
	[_request release];
	[_delegate release];

	[super dealloc];
}

@end
