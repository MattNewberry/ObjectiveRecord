//
//  Order.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/5/10.
//  Copyright 2010 Jaded Pixel Technologies Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ActiveRecord.h"

@class OrderItem;

@interface Order :  ActiveRecord  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSSet* items;

@end


@interface Order (CoreDataGeneratedAccessors)
- (void)addItemsObject:(OrderItem *)value;
- (void)removeItemsObject:(OrderItem *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end

