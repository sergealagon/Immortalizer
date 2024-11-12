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

static BOOL immortalizerEnabled;
static BOOL isFolderTransitioning = false;
static BOOL isIndicatorEnabled;
static BOOL isToastEnabled;
static BOOL isLockIndicatorEnabled;

%hook SpringBoard
- (void)frontDisplayDidChange:(id)arg1 {
    %orig;
    notify_post("com.sergy.immortalizer.updatecc");
}
%end

%hook SBIconView
-(long long)currentLabelAccessoryType {
    long long accessory = %orig;
    if (immortalizerEnabled && isIndicatorEnabled) {
        BOOL isDocked = [self.location containsString:@"Dock"];
        
        if (isDocked) {
            NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
            if ([immortalBundleIDs containsObject:[self.icon applicationBundleID]]) {
                SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[self.icon applicationBundleID]];
                accessory = app.processState ? 4 : 2;
            }
        }
        
        if ([self.icon isKindOfClass:[%c(SBFolderIcon) class]]) {
            SBFolder *folder = [(SBFolderIcon *)self.icon folder];
            NSArray *folderIcons = [folder icons];
            NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
            
            for (SBIcon *icon in folderIcons) {
                if ([immortalBundleIDs containsObject:[icon applicationBundleID]] && !isFolderTransitioning) {
                    SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[icon applicationBundleID]];
                    accessory = app.processState ? 4 : 2;
                }
            }
        }
    }
    return accessory; 
}

-(NSArray *)applicationShortcutItems { 
    NSArray *orig = %orig;
    if (immortalizerEnabled) {
        NSString *bundleID = [self.icon applicationBundleID];
        
        if (!bundleID) return orig;
        
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        BOOL isImmortal = [immortalBundleIDs containsObject:bundleID];
        
        SBSApplicationShortcutItem* immortalItem = [[%c(SBSApplicationShortcutItem) alloc] init];
        if (isImmortal) {
            immortalItem.localizedTitle = [NSString stringWithFormat:@"Disable Immortal Foreground"];
        } else {
            immortalItem.localizedTitle = [NSString stringWithFormat:@"Enable Immortal Foreground"];
        }
        immortalItem.type = @"com.sergy.immortalizer.immortalForeground.item";
        UIImage *iconImage = [UIImage systemImageNamed:@"hourglass.bottomhalf.fill"];
        immortalItem.icon = [[%c(SBSApplicationShortcutCustomImageIcon) alloc] initWithImageData:UIImagePNGRepresentation(iconImage) dataType:0 isTemplate:1];
        
        immortalItem.bundleIdentifierToLaunch = bundleID;
            
        return [orig arrayByAddingObject:immortalItem];
    } else 
        return orig;
}

+(void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(id)iconView {
    if (immortalizerEnabled && [[item type] isEqualToString:@"com.sergy.immortalizer.immortalForeground.item"]) {
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        NSMutableArray *immortalBundleIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"] mutableCopy];
        if (!immortalBundleIDs) immortalBundleIDs = [NSMutableArray array];
   
        if ([bundleID isEqualToString:@"com.apple.camera"] && ![immortalBundleIDs containsObject:bundleID]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Immortalizer"
                                                                                        message:@"You pervert! Kidding. But Immortalizer doesn't work for camera for recording. I don't know why, but if I got time, I'll try to investigate. I'll still let you Immortalize this app anyway."
                                                                                preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:@"Lmao"
                                                                    style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                }]];
                
                    UIWindow *keyWindow = nil;
                    for (UIWindow *window in UIApplication.sharedApplication.windows) {
                        if (window.isKeyWindow) {
                            keyWindow = window;
                            break;
                        }
                    }
                    if (!keyWindow) keyWindow = UIApplication.sharedApplication.windows.firstObject;
                    UIViewController *rootViewController = keyWindow.rootViewController;
                    [rootViewController presentViewController:alertController animated:YES completion:nil];
            });
        }

        if ([immortalBundleIDs containsObject:bundleID]) {
			SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
			if (app.processState != nil) [[%c(FBSSystemService) sharedService] openApplication:bundleID options:nil withResult:nil];
            if (isToastEnabled) [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:bundleID] subtitle:@"At rest" icon:[UIImage systemImageNamed:@"arrow.uturn.left.circle.fill"] autoHide:3.0];
            [immortalBundleIDs removeObject:bundleID];
			
        } else { 
            if (isToastEnabled) [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:bundleID] subtitle:@"Immortalized" icon:[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] autoHide:3.0];
			[[%c(FBSSystemService) sharedService] openApplication:bundleID options:nil withResult:nil];
            [immortalBundleIDs addObject:bundleID];
        }
        	[[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
        	[[NSUserDefaults standardUserDefaults] synchronize];
            [immortalizer updateAccessoryForBundle:bundleID];
    } else {
        %orig;
    }
}
%end


%hook FBScene
-(void)updateSettings:(id)arg1 withTransitionContext:(id)arg2 completion:(id)arg3{
    FBProcess *process = self.clientProcess;   
    if (immortalizerEnabled && process) {
        NSString *bundleIdentifier = process.bundleIdentifier;
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"]; 
          
        if ([immortalBundleIDs containsObject:bundleIdentifier] && arg2 == nil) { 
            Immortalizer *immortalizer = [Immortalizer sharedInstance];
            [immortalizer updateAccessoryForBundle:bundleIdentifier];
            return;
        } 
    }
    %orig; 
}
%end

%hook SBApplication
-(long long)labelAccessoryTypeForIcon:(id)arg1 {
    long long accessory = %orig;
    if (immortalizerEnabled && isIndicatorEnabled) {
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        if ([immortalBundleIDs containsObject:self.bundleIdentifier]) {
            SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleIdentifier];
            accessory = app.processState ? 4 : 2;
        }
    }
    return accessory;
}

