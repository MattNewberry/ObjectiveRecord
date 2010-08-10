/*
	An implementation of the Ruby on Rails inflector in Objective-C.
	Ciarán Walsh, 2008

	See README.mdown for usage info.

	Use ⌃R on the following line in TextMate to run tests:
	g++ "$TM_FILEPATH" "$(dirname "$TM_FILEPATH")"/RegexKitLite/RegexKitLite.m -licucore -DTEST_INFLECTOR -framework Cocoa -o "${TM_FILEPATH%.*}" && ("${TM_FILEPATH%.*}"; rm "${TM_FILEPATH%.*}")
*/

#import "CWInflector.h"
#import "RegexKitLite/RegexKitLite.h"

@implementation CWInflector
static CWInflector* sharedInstance = nil;

+ (CWInflector*)inflector;
{
	return sharedInstance ?: [[self new] autorelease];
}

- (id)init
{
	if(sharedInstance)
	{
		[self release];
	}
	else if(self = sharedInstance = [[super init] retain])
	{
		plurals      = [NSMutableArray new];
		singulars    = [NSMutableArray new];
		uncountables = [NSMutableArray new];
		[self addInflectionsFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"inflections" ofType:@"plist"]];
	}
	return sharedInstance;
}

- (void)dealloc
{
	[plurals release];
	[singulars release];
	[uncountables release];
	[super dealloc];
}

- (void)addInflectionsFromFile:(NSString*)path;
{
	NSDictionary* inflections = [NSDictionary dictionaryWithContentsOfFile:path];
	[plurals addObjectsFromArray:[inflections objectForKey:@"plurals"]];
	[singulars addObjectsFromArray:[inflections objectForKey:@"singulars"]];
	[uncountables addObjectsFromArray:[inflections objectForKey:@"uncountables"]];

	for(NSArray* irregular in [inflections objectForKey:@"irregulars"])
		[self addIrregular:[irregular objectAtIndex:0] plural:[irregular objectAtIndex:1]];
}

- (void)addIrregular:(NSString*)singular plural:(NSString*)plural;
{
	NSString* pattern      = [NSString stringWithFormat:@"(%C)%@$", [singular characterAtIndex:0], [singular substringFromIndex:1]];
	NSString* substitution = [NSString stringWithFormat:@"$1%@", [plural substringFromIndex:1]];
	[self addPluralPattern:pattern substitution:substitution];

	pattern      = [NSString stringWithFormat:@"(%C)%@$", [plural characterAtIndex:0], [plural substringFromIndex:1]];
	substitution = [NSString stringWithFormat:@"$1%@", [singular substringFromIndex:1]];
	[self addSingularPattern:pattern substitution:substitution];
}

- (void)addPluralPattern:(NSString*)pattern substitution:(NSString*)substitution;
{
	[plurals addObject:[NSArray arrayWithObjects:pattern,substitution,nil]];
}

- (void)addSingularPattern:(NSString*)pattern substitution:(NSString*)substitution;
{
	[singulars addObject:[NSArray arrayWithObjects:pattern,substitution,nil]];
}

- (NSString*)pluralFormOf:(NSString*)singular;
{
	if([uncountables containsObject:[singular lowercaseString]])
		return singular;

	NSEnumerator* enumerator = [plurals reverseObjectEnumerator];
	while(NSArray* conversion = [enumerator nextObject])
	{
		NSString* result = [singular stringByReplacingOccurrencesOfRegex:[conversion objectAtIndex:0] withString:[conversion objectAtIndex:1]];
		if(result && ![result isEqualToString:singular])
			return result;
	}
	return singular;
}

- (NSString*)singularFormOf:(NSString*)plural;
{
	if([uncountables containsObject:[plural lowercaseString]])
		return plural;

	NSEnumerator* enumerator = [singulars reverseObjectEnumerator];
	while(NSArray* conversion = [enumerator nextObject])
	{
		NSString* result = [plural stringByReplacingOccurrencesOfRegex:[conversion objectAtIndex:0] withString:[conversion objectAtIndex:1]];
		if(result && ![result isEqualToString:plural])
			return result;
	}
	return plural;
}

- (NSString*)humanizedFormOf:(NSString*)word;
{
	NSString* result = word;
	if([result length] > 3 && [[result substringFromIndex:([result length]-3)] isEqualToString:@"_id"])
		result = [result substringToIndex:([result length]-3)];
	result = [result stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	return [[[result substringToIndex:1] uppercaseString] stringByAppendingString:[result substringFromIndex:1]];
}
@end

@implementation NSString (InflectorAdditions)
- (NSString*)pluralForm    { return [[CWInflector inflector] pluralFormOf:self];    }
- (NSString*)singularForm  { return [[CWInflector inflector] singularFormOf:self];  }
- (NSString*)humanizedForm { return [[CWInflector inflector] humanizedFormOf:self]; }
@end

#ifdef TEST_INFLECTOR
#include <assert.h>

int main() {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	assert([CWInflector inflector] == [CWInflector inflector]);

	NSString* plistPath = [[[NSString stringWithUTF8String:__FILE__] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"inflections.plist"];
	[[CWInflector inflector] addInflectionsFromFile:plistPath];

	assert([[[CWInflector inflector] pluralFormOf:@"Cat"] isEqualToString:@"Cats"]);
	assert([[[CWInflector inflector] pluralFormOf:@"bus"] isEqualToString:@"buses"]);
	assert([[[CWInflector inflector] pluralFormOf:@"man"] isEqualToString:@"men"]);

	assert([[@"Sheep" pluralForm] isEqualToString:@"Sheep"]);

	assert([[[CWInflector inflector] singularFormOf:@"Cats"] isEqualToString:@"Cat"]);
	assert([[[CWInflector inflector] singularFormOf:@"buses"] isEqualToString:@"bus"]);
	assert([[[CWInflector inflector] singularFormOf:@"men"] isEqualToString:@"man"]);

	assert([[@"Sheep" singularForm] isEqualToString:@"Sheep"]);

	assert(![[@"cactus" pluralForm] isEqualToString:@"cacti"]);
	[[CWInflector inflector] addIrregular:@"cactus" plural:@"cacti"];
	assert([[@"cactus" pluralForm] isEqualToString:@"cacti"]);

	printf("Tests passed\n");

	[pool release];
	return 0;
}
#endif
