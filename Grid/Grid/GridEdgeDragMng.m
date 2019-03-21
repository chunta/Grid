//
//  GridEdgeDragMng.m
//  Grid
//
//  Created by Cindy on 2017/12/28.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridEdgeDragMng.h"
@interface GridEdgeDragMng()
{
    KeyLogger* ilogger;
}
@end

@implementation GridEdgeDragMng
- (instancetype)initWithKeyLogger:(KeyLogger*)logger
{
    self = [super init];
    ilogger = logger;
    return self;
}

- (void)start
{
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseDragged handler:^(NSEvent *event) {

        if ([ilogger isModifierPressed])
        {
            CGPoint location = [NSEvent mouseLocation];
            NSLog(@"MousePosition: %@", NSStringFromPoint(location));
        }
    }];
}

@end
