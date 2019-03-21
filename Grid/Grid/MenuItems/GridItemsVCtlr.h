//
//  ColorPickerItemVCtlr.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/14.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol GridItemsVCtlrDelegate
- (void)gridmenuSettingChange;
- (void)toGrid:(NSString*)type;
- (void)toVisual:(BOOL)isOn;
- (void)toLaunchStart:(BOOL)isOn;
- (void)toGridSetting;
- (void)toModifierSetting;
- (void)toCenterSetting;
- (void)toEULA;
@end
@interface GridItemsVCtlr : NSViewController
@property(nonatomic, weak) id<GridItemsVCtlrDelegate> delegate;
@end
