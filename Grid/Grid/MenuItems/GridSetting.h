//
//  GridSetting.h
//  Grid
//
//  Created by Cindy on 2018/1/23.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol GridSettingDelegate
- (void)onGridSettingBack;
@end
@interface GridSetting : NSViewController<NSTextFieldDelegate>
@property(nonatomic, weak) id<GridSettingDelegate> delegate;
@end
