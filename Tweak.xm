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
#import <notify.h>
#import <objc/runtime.h>
#import "Headers.h"
#import "Immortalizer.h"

static BOOL tweakEnabled;
static BOOL isFolderTransitioning = false;
static BOOL isIndicatorEnabled;
static BOOL isToastEnabled;

static void preferencesImmortalizerChanged() {
    Immortalizer *immortalizer = [Immortalizer sharedInstance];
    NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
    NSUserDefaults *const prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizerprefs"];
    tweakEnabled = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
        if (tweakEnabled) {
        for (NSString *bundleIdentifier in immortalBundleIDs) {
            [immortalizer updateAccessoryForBundle:bundleIdentifier];
        }
    } else {
        for (NSString *bundleIdentifier in immortalBundleIDs) {
            [immortalizer updateAccessoryForBundle:bundleIdentifier];
        }
    }
}

static void prefsNotifsChanged() {
    Immortalizer *immortalizer = [Immortalizer sharedInstance];
    NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
    for (NSString * immortalApp in immortalBundleIDs) {
        if ([immortalizer isNotificationEnabledForBundleIdentifier:immortalApp]) {
            [[%c(UNSUserNotificationServer) sharedInstance] _didChangeApplicationState:4 forBundleIdentifier:immortalApp];
        } else {
            [[%c(UNSUserNotificationServer) sharedInstance] _didChangeApplicationState:8 forBundleIdentifier:immortalApp];
        }
    }
}

static void prefsIndicatorChanged() {
    NSUserDefaults *const indicatorPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.indicator"];
    isIndicatorEnabled = [indicatorPrefs objectForKey:@"isIndicatorEnabled"] ? [indicatorPrefs boolForKey:@"isIndicatorEnabled"] : YES;
}

static void prefsToastChanged() {
    NSUserDefaults *const toastPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.toast"];
    isToastEnabled = [toastPrefs objectForKey:@"isToastEnabled"] ? [toastPrefs boolForKey:@"isToastEnabled"] : YES;
}

%hook SBIconView
-(long long)currentLabelAccessoryType {
    if (tweakEnabled && isIndicatorEnabled) {
        BOOL isDocked = [self.location containsString:@"Dock"];
        
        if (isDocked) {
            NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
            if ([immortalBundleIDs containsObject:[self.icon applicationBundleID]]) {
                SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[self.icon applicationBundleID]];
                return app.processState ? 4 : 2;
            }
        }
        
        if ([self.icon isKindOfClass:[%c(SBFolderIcon) class]]) {
            SBFolder *folder = [(SBFolderIcon *)self.icon folder];
            NSArray *folderIcons = [folder icons];
            NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
            
            for (SBIcon *icon in folderIcons) {
                if ([immortalBundleIDs containsObject:[icon applicationBundleID]] && !isFolderTransitioning) {
                    SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[icon applicationBundleID]];
                    return app.processState ? 4 : 2;
                }
            }
        }
    }
    return %orig; 
}

-(NSArray *)applicationShortcutItems {
    NSArray *orig = %orig;
    if (tweakEnabled) {
        NSString *bundleID = [self.icon applicationBundleID];
          
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        BOOL isImmortal = [immortalBundleIDs containsObject:bundleID];
        
        SBSApplicationShortcutItem* immortalItem = [[%c(SBSApplicationShortcutItem) alloc] init];
        if (isImmortal) {
            immortalItem.localizedTitle = [NSString stringWithFormat:@"Disable Immortal Foreground"];
        } else {
            immortalItem.localizedTitle = [NSString stringWithFormat:@"Enable Immortal Foreground"];
        }
        immortalItem.type = @"com.sergy.immortalForeground.item";
        immortalItem.bundleIdentifierToLaunch = bundleID;
            
        return [orig arrayByAddingObject:immortalItem];
    } else 
        return orig;
}

