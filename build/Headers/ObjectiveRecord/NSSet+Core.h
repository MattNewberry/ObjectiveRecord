//
//  NSSet+Core.h
//  Core Resource
//
//  Created by Mike Laurence on 2/5/10.
//  Copyright 2010 Mike Laurence. 
//

#import <Foundation/Foundation.h>


@interface NSSet (Core)

- (NSSet*) intersection:(NSSet*)otherSet;
- (NSSet*) difference:(NSSet*)otherSet;

- (id) objectOfClass:(Class)clazz;

- (id) firstObject;
- (id) lastObject;

@end
