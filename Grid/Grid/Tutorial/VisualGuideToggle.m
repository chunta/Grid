//
//  VisualGuideToggle.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/25.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "VisualGuideToggle.h"
#import "GHelper.h"
@interface VisualGuideToggle ()
@property(nonatomic, strong)IBOutlet NSImageView* on2off;
@property(nonatomic, strong)IBOutlet NSImageView* off2on;
@end

@implementation VisualGuideToggle
-(instancetype)initWithOnOff:(BOOL)isOn Ref:(CFTypeRef)windowRef
{
    NSRect mrect = [GHelper getActiveScreenRectByRef:windowRef];
    int w = 400;
    int h = 120;
    mrect = NSMakeRect(mrect.origin.x + (mrect.size.width-w)/2, mrect.origin.y + (mrect.size.height-h)/2, w, h);
    
    self = [super initWithWindowNibName:@"VisualGuideToggle"];
    self.window.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    if (isOn)
    {
        self.off2on.hidden = NO;
        self.on2off.hidden = YES;
    }
    else
    {
        self.off2on.hidden = YES;
        self.on2off.hidden = NO;
    }
    [self.window setFrame:mrect display:YES];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

@end
