#import "Localizer.h"

NSString *localizer(NSString *key) {
    NSBundle *tweakBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Immortalizer.bundle")];
    if (!tweakBundle) {
        return key; 
    }
    
    NSString *localizedString = [tweakBundle localizedStringForKey:key value:key table:nil];
    
    if ([localizedString isEqualToString:key]) {
        NSBundle *englishBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Immortalizer.bundle/en.lproj")];
        localizedString = [englishBundle localizedStringForKey:key value:key table:nil];
    }
    
    return localizedString;
}
