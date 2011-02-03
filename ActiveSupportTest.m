//
//  ActiveSupportTest.m
//  ObjectiveRecord
//
//  Created by Matt Newberry on 1/19/11.
//  Copyright 2011 Shopify. All rights reserved.
//

#import "NSString+InflectionSupport.h"

@interface ActiveSupportTest : SenTestCase{	}
@end

@implementation ActiveSupportTest

- (void) testTitelizeString{
	
	STAssertEqualObjects([@"mAtT newberry" titleize], @"Matt Newberry", @"");
	STAssertEqualObjects([@"matt " titleize], @"Matt", @"");
	STAssertEqualObjects([@"" titleize], @"", @"");
	STAssertEqualObjects([@"     matt" titleize], @"Matt", @"");
	STAssertEqualObjects([@"y our mydfd  GG" titleize], @"Y Our Mydfd Gg", @"");
}

@end
