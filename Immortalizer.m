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
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Headers.h"
#import "Immortalizer.h"
#import "CustomToastView.h"

@implementation Immortalizer
+ (instancetype)sharedInstance {
    static Immortalizer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    return self;
}

-(NSString *)getAppNameForBundle:(NSString *)bundle {
    return [[((SBIconController *)[objc_getClass("SBIconController") sharedInstance]).model applicationIconForBundleIdentifier:bundle] displayName];
}

-(void)updateAccessoryForBundle:(NSString *)bundle {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[((SBIconController *)[objc_getClass("SBIconController") sharedInstance]).model applicationIconForBundleIdentifier:bundle] _notifyAccessoriesDidUpdate];
    });
}

-(void)showToastWithTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(UIImage *)icon autoHide:(int)seconds {
    CustomToastView *toast = [[CustomToastView alloc] initWithTitle:title subtitle:subtitle icon:icon autoHide:seconds];
    [toast presentToast];
}

-(NSArray *)getNotificationEnabledApps {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.applist"];
    NSArray *selectedApps = [prefs objectForKey:@"selectedApplications"];
    return selectedApps;
}

-(BOOL)isNotificationEnabledForBundleIdentifier:(NSString *)bundleIdentifier {
    NSArray *selectedApps = [self getNotificationEnabledApps];
    return [selectedApps containsObject:bundleIdentifier];
}
@end
