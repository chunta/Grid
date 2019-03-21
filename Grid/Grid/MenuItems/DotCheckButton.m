//
//  CheckButton.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/17.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "DotCheckButton.h"

@implementation DotCheckButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    if (self.checked)
    {
        NSColor* dotColr = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [dotColr setFill];
        
        int wh = 10;
        NSRect rect = NSMakeRect(dirtyRect.origin.x + dirtyRect.size.width/2 - wh/2,
                                 dirtyRect.origin.y + dirtyRect.size.height/2 - wh/2, wh, wh);
        NSBezierPath* circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithOvalInRect: rect];
        [circlePath fill];
    }
}

@end
