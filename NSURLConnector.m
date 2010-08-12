//
//  NSURLConnector.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "NSURLConnector.h"


@implementation NSURLConnector

@synthesize responseData = _responseData;
@synthesize finished = _finished;
@synthesize request = _request;
@synthesize delegate = _delegate;
@synthesize didFinishSelector = _didFinishSelector;
@synthesize didFailSelector = _didFailSelector;

- (id) init{
	
	if(self = [super init]){
		
		self.responseData = [[NSMutableData alloc] init];
		self.finished = NO;
	}
	
	return self;
}

- (void) send:(ActiveRequest *)request{
		
	self.request = request;
		
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[request.urlPath stringByAddingPercentEscapesUsingEncoding:4]]];
	
	[urlRequest setHTTPMethod:request.httpMethod];
	[urlRequest setHTTPBody:request.httpBody];
	[urlRequest setAllHTTPHeaderFields:$D(@"application/json", @"Content-type")];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[connection start];
		
	NSLog(@"starting connection");
	
	while (!_finished) {			
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:30.0]];
	}
	
	NSString *response = [[[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding] autorelease];	
	
	ActiveResult *result = [[[ActiveResult alloc] initWithResults:[response yajl_JSON]] autorelease];
	NSLog(@"%@", [result objects]);
	
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
	NSLog(@"received auth challenge!!!!!!!!!!!!!!!!!");
	
	if([challenge previousFailureCount] == 0){
		
		NSURLCredential *credential = [NSURLCredential credentialWithUser:_request.user password:_request.password persistence:NSURLCredentialPersistenceNone];
		
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];		
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	
	[_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

	_finished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	_finished = YES;
}


- (void)dealloc{
	[_request release];
	[_responseData release];
	
	[super dealloc];
}

@end
