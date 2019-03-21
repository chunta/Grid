//
//  CheckButton.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/24.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "CheckButton.h"

@implementation CheckButton

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    if (1)
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
