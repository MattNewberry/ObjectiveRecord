//
//  ActiveResult.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveResult.h"


@implementation ActiveResult

@synthesize objects=_objects;
@synthesize error=_error;

- (id) initWithResults:(NSArray *)results{
	
	if(self = [super init]){
		
		_objects = [results retain];
	}
	
	return self;
}

- (void)dealloc{
	[_objects release];
	[_error release];

	[super dealloc];
}

- (ActiveRecord *) object{
	
	return _objects != nil && [_objects count] > 0 ? [_objects objectAtIndex:0] : nil;
}

- (BOOL) hasObjects{
	
	return [_objects count] > 0 ? NO : YES;
}

- (int) count{
	
	return [self hasObjects] ? [_objects count] : 0;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len {
    return [_objects countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
