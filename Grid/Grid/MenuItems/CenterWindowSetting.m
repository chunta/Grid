//
//  CenterSettingVCtl.m
//  Grid
//
//  Created by Cindy on 2018/1/21.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "CenterWindowSetting.h"
#import "LADSlider.h"
#import <OGSwitch/OGSwitch-Swift.h>
@interface CenterWindowSetting ()
{
    NSTimer *timer;
    int slideW;
    int slideH;
}
@property(nonatomic, strong)IBOutlet NSView* wbg;
@property(nonatomic, strong)IBOutlet NSView* twindow;
@property(nonatomic, strong)IBOutlet NSTextField* tindicator;
@property(nonatomic, strong)IBOutlet NSSegmentedControl* segCtl;
@property(nonatomic, strong)IBOutlet LADSlider* tWSlider;
@property(nonatomic, strong)IBOutlet LADSlider* tHSlider;
@property(nonatomic, strong)IBOutlet OGSwitch* toggleView;
@end

@implementation CenterWindowSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wbg.wantsLayer = YES;
    self.wbg.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.wbg.layer.borderWidth = 1;
    self.wbg.layer.borderColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    
    self.twindow.wantsLayer = YES;
    self.twindow.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    self.twindow.layer.borderWidth = 1;
    self.twindow.layer.borderColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor;
    
    self.tWSlider.continuous = YES;
    self.tHSlider.continuous = YES;

    //***** warning ****//
    //[self deletePref];
    
    //Default value
    slideW = kDefault_Slider_W;
    slideH = kDefault_Slider_H;
    self.tWSlider.intValue = slideW;
    self.tHSlider.intValue = slideH;
}

- (void)dealloc
{
    [self writePref];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    //Synchornize
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreW] && [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreH])
    {
        NSString* w = [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreW];
        slideW = [w intValue];
        
        NSString* h = [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreH];
        slideH = [h intValue];
        
        self.tWSlider.intValue = slideW;
        self.tHSlider.intValue = slideH;
    }
    NSLog(@"%d %d %s", slideW, slideH, __func__);
    [self updateIndicatorTxtAndGraphic];
    
    //Sync segindex
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:kZeroOrSpaceForCenterWindow];
    if(str==nil)
    {
        [self.segCtl setSelectedSegment:0];
        str = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kZeroOrSpaceForCenterWindow];
    }
    else if ([str isEqualToString:@"0"])
    {
        [self.segCtl setSelectedSegment:0];
    }
    else
    {
        [self.segCtl setSelectedSegment:1];
    }
    NSLog(@"Zero Or Space:%@", str);
    
    //Sync on/off
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDisableCenterHotkey];
    if (obj)
    {
        [self.toggleView setIsOn:NO];
    }
    else
    {
        [self.toggleView setIsOn:YES];
    }
    [self.toggleView reloadLayer];
    self.toggleView.target = self;
    self.toggleView.action = @selector(onToggleView);
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    [self writePref];
}

- (void)writePref
{
    //(0 ~ 100) --> (50 ~ 80)
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", slideW] forKey:kCenterPreW];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", slideH] forKey:kCenterPreH];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Write Pref %d %d", slideW, slideH);
}

- (void)deletePref
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCenterPreW];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCenterPreH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateIndicatorTxtAndGraphic
{
    int rw = kDefault_CenterWindow_Scale_W*100 - kCenterWindow_AvailableValueToScaleDown * (1-(slideW / 100.0));
    int rh = kDefault_CenterWindow_Scale_H*100 - kCenterWindow_AvailableValueToScaleDown * (1-(slideH / 100.0));
    
    CGSize parentsize = self.wbg.frame.size;
    float W = parentsize.width * (rw/100.0);
    float H = parentsize.height * (rh/100.0);
    float mx = (parentsize.width - W) * 0.5;
    float my = (parentsize.height - H) * 0.5;
    self.twindow.frame = CGRectMake(mx, my, W, H);
    self.tindicator.stringValue = [NSString stringWithFormat:@"[ W: %0.3d%% H: %0.3d%% ]", rw, rh];
}

- (IBAction)onBack:(id)sender
{
    [self writePref];
    [self.delegate onCenterSettingBack];
}

- (IBAction)onSlideW:(id)sender
{
    NSLog(@"%d", self.tWSlider.intValue);
    slideW = self.tWSlider.intValue;
    
    NSLog(@"Slider W:%d H:%d", slideW, slideH);
    [self updateIndicatorTxtAndGraphic];
}

- (IBAction)onSlideH:(id)sender
{
    NSLog(@"%d", self.tHSlider.intValue);
    slideH = self.tHSlider.intValue;
    
    NSLog(@"Slider W:%d H:%d", slideW, slideH);
    [self updateIndicatorTxtAndGraphic];
}

- (IBAction)onSegCt:(id)sender
{
    NSLog(@"%ld", self.segCtl.selectedSegment);
    NSArray *segs = [NSArray arrayWithObjects:@"0", @"Space", nil];
    [[NSUserDefaults standardUserDefaults] setObject:[segs objectAtIndex:self.segCtl.selectedSegment]  forKey:kZeroOrSpaceForCenterWindow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onToggleView
{
    if (self.toggleView.isOn)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDisableCenterHotkey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kDisableCenterHotkey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
