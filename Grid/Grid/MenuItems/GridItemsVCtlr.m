//
//  ColorPickerItemVCtlr.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/14.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridItemsVCtlr.h"
#import "DotCheckButton.h"
#import "CheckButton.h"
#import <ServiceManagement/ServiceManagement.h>
#import "PreferModifierSetting.h"
#import "PrefeAndStyle.h"
#import "CenterWindowSetting.h"
#import "LogMng.h"
#import <OGSwitch/OGSwitch-Swift.h>
@interface GridItemsVCtlr ()

@property(nonatomic, strong)IBOutlet DotCheckButton *cellColor01;
@property(nonatomic, strong)IBOutlet DotCheckButton *cellColor02;
@property(nonatomic, strong)IBOutlet DotCheckButton *cellColor03;
@property(nonatomic, strong)IBOutlet DotCheckButton *cellColor04;
@property(nonatomic, strong)IBOutlet DotCheckButton *cellColor05;
@property(nonatomic, strong)NSArray *cellColors;

@property(nonatomic, strong)IBOutlet DotCheckButton *borderColor01;
@property(nonatomic, strong)IBOutlet DotCheckButton *borderColor02;
@property(nonatomic, strong)IBOutlet DotCheckButton *borderColor03;
@property(nonatomic, strong)NSArray *brdColors;

@property(nonatomic, strong)PreferModifierSetting *premodifier;
@property(nonatomic, strong)CenterWindowSetting *centervctl;

@property(nonatomic, strong)IBOutlet NSButton *visualOn;
@property(nonatomic, strong)IBOutlet NSButton *visualOff;

@property(nonatomic, strong)IBOutlet NSButton *gridtype3x3;
@property(nonatomic, strong)IBOutlet NSButton *gridtype2x2;

@property(nonatomic, strong)IBOutlet NSButton *startupOn;
@property(nonatomic, strong)IBOutlet NSButton *startupOff;

@property(nonatomic, strong)IBOutlet OGSwitch *visualSwitch;
@property(nonatomic, strong)IBOutlet OGSwitch *launchSwitch;

@property(nonatomic, strong)NSMutableArray *hlineList;

@property(nonatomic, strong)IBOutlet NSTextField *vguidanceTxt;
@property(nonatomic, strong)IBOutlet NSTextField *typeTxt;
@property(nonatomic, strong)IBOutlet NSTextField *modifierTxt;
@property(nonatomic, strong)IBOutlet NSTextField *expandTxt;
@property(nonatomic, strong)IBOutlet NSTextField *expandDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *crossMonitorTxt;
@property(nonatomic, strong)IBOutlet NSTextField *crossMonitorDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *numberTxt;
@property(nonatomic, strong)IBOutlet NSTextField *numberDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *jklTxt;
@property(nonatomic, strong)IBOutlet NSTextField *jklDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *centerTxt;
@property(nonatomic, strong)IBOutlet NSTextField *centerDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *fullscnTxt;
@property(nonatomic, strong)IBOutlet NSTextField *fullscnDesTxt;
@property(nonatomic, strong)IBOutlet NSTextField *cellColorTxt;
@property(nonatomic, strong)IBOutlet NSTextField *borderColorTxt;
@property(nonatomic, strong)IBOutlet NSTextField *launchAtStartupTxt;

@property(nonatomic, strong)IBOutlet NSTextField *exInfo;
@end

@implementation GridItemsVCtlr

