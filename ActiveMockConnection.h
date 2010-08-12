//
//  ActiveMockConnection.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActiveMockConnection : NSObject <ActiveConnection>{

	ActiveRequest *_request;
	id	_delegate;
	SEL	_didFinishSelector;
	SEL _didFailSelector;
}

@property (nonatomic, retain) ActiveRequest *request;
@property (nonatomic, copy) id delegate;
@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didFailSelector;

- (void) send:(ActiveRequest *)request;

@end
