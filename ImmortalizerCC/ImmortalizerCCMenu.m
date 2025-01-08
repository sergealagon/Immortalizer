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

#import "ImmortalizerCCMenu.h"
#import "Localizer.h"

@implementation ImmortalizerCCUIMenuModuleViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    int token3;
    notify_register_dispatch("com.sergy.immortalizer.updatecc", &token3, dispatch_get_main_queue(), ^(int token3) {
        SBApplication *frontMostApp = [(SpringBoard *)UIApplication.sharedApplication _accessibilityFrontMostApplication];
        NSUserDefaults *const prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
        BOOL immortalizerStatus = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
        if (frontMostApp && immortalizerStatus) {
            NSArray *immortalBundleIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"]; 
            if ([immortalBundleIDs containsObject:frontMostApp.bundleIdentifier]) {
                [self setSelected:YES];
            } else {
                [self setSelected:NO];
            }
        } else
            [self setSelected:NO];
    });

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:UIImageSymbolWeightRegular];
	self.glyphImage = [[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] imageByApplyingSymbolConfiguration:config];
	self.selectedGlyphImage = [[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] imageByApplyingSymbolConfiguration:config];
	self.selectedGlyphColor = [UIColor blueColor];
    self.title = @"Immortalizer";
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (CGFloat)preferredExpandedContentWidth{
	return CCUIDefaultExpandedContentModuleWidth();
}
- (void)buttonTapped:(id)arg1 forEvent:(UIEvent *)event{ 
    Immortalizer *immortalizer = [objc_getClass("Immortalizer") sharedInstance];
    SBApplication *frontMostApp = [(SpringBoard *)UIApplication.sharedApplication _accessibilityFrontMostApplication];
    NSUserDefaults *const prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    BOOL immortalizerStatus = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
    BOOL isToastEnabled = [prefs objectForKey:@"isToastEnabled"] ? [prefs boolForKey:@"isToastEnabled"] : YES;
    if (immortalizerStatus) {
        if (frontMostApp) {
            NSMutableArray *immortalBundleIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"] mutableCopy];
            if (!immortalBundleIDs) immortalBundleIDs = [NSMutableArray array];
            BOOL isFrontAppImmortalized = [immortalBundleIDs containsObject:frontMostApp.bundleIdentifier];
            if (isFrontAppImmortalized) {
                [immortalBundleIDs removeObject:frontMostApp.bundleIdentifier];
                if (isToastEnabled)
                    [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"AT_REST") icon:[UIImage systemImageNamed:@"arrow.uturn.left.circle.fill"] autoHide:3.0];
                [[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier];
                [self setSelected:NO];
            } else {
                [immortalBundleIDs addObject:frontMostApp.bundleIdentifier];
                if (isToastEnabled)
                    [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"IMMORTALIZED") icon:[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] autoHide:3.0];
                [[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier];
                [self setSelected:YES];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Immortalizer"
                                                                                        message:localizer(@"IMMORTALIZER_CC_TOGGLE_FOOTER")
                                                                                preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:localizer(@"OOOPS")
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
    } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Immortalizer"
                                                                                        message:localizer(@"IMMORTALIZER_CC_ON_FOOTER")
                                                                                preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:localizer(@"OKAY")
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
}

- (BOOL)_canShowWhileLocked{
	return YES;
}

- (void)populateActions {
    Immortalizer *immortalizer = [objc_getClass("Immortalizer") sharedInstance];
    NSMutableArray *immortalBundleIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ImmortalForegroundBundleIDs"] mutableCopy];
    if (!immortalBundleIDs) immortalBundleIDs = [NSMutableArray array];
    SBApplication *frontMostApp = [(SpringBoard *)UIApplication.sharedApplication _accessibilityFrontMostApplication];
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergy.immortalizer.prefs"];
    NSMutableArray *lockedBundleIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"LockedBundleIDs"] mutableCopy];
    if (!lockedBundleIDs) lockedBundleIDs = [NSMutableArray array];
    __block BOOL isToastEnabled = [prefs objectForKey:@"isToastEnabled"] ? [prefs boolForKey:@"isToastEnabled"] : YES;
    __block BOOL immortalizerStatus = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
    __block BOOL isFrontAppImmortalized = [immortalBundleIDs containsObject:frontMostApp.bundleIdentifier];
    __block BOOL isFrontAppLocked = [lockedBundleIDs containsObject:frontMostApp.bundleIdentifier];
    __block BOOL isFrontAppNotifEnabled = [immortalizer isNotificationEnabledForBundleIdentifier:frontMostApp.bundleIdentifier];
    __weak typeof(self) weakSelf = self;

    if (frontMostApp && immortalizerStatus) {
        [self addActionWithTitle:(isFrontAppImmortalized ? localizer(@"DISABLE_IMMORTAL_FOREGROUND") : localizer(@"ENABLE_IMMORTAL_FOREGROUND")) subtitle:[NSString stringWithFormat:(localizer(@"FOR_APPS")),  frontMostApp.displayName] glyph:[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] handler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isFrontAppImmortalized) {
                    [immortalBundleIDs removeObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"AT_REST") icon:[UIImage systemImageNamed:@"arrow.uturn.left.circle.fill"] autoHide:3.0];
                    [[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier]; 
                    [weakSelf setSelected:NO];
                } else {
                    [immortalBundleIDs addObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"IMMORTALIZED") icon:[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] autoHide:3.0];
                    [[NSUserDefaults standardUserDefaults] setObject:immortalBundleIDs forKey:@"ImmortalForegroundBundleIDs"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier];
                    [weakSelf setSelected:YES];
                }
            });
        }];

        [self addActionWithTitle:[NSString stringWithFormat:(isFrontAppLocked ? localizer(@"UNLOCK") : localizer(@"LOCK")), frontMostApp.displayName] subtitle:(isFrontAppLocked ? localizer(@"SWITCHER_CLOSE_FOOTER")  : localizer(@"SWITCHER_LOCK_FOOTER") ) glyph:[UIImage systemImageNamed:(isFrontAppLocked ? @"lock.open.fill" : @"lock.fill")] handler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isFrontAppLocked) {
                    [lockedBundleIDs removeObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"RELEASED")  icon:[UIImage systemImageNamed:@"lock.open.fill"] autoHide:3.0];
                    [[NSUserDefaults standardUserDefaults] setObject:lockedBundleIDs forKey:@"LockedBundleIDs"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier]; 
                } else {
                    [lockedBundleIDs addObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"JAILEDE")  icon:[UIImage systemImageNamed:@"lock.fill"] autoHide:3.0];
                    [[NSUserDefaults standardUserDefaults] setObject:lockedBundleIDs forKey:@"LockedBundleIDs"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [immortalizer updateAccessoryForBundle:frontMostApp.bundleIdentifier]; 
                }
            });
        }];
        
        [self addActionWithTitle:[NSString stringWithFormat:(isFrontAppNotifEnabled ? localizer(@"DISABLE_NOTIFICATION") : localizer(@"ENABLE_NOTIFICATION")), frontMostApp.displayName] subtitle:(isFrontAppNotifEnabled ? localizer(@"DISABLE_NOTIFICATION_FOOTER") : localizer(@"ENABLE_NOTIFICATION_FOOTER")) glyph:[UIImage systemImageNamed:(isFrontAppNotifEnabled ? @"bell.slash.fill" : @"bell.fill")] handler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *enabledAppNotifsList = [[immortalizer getNotificationEnabledApps] mutableCopy];
                if (!enabledAppNotifsList) enabledAppNotifsList = [NSMutableArray array];
                if (isFrontAppNotifEnabled) {
                    [enabledAppNotifsList removeObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"DISABLE") icon:[UIImage systemImageNamed:@"bell.slash.fill"] autoHide:3.0];
                    [prefs setObject:enabledAppNotifsList forKey:@"selectedApplications"];
                    [prefs synchronize];
                        notify_post("com.sergy.immortalizer.preferenceschanged.notifs");
                } else {
                    [enabledAppNotifsList addObject:frontMostApp.bundleIdentifier];
                    if (isToastEnabled)
                        [immortalizer showToastWithTitle:frontMostApp.displayName subtitle:localizer(@"ENABLE") icon:[UIImage systemImageNamed:@"bell.fill"] autoHide:3.0];
                    [prefs setObject:enabledAppNotifsList forKey:@"selectedApplications"];
                    [prefs synchronize];
                    notify_post("com.sergy.immortalizer.preferenceschanged.notifs");
                }
            });
        }];   
    }

    if (immortalizerStatus && !frontMostApp)
        [self addActionWithTitle:localizer(@"NO_APP_OPEN")  subtitle:localizer(@"OPEN_APP_IMMORTALIZE")  glyph:[UIImage systemImageNamed:@"questionmark.circle.fill"] handler:^{}];

    [self addActionWithTitle:(immortalizerStatus ? localizer(@"DISABLE_TWEAK")  : localizer(@"ENABLE_TWEAK") ) subtitle:(immortalizerStatus ? localizer(@"DISABLE_FOOTER")  : localizer(@"ENABLE_FOOTER"))  glyph:[UIImage systemImageNamed:@"hammer.fill"] handler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL newStatus = !immortalizerStatus;
            [prefs setBool:newStatus forKey:@"isEnabled"];
            [prefs synchronize];
            notify_post("com.sergy.immortalizer.preferenceschanged");
        });

    }];
    [self addActionWithTitle:localizer(@"IMMORTALIZER_SETTINGS")  subtitle:localizer(@"IMMORTALIZER_SETTINGS_FOOTER") glyph:[UIImage systemImageNamed:@"gear"] handler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:@"prefs:root=Immortalizer"];
            [[UIApplication sharedApplication] _openURL:url];
        });
    }];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	[coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext>context)
	{
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	} completion:nil];
}

-(BOOL)shouldBeginTransitionToExpandedContentModule{
    [self populateActions];
    return true;
}
@end
