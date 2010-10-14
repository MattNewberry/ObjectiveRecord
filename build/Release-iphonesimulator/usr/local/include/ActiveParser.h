//
//  ActiveParser.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//



@protocol ActiveParser

@required
- (NSString *) parseToString:(id) object;
- (id) parse:(id) object;

@end

@protocol ActiveParserDelegate

@end
