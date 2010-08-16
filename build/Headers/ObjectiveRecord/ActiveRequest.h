//
//  ActiveRequest.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActiveRequest : NSObject {

	NSString		*_urlPath;
	NSString		*_httpMethod;
	NSData			*_httpBody;
	NSDictionary	*_parameters;
	NSDictionary	*_headers;
	NSString		*_contentType;
	NSString		*_user;
	NSString		*_password;
	
	id				_delegate;
	SEL				_didFinishSelector;
	SEL				_didFailSelector;
}

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didFailSelector;
@property (nonatomic, retain) NSString *urlPath;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSData *httpBody;
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSString *contentType;

@end
