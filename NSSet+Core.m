//
//  NSSet+Core.m
//  Core Resource
//
//  Created by Mike Laurence on 2/5/10.
//  Copyright 2010 Mike Laurence. 
//

#import "NSSet+Core.h"


@implementation NSSet (Core)

- (NSSet*) intersection:(NSSet*)otherSet {
    NSMutableSet *intersection = [self mutableCopy];
	[intersection intersectSet:otherSet];
	return [intersection autorelease];
}

- (NSSet*) difference:(NSSet*)otherSet {
    NSMutableSet *difference = [self mutableCopy];
    [difference minusSet:otherSet];
    return [difference autorelease];
}

- (id) objectOfClass:(Class)clazz {
    for (id obj in self) {
        if ([obj isKindOfClass:clazz])
            return obj;
    }
    return nil;
}

- (id) firstObject{
	
	return [[self allObjects] count] > 0 ? [[self allObjects] objectAtIndex:0] : nil;
}
- (id) lastObject{
	
	return [[self allObjects] count] > 0 ? [[self allObjects] objectAtIndex:([self count] -1)] : nil;
}

@end
