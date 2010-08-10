//
//  ActiveRequest.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveRequest.h"


@implementation ActiveRequest

@synthesize delegate = _delegate;
@synthesize didFinishSelector = _didFinishSelector;
@synthesize didFailSelector = _didFailSelector;
@synthesize urlPath = _urlPath;
@synthesize httpMethod = _httpMethod;
@synthesize httpBody = _httpBody;
@synthesize parameters = _parameters;
@synthesize headers = _headers;
@synthesize contentType = _contentType;

- (void)dealloc
{
	[_urlPath release];
	[_httpMethod release];
	[_httpBody release];
	[_parameters release];
	[_headers release];
	[_contentType release];

	[super dealloc];
}

@end
