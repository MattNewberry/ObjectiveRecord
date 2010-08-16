//
//  NSURLConnector.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveConnection.h"

@interface NSURLConnector : NSObject <ActiveConnection>{

	ActiveRequest *_request;
	id	_delegate;
	SEL	_didFinishSelector;
	SEL _didFailSelector;
	
	NSMutableData	*_responseData;
	BOOL	_finished;
}

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic) BOOL finished;
@property (nonatomic, retain) ActiveRequest *request;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didFailSelector;

- (void) send:(ActiveRequest *)activeRequest;

@end
