//
//  VisualGuideToggle.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/25.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VisualGuideToggle : NSWindowController
-(instancetype)initWithOnOff:(BOOL)isOn Ref:(CFTypeRef)windowRef;
@end