+(void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(id)iconView {
    if (tweakEnabled && [[item type] isEqualToString:@"com.sergy.immortalForeground.item"]) {

        NSMutableArray *immortalBundleIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"] mutableCopy];
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        if (!immortalBundleIDs) {
            immortalBundleIDs = [NSMutableArray array];
        }

        if ([immortalBundleIDs containsObject:bundleID]) {
			SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
			if (app.processState != nil)
				[[%c(FBSSystemService) sharedService] openApplication:bundleID options:nil withResult:nil];
            if (isToastEnabled)
                [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:bundleID] subtitle:@"At rest" icon:[UIImage systemImageNamed:@"checkmark.circle.fill"] autoHide:3.0];
            
            [immortalBundleIDs removeObject:bundleID];
			
        } else { 
            if (isToastEnabled)
                [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:bundleID] subtitle:@"Immortalized" icon:[UIImage systemImageNamed:@"checkmark.circle.fill"] autoHide:3.0];
			[[%c(FBSSystemService) sharedService] openApplication:bundleID options:nil withResult:nil];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            	[immortalBundleIDs addObject:bundleID];
			 });
        }
        
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
        	[[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
        	[[NSUserDefaults standardUserDefaults] synchronize];
            [immortalizer updateAccessoryForBundle:bundleID];
		});
    } else
        %orig;
}
%end

%hook FBScene
-(void)updateSettings:(id)arg1 withTransitionContext:(id)arg2 completion:(id)arg3 {
    FBProcess *process = self.clientProcess;

    if (tweakEnabled && process) {
        NSString *bundleIdentifier = process.bundleIdentifier;
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        Immortalizer *immortalizer = [Immortalizer sharedInstance];

        if ([immortalBundleIDs containsObject:bundleIdentifier]) {
                [immortalizer updateAccessoryForBundle:bundleIdentifier];
            if (arg2 == nil) 
                return;
            else 
                [arg1 setValue:@YES forKey:@"foreground"];
        } 
    }
    %orig; 
}
%end

%hook SBApplication
-(long long)labelAccessoryTypeForIcon:(id)arg1 {
    if (tweakEnabled && isIndicatorEnabled) {
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        if ([immortalBundleIDs containsObject:self.bundleIdentifier] ) {
            SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleIdentifier];
            return app.processState ? 4 : 2;
        }
    }
    return %orig;
}

-(void)_didExitWithContext:(id)arg1 {
	%orig;
    if (tweakEnabled) {
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        [immortalizer updateAccessoryForBundle:self.bundleIdentifier];
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        BOOL isImmortal = [immortalBundleIDs containsObject:self.bundleIdentifier];
        if (isImmortal && isToastEnabled) {
            [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:self.bundleIdentifier] subtitle:@"Terminated" icon:[UIImage systemImageNamed:@"exclamationmark.triangle.fill"] autoHide:3.0];
        }
    }
}
%end

%hook SBFolderView
-(void)willTransitionAnimated:(BOOL)arg1 withSettings:(id)arg2 {
    isFolderTransitioning = true;
    %orig;
}

-(void)didTransitionAnimated:(BOOL)arg1 {
    isFolderTransitioning = false;
    [self.folder.icon _notifyAccessoriesDidUpdate];
    %orig;
}
%end

%hook UNSUserNotificationServer
-(void)willPresentNotification:(id)arg1 forBundleIdentifier:(id)arg2 withCompletionHandler:(id)arg3 {
    if (tweakEnabled) {
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        if ([immortalizer isNotificationEnabledForBundleIdentifier:arg2])
            [self _didChangeApplicationState:4 forBundleIdentifier:arg2];
    }
    %orig;
}
%end

%ctor {
    preferencesImmortalizerChanged();
    prefsNotifsChanged();
    prefsIndicatorChanged();
    prefsToastChanged();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesImmortalizerChanged, CFSTR("com.sergy.immortalizer.preferenceschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsNotifsChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.notifs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsIndicatorChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.indicator"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsToastChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.toast"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
