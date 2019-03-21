//
//  GridToggleWindow.h
//  Grid
//
//  Created by ChunTa Chen on 2017/5/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LaunchToggleWindow : NSWindowController
-(instancetype)initWithLaunchOn:(BOOL)launchOn Ref:(CFTypeRef)windowRef;
@end
