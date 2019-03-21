//
//  GridToggleWindow.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridToggleWindow.h"
#import "GHelper.h"
@interface GridToggleWindow ()
@property(nonatomic, strong)IBOutlet NSImageView* grid2to3;
@property(nonatomic, strong)IBOutlet NSImageView* grid3to2;
@end

@implementation GridToggleWindow
-(instancetype)initWithGridType:(int)aType Ref:(CFTypeRef)windowRef
{
    NSRect mrect = [GHelper getActiveScreenRectByRef:windowRef];
    int w = 400;
    int h = 120;
    mrect = NSMakeRect(mrect.origin.x + (mrect.size.width-w)/2, mrect.origin.y + (mrect.size.height-h)/2, w, h);
    self = [super initWithWindowNibName:@"GridToggleWindow"];
    self.window.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    if (aType==3)
    {
        self.grid2to3.hidden = NO;
        self.grid3to2.hidden = YES;
    }
    else
    {
        self.grid3to2.hidden = NO;
        self.grid2to3.hidden = YES;
    }
    [self.window setFrame:mrect display:YES];
    
    return self;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