- (void)viewDidLoad
{
    [super viewDidLoad];
#if UAT
    self.exInfo.stringValue = @"UAT";
#elif DEV
    self.exInfo.stringValue = @"DEV";
#endif
    
    self.cellColor01.wantsLayer = YES;
    self.cellColor02.wantsLayer = YES;
    self.cellColor03.wantsLayer = YES;
    self.cellColor04.wantsLayer = YES;
    self.cellColor05.wantsLayer = YES;
    self.cellColor01.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.cellColor02.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.cellColor03.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.cellColor04.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.cellColor05.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.cellColors = [NSArray arrayWithObjects:self.cellColor01, self.cellColor02, self.cellColor03, self.cellColor04, self.cellColor05, nil];
    NSButtonCell *cell = self.cellColor01.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.cellColor02.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.cellColor03.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.cellColor04.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.cellColor05.cell;
    cell.backgroundColor = [NSColor clearColor];
    
    self.borderColor01.wantsLayer = YES;
    self.borderColor02.wantsLayer = YES;
    self.borderColor03.wantsLayer = YES;
    self.borderColor01.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.borderColor02.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.borderColor03.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.brdColors = [NSArray arrayWithObjects:self.borderColor01, self.borderColor02, self.borderColor03, nil];
    cell = self.borderColor01.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.borderColor02.cell;
    cell.backgroundColor = [NSColor clearColor];
    cell = self.borderColor03.cell;
    cell.backgroundColor = [NSColor clearColor];
    
    //Default settings
    id cellindex = [[NSUserDefaults standardUserDefaults] objectForKey:kCellSelectIndex];
    if (cellindex==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kCellSelectIndex];
    }
    id brdindex = [[NSUserDefaults standardUserDefaults] objectForKey:kBorderSelectIndex];
    if(brdindex==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kBorderSelectIndex];
    }
    
    //Gen h-line
    self.hlineList = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++)
    {
        NSView* line = [[NSView alloc] initWithFrame:NSMakeRect(0, self.view.frame.size.height-(i+1)*42, 354, 1)];
        line.wantsLayer = YES;
        line.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        [self.view addSubview:line];
    }
    
    //Update settings
    [self updateSettings];
    
    //UISwitch
    self.visualSwitch.target = self;
    self.visualSwitch.action = @selector(onToggleSegments:);
    
    self.launchSwitch.target = self;
    self.launchSwitch.action = @selector(onToggleSegments:);
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self updateSettings];
}
- (void)updateSettings
{
    //Sync pref
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
    if ([str isEqualToString:kPreferenceGrid3])
    {
        [self.gridtype3x3 setImage:[NSImage imageNamed:@"Toggle_3x3_Enabled.png"]];
        [self.gridtype2x2 setImage:[NSImage imageNamed:@"Toggle_2x2_Disabled.png"]];
    }
    else if ([str isEqualToString:kPreferenceGrid2])
    {
        [self.gridtype3x3 setImage:[NSImage imageNamed:@"Toggle_3x3_Disabled.png"]];
        [self.gridtype2x2 setImage:[NSImage imageNamed:@"Toggle_2x2_Enabled.png"]];
    }
    str = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleVisual];
    if ([str isEqualToString:@"1"])
    {
        [self.visualOn setImage:[NSImage imageNamed:@"Toggle_On_Enabled.png"]];
        [self.visualOff setImage:[NSImage imageNamed:@"Toggle_Off_Disabled.png"]];
        [self.visualSwitch setIsOn:YES];
        [self.visualSwitch reloadLayer];
    }
    else
    {
        [self.visualOn setImage:[NSImage imageNamed:@"Toggle_On_Disabled.png"]];
        [self.visualOff setImage:[NSImage imageNamed:@"Toggle_Off_Enabled.png"]];
        [self.visualSwitch setIsOn:NO];
        [self.visualSwitch reloadLayer];
    }
    str =  [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchAtStartup];
    if ([str isEqualToString:@"1"])
    {
        [self.startupOn setImage:[NSImage imageNamed:@"Toggle_On_Enabled.png"]];
        [self.startupOff setImage:[NSImage imageNamed:@"Toggle_Off_Disabled.png"]];
        [self.launchSwitch setIsOn:YES];
        [self.launchSwitch reloadLayer];
    }
    else
    {
        [self.startupOn setImage:[NSImage imageNamed:@"Toggle_On_Disabled.png"]];
        [self.startupOff setImage:[NSImage imageNamed:@"Toggle_Off_Enabled.png"]];
        [self.launchSwitch setIsOn:NO];
        [self.launchSwitch reloadLayer];
    }
    NSLog(@"%@", NSLocalizedStringFromTable(@"Visual Guidance", @"Localization", @""));
    self.vguidanceTxt.stringValue = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"Visual Guidance", @"Localization", @"")];
    self.typeTxt.stringValue = [NSString stringWithFormat:@"%@ (G)", NSLocalizedStringFromTable(@"Grid Type", @"Localization", @"")];
    self.expandTxt.stringValue = [NSString stringWithFormat:@"%@ + %@", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                  NSLocalizedStringFromTable(@"Arrow Key", @"Localization", @"")];
    self.expandDesTxt.stringValue = NSLocalizedStringFromTable(@"Expand Window", @"Localization", @"");
    
    self.numberTxt.stringValue = [NSString stringWithFormat:@"%@ + %@", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                  NSLocalizedStringFromTable(@"Number Key", @"Localization", @"")];
    self.numberDesTxt.stringValue = NSLocalizedStringFromTable(@"Move Window", @"Localization", @"");
    self.jklTxt.stringValue = [NSString stringWithFormat:@"%@ + J,K,L", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @"")];
    self.jklDesTxt.stringValue = NSLocalizedStringFromTable(@"LeftMidRightScreenWidth", @"Localization", @"");
    
    //0 or Space
    NSString *zerospace = [[NSUserDefaults standardUserDefaults] objectForKey:kZeroOrSpaceForCenterWindow];
    if (zerospace)
    {
        if ([zerospace isEqualToString:@"0"])
        {
            self.centerTxt.stringValue = [NSString stringWithFormat:@"%@ + %@", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                          NSLocalizedStringFromTable(@"Zero", @"Localization", @"")];
        }
        else
        {
            self.centerTxt.stringValue = [NSString stringWithFormat:@"%@ + %@", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                          NSLocalizedStringFromTable(@"Space", @"Localization", @"")];
        }
    }
    else
    {
    self.centerTxt.stringValue = [NSString stringWithFormat:@"%@ + %@", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                  NSLocalizedStringFromTable(@"Zero", @"Localization", @"")];
    }
    
    self.centerDesTxt.stringValue = NSLocalizedStringFromTable(@"Center Window", @"Localization", @"");
    self.fullscnTxt.stringValue = [NSString stringWithFormat:@"%@ + Enter", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @"")];
    self.fullscnDesTxt.stringValue = NSLocalizedStringFromTable(@"FullScreen", @"Localization", @"");
    self.crossMonitorTxt.stringValue = [NSString stringWithFormat:@"%@ + <,>", NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),
                                        NSLocalizedStringFromTable(@"Cross Key", @"Localization", @"")];
    self.crossMonitorDesTxt.stringValue = NSLocalizedStringFromTable(@"Pre/Next Screen", @"Localization", @"");
    self.cellColorTxt.stringValue = NSLocalizedStringFromTable(@"Pre/Next Screen", @"Localization", @"");
    self.borderColorTxt.stringValue = NSLocalizedStringFromTable(@"Border Color", @"Localization", @"");
    self.cellColorTxt.stringValue = NSLocalizedStringFromTable(@"Cell Color", @"Localization", @"");
    self.launchAtStartupTxt.stringValue = NSLocalizedStringFromTable(@"Launch at startup", @"Localization", @"");
    
    //Update Modifier txt
    NSString* m01 = [[NSUserDefaults standardUserDefaults] objectForKey:kModifier01];
    NSString* m02 = [[NSUserDefaults standardUserDefaults] objectForKey:kModifier02];
    if (m01==nil || m02==nil)
    {
        NSInteger im01 = [PrefeAndStyle defaultModifier01]; 
        NSInteger im02 = [PrefeAndStyle defaultModifier02]; 
        NSString *strm01 = [GHelper modifierConvertToString:im01];
        NSString *strm02 = [GHelper modifierConvertToString:im02];
        self.modifierTxt.stringValue = [NSString stringWithFormat:@"%@ (  %@ + %@  )",NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),strm01,strm02];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", im01] forKey:kModifier01];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", im02] forKey:kModifier02];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(m01 && m02)
    {
        NSInteger im01 = [m01 integerValue];
        NSInteger im02 = [m02 integerValue];
        NSString *strm01 = [GHelper modifierConvertToString:im01];
        NSString *strm02 = [GHelper modifierConvertToString:im02];
        self.modifierTxt.stringValue = [NSString stringWithFormat:@"%@ (  %@ + %@  )",NSLocalizedStringFromTable(@"Modifer Key", @"Localization", @""),strm01,strm02];
    }
    
    [LogMng logChangeMod01:m01 Mod02:m02];
    
    //Update settings - Cell Index
    for (int i = 0; i < self.cellColors.count; i++)
    {
        DotCheckButton *btn = [self.cellColors objectAtIndex:i];
        btn.checked = NO;
    }
    NSString *cellstr = [[NSUserDefaults standardUserDefaults] objectForKey:kCellSelectIndex];
    int cellint = [cellstr intValue];
    DotCheckButton *cellbtn = [self.cellColors objectAtIndex:cellint];
    cellbtn.checked = YES;
    [cellbtn setNeedsDisplay];
    
    //Update settings - Border Index
    for (int i = 0; i < self.brdColors.count; i++)
    {
        DotCheckButton *btn = [self.brdColors objectAtIndex:i];
        btn.checked = NO;
    }
    NSString *brdstr = [[NSUserDefaults standardUserDefaults] objectForKey:kBorderSelectIndex];
    int brdint = [brdstr intValue];
    DotCheckButton *brdbtn = [self.brdColors objectAtIndex:brdint];
    brdbtn.checked = YES;
    [brdbtn setNeedsDisplay];
}

