//
//  PreferModifierSetting.h
//  Grid
//
//  Created by ChunTa Chen on 2017/7/25.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol PreferModifierSettingDelegate
- (void)onModifierSettingBack;
@end

@interface PreferModifierSetting : NSViewController
@property(nonatomic, weak)id<PreferModifierSettingDelegate> delegate;
@end
