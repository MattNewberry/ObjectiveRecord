//
//  YAJLParser.h
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YAJLParsing : NSObject <ActiveParser>{

}

- (NSString *) parseToString:(id)object;

@end
