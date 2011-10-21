//
//  ActiveSupport.h
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 8/2/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActiveSupport : NSObject {

}

#define $D(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define $A(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define $MA(...) [NSMutableArray arrayWithObjects: __VA_ARGS__, nil]
#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]
#define $I(i) [NSNumber numberWithInt:i]
#define $B(b) [NSNumber numberWithBool:b]
#define $F(f) [NSNumber numberWithFloat:f]
#define toArray(object) (object != nil ? ([object isKindOfClass:[NSArray class]] ? object : [NSArray arrayWithObject:object]) : [NSArray array])
#define $P(...) [NSPredicate predicateWithFormat:__VA_ARGS__]
#define $SORT(i) [ActiveSupport sortDescriptorsFromString:i]

#pragma mark -
#pragma mark Helpers
+ (NSArray*) sortDescriptorsFromString:(NSString*)string;
+ (NSArray*) sortDescriptorsFromParameters:(id)parameters;
+ (NSURL*) URLWithSite:(NSString*)site andFormat:(NSString*)format andParameters:(id)parameters;

#pragma mark -
#pragma mark Predicates
+ (NSPredicate*) variablePredicateFromObject:(id)object;
+ (NSPredicate*) predicateFromObject:(id)object;
+ (NSPredicate*) equivalencyPredicateForKey:(NSString*)key;

@end
