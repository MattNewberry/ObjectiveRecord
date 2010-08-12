//
//  YAJLParser.m
//  ObjectiveRecord
//
//  Created by Matthew Newberry on 8/11/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "YAJLParsing.h"


@implementation YAJLParsing

- (NSString *) parseToString:(id) object{
	
	return [object yajl_JSONString];
}

- (id) parse:(id) object{
	
	return [object yajl_JSON];
}

@end
