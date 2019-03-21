//
//  GridToggleWindow.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "LaunchToggleWindow.h"
#import "GHelper.h"
@interface LaunchToggleWindow ()
@property(nonatomic, strong)IBOutlet NSImageView* lhon2off;
@property(nonatomic, strong)IBOutlet NSImageView* lhoff2on;
@end

@implementation LaunchToggleWindow
-(instancetype)initWithLaunchOn:(BOOL)launchOn Ref:(CFTypeRef)windowRef
{
    NSRect mrect = [GHelper getActiveScreenRectByRef:windowRef];
    int w = 400;
    int h = 120;
    mrect = NSMakeRect(mrect.origin.x + (mrect.size.width-w)/2, mrect.origin.y + (mrect.size.height-h)/2, w, h);
    self = [super initWithWindowNibName:@"LaunchToggleWindow"];
    self.window.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    if (launchOn)
    {
        self.lhoff2on.hidden = NO;
        self.lhon2off.hidden = YES;
    }
    else
    {
        self.lhoff2on.hidden = YES;
        self.lhon2off.hidden = NO;
    }
    [self.window setFrame:mrect display:YES];
    
    return self;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
