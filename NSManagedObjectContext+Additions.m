//
//  NSManagedObjectContext+Additions.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 7/12/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "NSManagedObjectContext+Additions.h"

@implementation NSManagedObjectContext (NSManagedObjectContext_Additions)


- (BOOL) save{
	
	NSError *error;
	if(![self save:&error]) {
		NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				NSLog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			NSLog(@"  %@", [error userInfo]);
		}
		
		return NO;
	}
	
	return YES;
}

@end
