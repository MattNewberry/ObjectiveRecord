//
//  ActiveRequest.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActiveRequest : NSObject {

	NSString			*_urlPath;
	NSString			*_httpMethod;
	NSData				*_httpBody;
	NSMutableDictionary	*_parameters;
	NSDictionary		*_headers;
	NSString			*_contentType;
	NSString			*_user;
	NSString			*_password;
	
	id				_delegate;
	SEL				_didFinishSelector;
	SEL				_didFailSelector;
	SEL				_didParseObjectSelector;
	
	BOOL			_batch;
	NSUInteger _totalBatches;
}

@property (nonatomic, assign) SEL didParseObjectSelector;
@property (nonatomic, assign) NSUInteger totalBatches;
@property (nonatomic, assign) BOOL batch;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didFailSelector;
@property (nonatomic, retain) NSString *urlPath;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSData *httpBody;
@property (nonatomic, retain) NSMutableDictionary *parameters;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSString *contentType;

+ (ActiveRequest *) requestWithURLPath:(NSString *) url;
- (id) initWithURLPath:(NSString *) url;

- (void) addParameters:(NSDictionary *) params;

@end
