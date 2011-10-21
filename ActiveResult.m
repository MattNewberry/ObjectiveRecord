//
//  ActiveResult.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "ActiveResult.h"


@implementation ActiveResult

@synthesize urlPath = _urlPath;
@synthesize source = _source;
@synthesize objects=_objects;
@synthesize error=_error;
@synthesize headers=_headers;

- (id) init{
    
    if(self = [super init]){
        
        self.objects = [NSArray array];
    }
    
    return self;
}

- (id) initWithResults:(NSArray *)results{
	
	if(self = [self init]){
		
		_objects = [results retain];
	}
	
	return self;
}

- (id) initWithSource:(id) resultSource{
	
	if (self = [self init]){
		
		_source = [resultSource retain];
	}
	
	return self;
}

- (id) initWithError:(NSError*) errorRef {
    if (self = [self init]) {
        _error = [errorRef retain];
    }
    return self;
}

- (id) object{
	
	return _objects != nil && [_objects count] > 0 ? [_objects objectAtIndex:0] : nil;
}

- (BOOL) hasObjects{
	
	return !![_objects count] > 0;
}

- (int) count{
	
	return [self hasObjects] ? [_objects count] : 0;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len {
    return [_objects countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (void)dealloc{
	[_objects release];
	[_error release];
    [_headers release];
	[_source release];
	[_urlPath release];
    
	[super dealloc];
}

@end
