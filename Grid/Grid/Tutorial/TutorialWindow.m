//
//  TutorialWindow.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/14.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "TutorialWindow.h"

@interface TutorialWindow ()
@property(nonatomic, strong)IBOutlet NSScrollView *sclview;
@property(nonatomic, strong)IBOutlet NSButton *upbtn;
@property(nonatomic, strong)IBOutlet NSButton *dnbtn;
@property(nonatomic, assign)int startY;
@end

@implementation TutorialWindow
- (id)init
{
    self = [super initWithWindowNibName:@"TutorialWindow"];
    self.window.backgroundColor = [NSColor whiteColor];
    
    //Frame
    int w = 1000;
    int h = 566;
    NSRect mrect = [NSScreen mainScreen].visibleFrame;
    [self.window setFrame:NSMakeRect((mrect.size.width-w)/2, mrect.size.height-h, w, h) display:YES];
    
    //Grid 3x3
    NSImageView *imgview3x3 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 1000, 563)];
    imgview3x3.image = [NSImage imageNamed:@"3x3GridDetail_1000.png"];
    [self.sclview.documentView addSubview:imgview3x3];
    
    //----
    NSView *horizontalSeparator = [[NSView alloc] initWithFrame:NSMakeRect(25, 563, 1000-50, 1)];
    [horizontalSeparator setWantsLayer:YES];
    [horizontalSeparator.layer setBackgroundColor:[NSColor whiteColor].CGColor];
    [self.sclview.documentView addSubview:horizontalSeparator];
    
    //Grid 2x2
    NSImageView *imgview2x2 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 563, 1000, 563)];
    imgview2x2.image = [NSImage imageNamed:@"2x2GridDetail_1000.png"];
    [self.sclview.documentView addSubview:imgview2x2];
    
    //Content Size
    self.startY = imgview2x2.frame.origin.y+imgview2x2.frame.size.height;
    [self.sclview.documentView setFrame:NSMakeRect(0, 0, w, self.startY)];
    [self.sclview.documentView scrollPoint:NSMakePoint(0, self.startY)];
    [self.sclview setScrollerStyle:NSScrollerStyleOverlay];
    [self scrollToYPosition:self.startY SclView:self.sclview];
    
    //Arrow
    self.upbtn.hidden = YES;
    [self.upbtn rotateByAngle:180];
    return self;
}

- (void)scrollToYPosition:(float)yCoord SclView:(NSScrollView*)scrollView
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.6];
    NSClipView* clipView = [scrollView contentView];
    NSPoint newOrigin = NSMakePoint(0, yCoord);
    [[clipView animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)onUp:(id)sender
{
    self.upbtn.hidden = YES;
    self.dnbtn.hidden = NO;
    [self scrollToYPosition:self.startY SclView:self.sclview];
}

- (IBAction)onDown:(id)sender
{
    self.upbtn.hidden = NO;
    self.dnbtn.hidden = YES;
    [self scrollToYPosition:0 SclView:self.sclview];
}

@end