- (IBAction)onPickCellColor:(id)sender
{
    self.cellColor01.checked = (self.cellColor01==sender)?YES:NO;
    self.cellColor02.checked = (self.cellColor02==sender)?YES:NO;
    self.cellColor03.checked = (self.cellColor03==sender)?YES:NO;
    self.cellColor04.checked = (self.cellColor04==sender)?YES:NO;
    self.cellColor05.checked = (self.cellColor05==sender)?YES:NO;
    
    [self.cellColor01 setNeedsDisplay];
    [self.cellColor02 setNeedsDisplay];
    [self.cellColor03 setNeedsDisplay];
    [self.cellColor04 setNeedsDisplay];
    [self.cellColor05 setNeedsDisplay];
    
    NSUInteger index = [self.cellColors indexOfObject:sender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)index] forKey:kCellSelectIndex];
    [self updateSettings];
    
    /************ LOG ************/
    [LogMng logChangeCellColor:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    /*****************************/
}

- (IBAction)onPickBorderColor:(id)sender
{
    self.borderColor01.checked = (self.borderColor01==sender)?YES:NO;
    self.borderColor02.checked = (self.borderColor02==sender)?YES:NO;
    self.borderColor03.checked = (self.borderColor03==sender)?YES:NO;
    
    [self.borderColor01 setNeedsDisplay];
    [self.borderColor02 setNeedsDisplay];
    [self.borderColor03 setNeedsDisplay];
    
    NSUInteger index = [self.brdColors indexOfObject:sender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)index] forKey:kBorderSelectIndex];
    [self updateSettings];
    
    /************ LOG ************/
    [LogMng logChangeBorderColor:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    /*****************************/
}

