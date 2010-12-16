//
//  ActiveRequest.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveRequest.h"


@implementation ActiveRequest

@synthesize didParseObjectSelector = _didParseObjectSelector;
@synthesize totalBatches = _totalBatches;
@synthesize batch = _batch;
@synthesize user = _user;
@synthesize password = _password;
@synthesize delegate = _delegate;
@synthesize didFinishSelector = _didFinishSelector;
@synthesize didFailSelector = _didFailSelector;
@synthesize urlPath = _urlPath;
@synthesize httpMethod = _httpMethod;
@synthesize httpBody = _httpBody;
@synthesize parameters = _parameters;
@synthesize headers = _headers;
@synthesize contentType = _contentType;

- (id) initWithURLPath:(NSString *) url{
	
	if(self = [super init]){
		
		self.urlPath = url;
		_parameters = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (ActiveRequest *) requestWithURLPath:(NSString *) url{
	
	return [[[ActiveRequest alloc] initWithURLPath:url] autorelease];
}

- (void) addParameters:(NSDictionary *) params{
	
	[_parameters addEntriesFromDictionary:params];
}

- (void)dealloc
{
	[_urlPath release];
	[_httpMethod release];
	[_httpBody release];
	[_parameters release];
	[_headers release];
	[_contentType release];

	[_user release];
	[_password release];




	[super dealloc];
}

@end