-(NSString *)displayName {
    NSString *originalName = %orig;
    NSString *bundleID = self.bundleIdentifier;
    NSArray *lockedBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"LockedBundleIDs"]; 

    NSString *status = @"";
    if (immortalizerEnabled && lockedBundleIDs && [lockedBundleIDs containsObject:bundleID] && isLockIndicatorEnabled) status = @"🔒";
    
    return [NSString stringWithFormat:@"%@%@", originalName, status];
}

-(void)_didExitWithContext:(id)arg1 {
	%orig;
    if (immortalizerEnabled) {
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        [immortalizer updateAccessoryForBundle:self.bundleIdentifier];
        NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
        BOOL isImmortalized = [immortalBundleIDs containsObject:self.bundleIdentifier];
        if (isImmortalized && isToastEnabled) {
            [immortalizer showToastWithTitle:[immortalizer getAppNameForBundle:self.bundleIdentifier] subtitle:@"Terminated" icon:[UIImage systemImageNamed:@"exclamationmark.triangle.fill"] autoHide:3.0];
        }
    }
}

%end

%hook SBFolderView
-(void)willTransitionAnimated:(BOOL)arg1 withSettings:(id)arg2 {
    if (immortalizerEnabled && isIndicatorEnabled) isFolderTransitioning = true;
    %orig;
}

-(void)didTransitionAnimated:(BOOL)arg1 {
    if (immortalizerEnabled && isIndicatorEnabled) {
        isFolderTransitioning = false;
        [self.folder.icon _notifyAccessoriesDidUpdate];
    }
    %orig;
}
%end

%hook UNSUserNotificationServer
-(void)willPresentNotification:(id)arg1 forBundleIdentifier:(id)arg2 withCompletionHandler:(id)arg3 {
    if (immortalizerEnabled) {
        Immortalizer *immortalizer = [Immortalizer sharedInstance];
        if ([immortalizer isNotificationEnabledForBundleIdentifier:arg2]) {
            [self _didChangeApplicationState:4 forBundleIdentifier:arg2];
        }
    }
    %orig;
}
%end

%hook UIMutableApplicationSceneSettings
-(void)setDeactivationReasons:(unsigned long long)arg1 {
    if (arg1 != 0)
        return;
    %orig;
}

%end

%hook SBFluidSwitcherItemContainer
-(void)setKillable:(BOOL)arg1 {
    BOOL shouldTerminate = arg1;

    if (immortalizerEnabled) {
        SBAppLayout *appLayout = [self appLayout];
        NSDictionary *bundles = nil;
        NSArray *lockedBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"LockedBundleIDs"]; 

        if (@available(iOS 16.0, *)) bundles = [appLayout itemsToLayoutAttributesMap];
        else bundles = (NSDictionary *)object_getIvar(appLayout, class_getInstanceVariable([%c(SBAppLayout) class], "_rolesToLayoutItemsMap"));

        if (bundles) {
            if (@available(iOS 16.0, *)) {
                for (SBDisplayItem *displayItem in bundles) {
                    NSString *bundleIdentifier = [displayItem bundleIdentifier];
                    if ([lockedBundleIDs containsObject:bundleIdentifier]) shouldTerminate = false;
                }
            } 
            else {
                SBDisplayItem *displayItem = bundles[@1];
                NSString *bundleIdentifier = nil;
                if ([displayItem respondsToSelector:@selector(bundleIdentifier)])
                    bundleIdentifier = [displayItem bundleIdentifier];
                if (bundleIdentifier && [lockedBundleIDs containsObject:bundleIdentifier]) {
                    shouldTerminate = false;
                }
            }
        }
    }

    %orig(shouldTerminate);
}
%end

static void prefsLockIndicatorChanged() {
    Immortalizer *immortalizer = [Immortalizer sharedInstance];
    NSArray *lockedBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"LockedBundleIDs"]; 
    NSUserDefaults *const prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    isLockIndicatorEnabled = [prefs objectForKey:@"isLockIndicatorEnabled"] ? [prefs boolForKey:@"isLockIndicatorEnabled"] : YES;
    for (NSString *bundleIdentifier in lockedBundleIDs)
        [immortalizer updateAccessoryForBundle:bundleIdentifier];
}

static void immortalizerPreferencesChanged() {
    Immortalizer *immortalizer = [Immortalizer sharedInstance];
    NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"];
    NSUserDefaults *const prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    immortalizerEnabled = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
        for (NSString *bundleIdentifier in immortalBundleIDs) 
            [immortalizer updateAccessoryForBundle:bundleIdentifier];
    notify_post("com.sergy.immortalizer.updatecc");
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
    NSUserDefaults *const indicatorPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    isIndicatorEnabled = [indicatorPrefs objectForKey:@"isIndicatorEnabled"] ? [indicatorPrefs boolForKey:@"isIndicatorEnabled"] : YES;
}

static void prefsToastChanged() {
    NSUserDefaults *const toastPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    isToastEnabled = [toastPrefs objectForKey:@"isToastEnabled"] ? [toastPrefs boolForKey:@"isToastEnabled"] : YES;
}

static void loadAllImmortalizerPrefs() {
    immortalizerPreferencesChanged();
    prefsNotifsChanged();
    prefsIndicatorChanged();
    prefsToastChanged();
    prefsLockIndicatorChanged();
}

%ctor {
    loadAllImmortalizerPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)immortalizerPreferencesChanged, CFSTR("com.sergy.immortalizer.preferenceschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsNotifsChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.notifs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsIndicatorChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.indicator"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsToastChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.toast"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsLockIndicatorChanged, CFSTR("com.sergy.immortalizer.preferenceschanged.lockindicator"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}