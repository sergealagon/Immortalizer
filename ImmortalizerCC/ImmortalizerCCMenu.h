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

#if defined __cplusplus
extern "C" {
#endif
CGFloat CCUISliderExpandedContentModuleHeight();
CGFloat CCUISliderExpandedContentModuleWidth();
CGFloat CCUIExpandedModuleContinuousCornerRadius();
CGFloat CCUICompactModuleContinuousCornerRadius();
CGFloat CCUIDefaultExpandedContentModuleWidth();
CGFloat CCUIMaximumExpandedContentModuleHeight();
#if defined __cplusplus
};
#endif

#import <notify.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import "Headers.h"
#import "../Immortalizer.h"
#import "ImmortalizerCC.h"


@interface ImmortalizerCCUIMenuModuleViewController : CCUIMenuModuleViewController
@property (nonatomic, weak) ImmortalizerCC* module;
@end
