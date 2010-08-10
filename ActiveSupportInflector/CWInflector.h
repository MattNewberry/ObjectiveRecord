#import <Foundation/Foundation.h>

@interface CWInflector : NSObject
{
	NSMutableArray* plurals;
	NSMutableArray* singulars;
	NSMutableArray* uncountables;
}
+ (CWInflector*)inflector;

- (void)addPluralPattern:(NSString*)pattern substitution:(NSString*)substitution;
- (void)addSingularPattern:(NSString*)pattern substitution:(NSString*)substitution;
- (void)addIrregular:(NSString*)singular plural:(NSString*)plural;
- (void)addInflectionsFromFile:(NSString*)path;

- (NSString*)pluralFormOf:(NSString*)singular;
- (NSString*)singularFormOf:(NSString*)plural;
- (NSString*)humanizedFormOf:(NSString*)word;
@end

@interface NSString (InflectorAdditions)
- (NSString*)pluralForm;
- (NSString*)singularForm;
- (NSString*)humanizedForm;
@end
