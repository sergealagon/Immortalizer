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

#import "ImmortalizerCC.h"
#import "ImmortalizerCCMenu.h"

@implementation ImmortalizerCC {
    BOOL _selected;
    ImmortalizerCCUIMenuModuleViewController *_contentViewController;
}

-(instancetype)init{
	if ((self = [super init])) {
		_contentViewController = [[ImmortalizerCCUIMenuModuleViewController alloc] init];
        _contentViewController.module = self;
	}
	return self;
}

-(UIViewController*)contentViewController{
	return _contentViewController;
}

- (UIImage *)iconGlyph {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:UIImageSymbolWeightRegular];
    return [[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] imageByApplyingSymbolConfiguration:config];
}

- (UIImage *)selectedIconGlyph {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:UIImageSymbolWeightRegular];
    return [[UIImage systemImageNamed:@"hourglass.tophalf.fill"] imageByApplyingSymbolConfiguration:config];
}

- (UIColor *)selectedColor {
    return [UIColor blueColor];
}

- (BOOL)isSelected {
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [super refreshState];
}
@end