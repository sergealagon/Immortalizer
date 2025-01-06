/* 
    Copyright (C) 2024  Serge Alagon

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>. 
*/

#import <Foundation/Foundation.h>
#import "IPBRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <AltList/ATLApplicationListSubcontrollerController.h>
#import "Localizer.h"

@implementation IPBRootListController
-(NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    [self localizeSpecifiers:_specifiers];

    return _specifiers;
}

-(void)sourceCode {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sergealagon/Immortalizer/"] withCompletionHandler:nil];
}

-(void)supportPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buymeacoffee.com/sergy"] withCompletionHandler:nil];
}

-(void)socialPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://x.com/@srgndrlgn"] withCompletionHandler:nil];
}

- (void)localizeSpecifiers:(NSArray *)specifiers {
    for (PSSpecifier *specifier in specifiers) {
        NSString *labelKey = specifier.properties[@"label"];
        NSString *footerTextKey = specifier.properties[@"footerText"];
        NSArray *validTitles = specifier.properties[@"validTitles"];

        if (labelKey) specifier.name = localizer(labelKey);
        if (footerTextKey) [specifier setProperty:localizer(footerTextKey) forKey:@"footerText"];

        if (validTitles) {
            NSMutableDictionary *mutableTitleDictionary = [NSMutableDictionary dictionary];
            for (NSUInteger i = 0; i < validTitles.count; i++) {
                mutableTitleDictionary[@(i)] = localizer(validTitles[i]);  
            }

            specifier.titleDictionary = [mutableTitleDictionary copy];
        }

    }
}
@end
