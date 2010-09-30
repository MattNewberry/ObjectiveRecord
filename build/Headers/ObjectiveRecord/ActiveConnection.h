//
//  ActiveConnection.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 7/22/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveRequest.h"
#import "ActiveResult.h"

const typedef enum{
	ActiveConnectionNotificationDidFinish,
	ActiveConnectionNotificationDidFailWithError
} ActiveConnectionNotificationType;



@protocol ActiveConnection

@optional
- (void) setResponseDelegate:(id) delegate;
- (void) setDidFinishSelector:(SEL) selector;
- (void) setDidFailSelector:(SEL) selector;

@required
- (ActiveResult *) send:(ActiveRequest *) activeRequest;

@end

@protocol ActiveConnectionDelegate

@optional
- (void) connectionDidFinish:(ActiveResult *) result;
- (void) connectionDidFail:(ActiveResult *) result;

@end


