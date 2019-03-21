//
//  ValidateInputTxtField.m
//  Grid
//
//  Created by nmi on 2017/6/7.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "ValidateInputTxtField.h"
#import "ValidateInputTxtCell.h"
@implementation ValidateInputTxtField

+(Class)cellClass
{
    return [ValidateInputTxtCell class];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSPoint origin = { 0.0,0.0 };
    NSRect rect;
    rect.origin = origin;
    rect.size.width  = [self bounds].size.width;
    rect.size.height = [self bounds].size.height;
    
    NSGradient *gd = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor whiteColor]];
    if (([[self window] firstResponder] == [self currentEditor]) && [NSApp isActive])
    {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [gd drawInRect:rect angle:0];
        [NSGraphicsContext restoreGraphicsState];
    }
    else
    {
        [super drawRect:dirtyRect];
    }
}

@end