- (IBAction)onChangeModifier:(id)sender
{
    [self.delegate toModifierSetting];
}

- (IBAction)onGridSetting:(id)sender
{
    [self.delegate toGridSetting];
}

- (IBAction)onHiddenSettings:(id)sender
{
    NSWindow *window = [[[NSApplication sharedApplication] currentEvent] window];
    NSRect rect = [window frame];
    NSPoint pt = NSMakePoint(rect.origin.x + rect.size.width-30, rect.origin.y+60);
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // example: 1.0.0
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *vb = [NSString stringWithFormat:@"%@.%@",appVersion,buildNumber];
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:NSLocalizedStringFromTable(@"About Mildgrind.com", @"Localization", @"") action:@selector(onGo2OfficeSite:) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:NSLocalizedStringFromTable(@"License Agreement", @"Localization", @"") action:@selector(onEULA:) keyEquivalent:@"" atIndex:1];
    [theMenu insertItemWithTitle:vb action:nil keyEquivalent:@"" atIndex:2];
    [theMenu insertItemWithTitle:NSLocalizedStringFromTable(@"Quit", @"Localization", @"") action:@selector(onExitApp:) keyEquivalent:@"" atIndex:3];
    [theMenu popUpMenuPositioningItem:nil atLocation:pt inView:nil];
}

- (IBAction)onSetupCenter:(id)sender
{
    NSLog(@"Center..");
    [self.delegate toCenterSetting];
}

