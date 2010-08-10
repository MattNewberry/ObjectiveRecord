//
//  ActiveResult.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveRecord;

@interface ActiveResult : NSObject {

	NSArray *_objects;
	NSError *_error;
}

@property (nonatomic, retain, readonly) NSArray *objects;
@property (nonatomic, retain, readonly) NSError *error;

- (id) initWithResults:(NSArray *)results;

- (ActiveRecord *) object;
- (BOOL) hasObjects;
- (int) count;




@end
