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

@interface SBApplicationProcessState 
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) SBApplicationProcessState * processState; 
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;  
@property (nonatomic,copy,readonly) NSString * displayName; 
@end

@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1 ;
@end

@interface SBIconLabelImageParameters : NSObject
@property (nonatomic,copy,readonly) NSString * text; 
@end

@interface SBIconLabelView
@property (nonatomic,readonly) SBIconLabelImageParameters * imageParameters; 
-(void)updateIconLabelWithSettings:(id)arg1 imageParameters:(id)arg2;
@end

@interface SBIcon : NSObject
@property (nonatomic,copy,readonly) NSString * displayName; 
-(id)applicationBundleID;
-(void)_notifyAccessoriesDidUpdate;
-(void)_notifyImageDidUpdate;
@end

@interface SBIconModel : NSObject
-(id)applicationIconForBundleIdentifier:(id)arg1 ;
@end

@interface SBIconController : NSObject
@property (nonatomic,retain) SBIconModel * model;
@end

@class SBFolder, SBFolderIcon;
@interface SBFolderIcon : SBIcon
@property (nonatomic,readonly) SBFolder * folder;   
@end

@interface SBFolder : NSObject
@property (nonatomic,copy,readonly) NSArray * icons; 
@property (assign,nonatomic) SBFolderIcon * icon;
@end

@interface SBFolderView : UIView
@property (nonatomic,retain) SBFolder * folder;   
@end

@interface SBIconView : UIView
@property (nonatomic,readonly) SBIconLabelView *labelView;
@property (nonatomic,copy) NSString * location;
@property (nonatomic,retain) SBIcon * icon; 
@property (nonatomic,retain) SBFolderIcon * folderIcon;  
- (NSString*)applicationBundleIdentifier; //only on 14
- (NSString*)applicationBundleIdentifierForShortcuts;
-(void)_updateLabelAccessoryView;
@property (nonatomic,readonly) CGRect frame; 
@end

@interface  LabelImageParameters : SBIconLabelImageParameters
@end

@interface SBIconLegibilityLabelView : NSObject
@property (nonatomic,retain) SBIconLabelImageParameters * imageParameters;  
@end

@interface SBMutableIconLabelImageParameters : SBIconLabelImageParameters
@property (copy, readwrite, nonatomic) NSString *text;
@end

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBSApplicationShortcutCustomImageIcon : SBSApplicationShortcutIcon
- (id)initWithImageData:(id)arg1 dataType:(long long)arg2 isTemplate:(bool)arg3;
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* localizedTitle;
@property (nonatomic, copy) NSString* localizedSubtitle;
@property (nonatomic, copy) NSDictionary* userInfo;
@property (assign, nonatomic) NSUInteger activationMode;
@property (nonatomic, copy) NSString* bundleIdentifierToLaunch;
@property (nonatomic,copy) SBSApplicationShortcutIcon *icon;
@end

@interface RBSProcessIdentity : NSObject
@property (nonatomic,copy,readonly) NSString * embeddedApplicationIdentifier; 
@end

@class FBSSceneParameters, UIMutableApplicationSceneSettings;

@interface FBProcess : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier; 
@property (nonatomic,readonly) RBSProcessIdentity * identity; 
@end

@interface BSSettings : NSObject
-(void)_applyToSettings:(id)arg1;
-(void)_removeAllSettings;
@end

@interface FBSSceneSettings : NSObject {
    BSSettings* _otherSettings;
}

@property (getter=isBackgrounded,nonatomic,readonly) BOOL backgrounded; 
@property (getter=isForeground,nonatomic,readonly) BOOL foreground; 

@end

@interface FBSceneWorkspace : NSObject {
    NSMutableDictionary* _allScenesByID;
}
@end

@interface FBSceneManager : NSObject {
	FBSceneWorkspace* _workspace;
}
+(id)sharedInstance;
+(id)keyboardScene;
+(void)_clearKeyboardScene;
+(void)setKeyboardScene:(id)arg1 ;
@end

@interface FBSSceneSpecification : NSObject
+ (instancetype)specification;
@end

@interface FBSSceneParameters : NSObject
@property(nonatomic, copy) UIMutableApplicationSceneSettings *settings;
+ (instancetype)parametersForSpecification:(FBSSceneSpecification *)spec;
@end

@interface FBSSceneDefinition : NSObject
@property (nonatomic,copy) FBSSceneSpecification * specification;   
@end

@interface FBSSceneClientSettings : NSObject
@end

@interface FBSceneClientHandle : NSObject
@end

@interface FBScene : NSObject 
@property (nonatomic,readonly) FBProcess * clientProcess;   
@end

@interface FBSSystemService : NSObject
+(id)sharedService;
-(void)openApplication:(id)arg1 options:(id)arg2 withResult:(id)arg3 ;
@end

@interface UNSUserNotificationServer : NSObject
+(id)sharedInstance;
-(void)_didChangeApplicationState:(unsigned)arg1 forBundleIdentifier:(id)arg2;
@end

@interface SpringBoard : UIApplication
-(id)_accessibilityFrontMostApplication;
@end

@interface SBAppLayout : NSObject {
    NSDictionary* _rolesToLayoutItemsMap; //iOS 15 below
}
@property (nonatomic,readonly) NSDictionary * itemsToLayoutAttributesMap; 
@end

@interface SBFluidSwitcherItemContainer
@property (nonatomic,retain) SBAppLayout * appLayout; 
-(void)setKillable:(BOOL)arg1;
@end

@interface SBDisplayItem : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier; 
@end

@interface UIApplication ()
-(void)openURL:(id)arg1 withCompletionHandler:(id)arg2 ;
-(BOOL)_openURL:(id)arg1 ;
@end