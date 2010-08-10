//
//  NSManagedObjectContext+Additions.m
//  Shopify_Mobile
//
//  Created by Matthew Newberry on 7/12/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "NSManagedObjectContext+Additions.h"

static NSManagedObjectContext *_sharedInstance;

@implementation NSManagedObjectContext (NSManagedObjectContext_Additions)


+ (NSManagedObjectContext *) shared{
	
	if(!_sharedInstance){
		
		id delegate	= [[UIApplication sharedApplication] delegate];
		_sharedInstance	= [delegate managedObjectContext];
	}
	
	return _sharedInstance;
}

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

+ (NSManagedObjectContext *) create{
	
	NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
	[moc setPersistentStoreCoordinator:[[NSManagedObjectContext shared] persistentStoreCoordinator]];
	
	[[NSNotificationCenter defaultCenter] addObserver:[[UIApplication sharedApplication] delegate] selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
	
	return [moc autorelease];
}



@end
