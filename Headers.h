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
-(void)_processWillLaunch:(id)arg1 ;
-(void)_processDidLaunch:(id)arg1 ;
-(void)_setInternalProcessState:(id)arg1 ;
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
@end

@interface  LabelImageParameters : SBIconLabelImageParameters
@end

@interface SBIconLegibilityLabelView : NSObject
@property (nonatomic,retain) SBIconLabelImageParameters * imageParameters;  
@end

@interface SBMutableIconLabelImageParameters : SBIconLabelImageParameters
@property (copy, readwrite, nonatomic) NSString *text;
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* localizedTitle;
@property (nonatomic, copy) NSString* localizedSubtitle;
@property (nonatomic, copy) NSDictionary* userInfo;
@property (assign, nonatomic) NSUInteger activationMode;
@property (nonatomic, copy) NSString* bundleIdentifierToLaunch;
@end

@interface FBProcess : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier; 
@end

@interface FBScene : NSObject 
@property (nonatomic,readonly) FBProcess * clientProcess;   
@property (nonatomic,copy,readonly) NSString * identifier;
@end

@interface FBSSystemService : NSObject
+(id)sharedService;
-(void)openApplication:(id)arg1 options:(id)arg2 withResult:(id)arg3 ;
@end

@interface UNSUserNotificationServer : NSObject
+(id)sharedInstance;
-(void)_didChangeApplicationState:(unsigned)arg1 forBundleIdentifier:(id)arg2;
@end

