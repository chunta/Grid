//
//  CenterSettingVCtl.h
//  Grid
//
//  Created by Cindy on 2018/1/21.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol CenterWindowSettingDelegate
- (void)onCenterSettingBack;
@end

@interface CenterWindowSetting: NSViewController
@property(nonatomic, weak)id<CenterWindowSettingDelegate> delegate;
@end
