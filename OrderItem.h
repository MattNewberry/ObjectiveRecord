//
//  OrderItem.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/5/10.
//  Copyright 2010 Jaded Pixel Technologies Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ActiveRecord.h"

@class Order;

@interface OrderItem :  ActiveRecord  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) Order * order;

@end



