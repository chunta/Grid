//
//  EULAWindow.h
//  Grid
//
//  Created by Chen Rex on 17/10/2017.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define AGREE_EULA @"AGREE_EULA"
@protocol EULAWindowDelegate
- (void)eulawindowClose;
@end

@interface EULAWindow : NSWindowController
@property(weak)id<EULAWindowDelegate> delegate;
@end
