// 
//  OrderItem.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/5/10.
//  Copyright 2010 Jaded Pixel Technologies Inc. All rights reserved.
//

#import "OrderItem.h"
#import "Order.h"

@implementation OrderItem 

@dynamic id;
@dynamic name;
@dynamic price;
@dynamic qty;
@dynamic order;

- (NSString *) resourceURLForAction:(Action)action{
	
	return $S(@"orders/%i/items/%i", [[self.order id] intValue], [self.id intValue]);
}

@end
