#import <Foundation/Foundation.h>

/*
#define NSLocalizedBundleStringOverride(key, comment) \
[[NSBundle bundleWithPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle"] localizedStringForKey:(key) value:@"" table:nil]
*/


static NSString * NSLocalizedBundleString(NSString * translation_key, id meh) { //Oh what a lovely lovely hack this is eh? Thank you stackoverflow Kent Nguyen in 2012.  Modified this example so it loads from the bundle we need.
    NSString * s = [[NSBundle bundleWithPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle"] localizedStringForKey:(translation_key) value:@"" table:nil];
    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"] && [s isEqualToString:translation_key]) {
    NSString * path = [[NSBundle bundleWithPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle"] pathForResource:@"en" ofType:@"lproj"];
    NSBundle * languageBundle = [NSBundle bundleWithPath:path];
    s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}