- (IBAction)onToggleSegments:(id)sender
{
    if (sender==self.gridtype3x3)
    {
        NSString* type = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
        if (type && [type isEqualToString:kPreferenceGrid3])
        {
            NSLog(@"already grid 3x3");
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:kPreferenceGrid3 forKey:kToggleGrid];
        
        [self.gridtype3x3 setImage:[NSImage imageNamed:@"Toggle_3x3_Enabled.png"]];
        [self.gridtype2x2 setImage:[NSImage imageNamed:@"Toggle_2x2_Disabled.png"]];
        
        [self.delegate toGrid:kPreferenceGrid3];
    }
    else if(sender==self.gridtype2x2)
    {
        NSString* type = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
        if (type && [type isEqualToString:kPreferenceGrid2])
        {
            NSLog(@"already grid 2x2");
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:kPreferenceGrid2 forKey:kToggleGrid];
        
        [self.gridtype3x3 setImage:[NSImage imageNamed:@"Toggle_3x3_Disabled.png"]];
        [self.gridtype2x2 setImage:[NSImage imageNamed:@"Toggle_2x2_Enabled.png"]];
        
        [self.delegate toGrid:kPreferenceGrid2];
    }
    else if(sender==self.visualOn)
    {
        NSString *onoff = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleVisual];
        int val = [onoff intValue];
        if(val==1)
        {
            NSLog(@"already on");
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kToggleVisual];
        
        [self.visualOn setImage:[NSImage imageNamed:@"Toggle_On_Enabled.png"]];
        [self.visualOff setImage:[NSImage imageNamed:@"Toggle_Off_Disabled.png"]];
        
        [self.delegate toVisual:YES];
    }
    else if(sender==self.visualOff)
    {
        NSString *onoff = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleVisual];
        int val = [onoff intValue];
        if(val==0)
        {
            NSLog(@"already off");
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kToggleVisual];
        
        [self.visualOn setImage:[NSImage imageNamed:@"Toggle_On_Disabled.png"]];
        [self.visualOff setImage:[NSImage imageNamed:@"Toggle_Off_Enabled.png"]];
        
        [self.delegate toVisual:NO];
    }
    else if(sender==self.startupOn)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kLaunchAtStartup];
        if (SMLoginItemSetEnabled ((__bridge CFStringRef)LauncherAppBundleIdentifier, YES))//Turn on launch at login
        {
            NSLog(@"OK to turn on launch at startup");
        }
        
        [self.startupOn setImage:[NSImage imageNamed:@"Toggle_On_Enabled.png"]];
        [self.startupOff setImage:[NSImage imageNamed:@"Toggle_Off_Disabled.png"]];
    }
    else if(sender==self.startupOff)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kLaunchAtStartup];
        if (SMLoginItemSetEnabled ((__bridge CFStringRef)LauncherAppBundleIdentifier, NO))//Turn off launch at login
        {
            NSLog(@"OK to turn off launch at startup");
        }
        
        [self.startupOn setImage:[NSImage imageNamed:@"Toggle_On_Disabled.png"]];
        [self.startupOff setImage:[NSImage imageNamed:@"Toggle_Off_Enabled.png"]];
    }
    else if(sender==self.visualSwitch)
    {
        NSString* onoff = (self.visualSwitch.isOn)?@"1":@"0";
        [[NSUserDefaults standardUserDefaults] setObject:onoff forKey:kToggleVisual];
        [self.delegate toVisual:self.visualSwitch.isOn];
    }
    else if(sender==self.launchSwitch)
    {
        NSString* onoff = (self.launchSwitch.isOn)?@"1":@"0";
        [[NSUserDefaults standardUserDefaults] setObject:onoff forKey:kLaunchAtStartup];
        if (SMLoginItemSetEnabled ((__bridge CFStringRef)LauncherAppBundleIdentifier, [onoff boolValue]))//Turn off launch at login
        {
            NSLog(@"OK to turn off launch at startup");
        }
        [self.delegate toLaunchStart:self.launchSwitch.isOn];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate gridmenuSettingChange];
}

- (void)onGo2OfficeSite:(id)sender
{
    NSURL *myURL = [NSURL URLWithString:@"https://mildgrind.com"];
    [[NSWorkspace sharedWorkspace] openURL:myURL];
}

- (void)onEULA:(id)sender
{
    [self.delegate toEULA];
}

- (void)onExitApp:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
