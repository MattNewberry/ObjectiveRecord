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
	NSString *_urlPath;
    NSDictionary *_headers;
	
	id _source;
}

@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, retain) id source;
@property (nonatomic, retain) NSArray *objects;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSDictionary *headers;

- (id) initWithResults:(NSArray *)results;
- (id) initWithSource:(id) resultSource;
- (id) initWithError:(NSError*) errorRef;

- (id) object;
- (BOOL) hasObjects;
- (int) count;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;



@end
