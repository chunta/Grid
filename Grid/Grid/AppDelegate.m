//
//  AppDelegate.m
//  Grid
//
//  Created by ChunTa Chen on 4/30/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//
#import "AppDelegate.h"
#import "PrivacySetupWindow.h"
#import "TutorialWindow.h"
#import "GWinView.h"
#import "GridJKLMng.h"
#import "Grid3x3Mng.h"
#import "Grid2x2Mng.h"
#import "GridMvMng.h"
#import "GridCenterMng.h"
#import "GridFullScreenMng.h"
#import "GridToggleWindow.h"
#import "VisualGuideToggle.h"
#import "LaunchToggleWindow.h"
#import "KeyLogger.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Validator.h"
#import "GridItemsVCtlr.h"
#import "GridSetting.h"
#import "PreferModifierSetting.h"
#import "CenterWindowSetting.h"
#import "EULAView.h"
#import "LogMng.h"
#import "BannerMng.h"
#import "VersionMng.h"
#import "GridCtlServer.h"
#import "EULAWindow.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#if ENABLE_GEO
#import <CoreLocation/CoreLocation.h>
#endif

@interface AppDelegate ()<KeyLoggerDelegate, GridItemsVCtlrDelegate, PreferModifierSettingDelegate,
                          CenterWindowSettingDelegate, GridSettingDelegate, EULAViewDelegate, VersionMngDelegate, EULAWindowDelegate>
{
    NSStatusItem *statusItem;
    PrivacySetupWindow *privacysetupWindow;
    TutorialWindow *tutorialWindow;
    GridMng *gridMng;
    GridJKLMng *jklMng;
    GridMvMng *mvMng;
    GridCenterMng *centerMng;
    GridFullScreenMng *fullMng;
    GridToggleWindow *gridToggle;
    VisualGuideToggle *visualToggle;
    LaunchToggleWindow *launchToggle;
    KeyLogger *keyLogger;
    Validator *validator;
    GridItemsVCtlr *gridItems;
    PreferModifierSetting *premodiferSetting;
    GridSetting* gridSetting;
    CenterWindowSetting *centerSetting;
    EULAView *eulaView;
    EULAWindow *eulaWin;
    NSPopover *menuPopover;
    BannerMng *bannermng;
    VersionMng *versionmng;
    GridCtlServer *ctlServer;
    BOOL stopWorkingForUpdate;
#if ENABLE_GEO
    CLLocationManager *locationManager;
#endif
}
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if ENABLE_GEO
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
#endif
 
    //Show EULA Window
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AGREE_EULA])
    {
        int w = 600;
        int h = 720;
        NSArray *screenArray = [NSScreen screens];
        NSScreen *scn = [screenArray firstObject];
        NSRect sfn = [scn visibleFrame];
        NSRect mre = NSMakeRect((sfn.size.width-w)/2, (sfn.size.height-h)/2+150, w, h);
        eulaWin = [[EULAWindow alloc] initWithWindowNibName:@"EULAWindow"];
        eulaWin.delegate = self;
        [eulaWin showWindow:@"EULA"];
        [eulaWin.window setLevel:NSSubmenuWindowLevel];
        [eulaWin.window setFrame:mre display:YES];
    }
    
    //Zero or Space
    id str = [[NSUserDefaults standardUserDefaults] objectForKey:kZeroOrSpaceForCenterWindow];
    if (str==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kZeroOrSpaceForCenterWindow];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //Log
    [LogMng logLaunchEvent];
    
    //AutoLauncher
    BOOL startedAtLogin = NO;
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps)
    {
        if ([app.bundleIdentifier isEqualToString:LauncherAppBundleIdentifier])
        {
            startedAtLogin = YES;
        }
    }

    if (startedAtLogin)
    {
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:TerminateNotification object:[[NSBundle mainBundle] bundleIdentifier]];
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(checkAXIProcessTrusted) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    //StatusItem
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"appicon.png"];
    statusItem.highlightMode = YES;
    [statusItem.button setAction:@selector(onStatusItem:)];
    [self configureMenuIcon];
    
    //Prepare menu
    gridItems = [[GridItemsVCtlr alloc] initWithNibName:@"GridItemsVCtlr" bundle:[NSBundle mainBundle]];
    gridItems.delegate = self;
    
    //Preference init and update
    [self preparePreference];
    [self updateGridMng];
    
    //Fixed JKL Mng
    jklMng = [[GridJKLMng alloc] init];
    
    //Center Mng
    centerMng = [[GridCenterMng alloc] init];
    
    //Display MV Mng
    mvMng = [[GridMvMng alloc] init];
    
    //Fullscreen Mng
    fullMng = [[GridFullScreenMng alloc] init];
    
    //Init banner mng
    bannermng = [[BannerMng alloc] initWithTopButton:statusItem.button];
    
    //Version mng
    versionmng = [[VersionMng alloc] initWithTopButton:statusItem.button Delegate:self];
    
#if !ENABLE_KEYLOGGER
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *event) {
        if([event modifierFlags] & NSEventModifierFlagControl && [event modifierFlags] & NSEventModifierFlagOption)
        {
            CFTypeRef focuswin = [self getActiveWindow];
            if (focuswin)
            {
                NSString *keychar = [event charactersIgnoringModifiers];
                
                [self preferenceToggleByKeyEvent:event];
                
                NSAssert(gridMng!=nil, @"We should already init gridManager");
                [gridMng snapWindowSize:focuswin KeyEvent:event];
            }
        }
    }];
#else
    keyLogger = [[KeyLogger alloc] initWithDelegate:self];
#endif
    
    //Launch Item
    if (!SMLoginItemSetEnabled ((__bridge CFStringRef)LauncherAppBundleIdentifier, YES))//Turn on launch at login
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Couldn't add Helper App to launch at login item list."];
        [alert runModal];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kLaunchAtStartup];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kLaunchAtStartup];
    }
    
    //Monitor for Close popover
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSRightMouseDownMask
                                           handler:^(NSEvent* aEvent){
                                               if (menuPopover)
                                               {
                                                   [menuPopover close];
                                                   menuPopover = nil;
                                               }
                                           }];
    [Fabric with:@[[Crashlytics class]]];

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
}

#if ENABLE_GEO
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *loc = [locations firstObject];
    NSLog(@"%f %f", loc.coordinate.longitude, loc.coordinate.latitude);
}
#endif

- (void)onStatusItem:(id)sender
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
        return;
    }
    
    //Log
    [LogMng logOpenTopMenuEvent];
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.contentViewController = gridItems;
    [menuPopover setContentSize: gridItems.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSRectEdgeMaxY];
}

- (void)onJustOpenStatusItem
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = gridItems;
    [menuPopover setContentSize: gridItems.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:statusItem.button preferredEdge:NSRectEdgeMaxY];
}

#pragma mark - EULA Window
- (void)eulawindowClose
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AGREE_EULA])
    {
        [NSApp terminate:self];
    }
}

#pragma mark - Configure MenuIcon
- (void)configureMenuIcon
{
    NSAssert(statusItem, @"Status Item should not be nil");
    
    //Should be enable or disable
    BOOL enabled = AXIsProcessTrusted();
    
    //Grid 2x2 or 3x3
    BOOL grid3x3 = YES;
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
    if (str)
    {
        if ([str isEqualToString:kPreferenceGrid2])
        {
            grid3x3 = NO;
        }
    }
    
    NSString *filename = @"grid3x3-";
    if (grid3x3==NO)
    {
        filename = @"grid2x2-";
    }
    if (enabled)
    {
        filename = [NSString stringWithFormat:@"%@enable.png",filename];
    }
    else
    {
        filename = [NSString stringWithFormat:@"%@disable.png",filename];
    }
    NSImage* img = [NSImage imageNamed:filename];
    [img setTemplate:YES];
    statusItem.image = img;
}

#pragma mark - GridItemDelegate
- (void)gridmenuSettingChange
{
    [self configureMenuIcon];
    [self updateGridMng];
}

- (void)toGrid:(NSString *)type
{
    if([type isEqualToString:kPreferenceGrid3] || [type isEqualToString:kPreferenceGrid2])
    {
        /************ LOG ************/
        [LogMng logChangeGridType:type];
        /*****************************/
        
        NSInteger val = [type integerValue];
        //Show toggle indicator
        if (gridToggle)
        {
            [gridToggle close];
        }
        gridToggle = [[GridToggleWindow alloc] initWithGridType:(int)val Ref:[self getActiveWindow]];
        [gridToggle showWindow:@"Grid Toggle"];
        [gridToggle.window setLevel:NSSubmenuWindowLevel];
        gridToggle.window.alphaValue = 0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = kGuideShowDuration;
            gridToggle.window.animator.alphaValue = 1;
        } completionHandler:^{
            [gridToggle close];
        }];
    }
    else
    {
        NSAssert(0,@"toGrid invalid input");
    }
}

- (void)toVisual:(BOOL)isOn
{
    int val = isOn;
    //Show toggle indicator
    if (visualToggle)
    {
        [visualToggle close];
    }
    
    /************ LOG ************/
    [LogMng logChangeVGuidance:[NSString stringWithFormat:@"%d", val]];
    /*****************************/
    
    visualToggle = [[VisualGuideToggle alloc] initWithOnOff:val Ref:[self getActiveWindow]];
    [visualToggle showWindow:@"VisualGuide Toggle"];
    [visualToggle.window setLevel:NSSubmenuWindowLevel];
    visualToggle.window.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = kGuideShowDuration;
        visualToggle.window.animator.alphaValue = 1;
    } completionHandler:^{
        [visualToggle close];
    }];
}

- (void)toLaunchStart:(BOOL)isOn
{
    int val = isOn;
    if(launchToggle)
    {
        [launchToggle close];
    }

    /************ LOG ************/
    [LogMng logChangeVGuidance:[NSString stringWithFormat:@"%d", val]];
    /*****************************/
    
    launchToggle = [[LaunchToggleWindow alloc] initWithLaunchOn:isOn Ref:[self getActiveWindow]];
    [launchToggle showWindow:@"Launch Toggle"];
    [launchToggle.window setLevel:NSSubmenuWindowLevel];
    launchToggle.window.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = kGuideShowDuration;
        launchToggle.window.animator.alphaValue = 1;
    } completionHandler:^{
        [launchToggle close];
    }];
}

- (void)toGridSetting
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    gridSetting = nil;
    gridSetting = [[GridSetting alloc] initWithNibName:@"GridSetting" bundle:[NSBundle mainBundle]];
    gridSetting.delegate = self;
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = gridSetting;
    [menuPopover setContentSize: gridSetting.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:statusItem.button preferredEdge:NSRectEdgeMaxY];
    
    /************ LOG ************/
    [LogMng logOpenModifierSetting];
    /*****************************/
}

- (void)toModifierSetting
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    premodiferSetting = nil;
    premodiferSetting = [[PreferModifierSetting alloc] initWithNibName:@"PreferModifierSetting" bundle:[NSBundle mainBundle]];
    premodiferSetting.delegate = self;
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = premodiferSetting;
    [menuPopover setContentSize: premodiferSetting.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:statusItem.button preferredEdge:NSRectEdgeMaxY];
    
    /************ LOG ************/
    [LogMng logOpenModifierSetting];
    /*****************************/
}

- (void)toCenterSetting
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    centerSetting = nil;
    centerSetting = [[CenterWindowSetting alloc] initWithNibName:@"CenterWindowSetting" bundle:[NSBundle mainBundle]];
    centerSetting.delegate = self;
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = centerSetting;
    [menuPopover setContentSize: centerSetting.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:statusItem.button preferredEdge:NSRectEdgeMaxY];
    
    /************ LOG ************/
    [LogMng logOpenModifierSetting];
    /*****************************/
}

- (void)toEULA
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    eulaView = nil;
    eulaView = [[EULAView alloc] initWithNibName:@"EULAView" bundle:[NSBundle mainBundle]];
    eulaView.delegate = self;
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = eulaView;
    [menuPopover setContentSize: eulaView.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:statusItem.button preferredEdge:NSRectEdgeMaxY];
    
    /************ LOG ************/
    [LogMng logOpenModifierSetting];
    /*****************************/
}

#pragma mark - PreModifierDelegate
- (void)onModifierSettingBack
{
    [self onJustOpenStatusItem];
}

#pragma mark - VersionMng
- (void)stayInForceUpdate
{
    stopWorkingForUpdate = YES;
}

#pragma mark - GridSetting
- (void)onGridSettingBack
{
    [self onJustOpenStatusItem];
}

#pragma mark - EULAView
- (void)onEULABack
{
    [self onJustOpenStatusItem];
}

#pragma mark - CenterSetting
- (void)onCenterSettingBack
{
    [self onJustOpenStatusItem];
}

#pragma mark - KeyLoggerDelegate
- (void)validInput:(NSUInteger)aKeyCode Str:(NSString*)aKeyStr
{
    if ([versionmng needForceUpdate])
    {
        return;
    }
#if DISABLE_ALL
    return;
#endif
    // Force update ////////////////////
    if (stopWorkingForUpdate)
    {
        NSLog(@"stopWorkingForUpdate...");
        return;
    }
    ////////////////////////////////////
    
    [self preferenceToggleByKeyStr:aKeyStr];
    
    CFTypeRef focuswin = [self getActiveWindow];
    if (focuswin)
    {
        NSAssert(gridMng!=nil, @"We should already init gridManager");
        [gridMng snapWindowSize:focuswin KeyCode:aKeyCode KeyStr:aKeyStr];
        [jklMng snapWindowSize:focuswin KeyCode:aKeyCode KeyStr:aKeyStr];
        [centerMng snapWindowSize:focuswin KeyCode:aKeyCode KeyStr:aKeyStr];
        [mvMng moveWindow:focuswin KeyCode:aKeyCode];
        [fullMng snapWindowSize:focuswin KeyCode:aKeyCode KeyStr:aKeyStr];
    }
}

#pragma mark - Privacy Trust
- (void)checkAXIProcessTrusted
{
    id eula = [[NSUserDefaults standardUserDefaults] objectForKey:AGREE_EULA];
    //NSLog(@"checkAXIProcessTrusted.....");
    if (eula==nil)
    {
        //NSLog(@"no AGREE EULA");
    }
    else
    {
        //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:AGREE_EULA]);
    }
    if (privacysetupWindow==nil && NO==AXIsProcessTrusted() && [[NSUserDefaults standardUserDefaults] objectForKey:AGREE_EULA])
    {
        privacysetupWindow = [[PrivacySetupWindow alloc] init];
        [privacysetupWindow showWindow:@"PrivacySetup"];
        [privacysetupWindow.window setLevel:NSFloatingWindowLevel];
        
        [self configureMenuIcon];
    }
}

#pragma mark - Preference / MenuAction
- (void)preferenceToggleByKeyEvent:(NSEvent*)keyevent
{
    NSString *keychar = [keyevent charactersIgnoringModifiers];
    if ([[keychar lowercaseString] isEqualToString:@"g"])
    {
        [self toggleGrid:nil];
    }
    else if ([[keychar lowercaseString] isEqualToString:@"v"])
    {
        [self toggleVisualGuide:nil];
    }
}

- (void)preferenceToggleByKeyStr:(NSString*)keystr
{
    if ([[keystr lowercaseString] isEqualToString:@"g"])
    {
        [self toggleGrid:nil];
    }
    else if ([[keystr lowercaseString] isEqualToString:@"v"])
    {
      //  [self toggleVisualGuide:nil];
    }
}

- (void)preparePreference
{
    //Toggle visual grid guidance
    {
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleVisual];
        if (obj==nil)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kToggleVisual];
        }
    }
    
    //Toggle grid type 2x2 or 3x3
    {
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
        if (obj==nil)
        {
            [[NSUserDefaults standardUserDefaults] setObject:kDefaultPreferenceGrid forKey:kToggleGrid];
        }
    }
}

- (void)updateGridMng
{
    //Grid type
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
    NSAssert(obj!=nil, @"kToggleGrid should not be nil in this place");
        
    NSMenuItem *item = [statusItem.menu itemWithTag:kToggleGridTag];
    NSInteger val = [obj integerValue];
    if (val==2)
    {
        [item setTitle:NSLocalizedString(@"Grid3x3", comment: @"")];
        gridMng = [[Grid2x2Mng alloc] init];
    }
    else
    {
        [item setTitle:NSLocalizedString(@"Grid2x2", comment: @"")];
        gridMng = [[Grid3x3Mng alloc] init];
    }
}

- (void)toggleGrid:(id)sender
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleGrid];
    NSAssert(obj!=nil, @"kToggleGrid should not be nil in this place");
    NSInteger val = [obj integerValue];
    if (val == [kPreferenceGrid2 integerValue])
    {
        val = [kPreferenceGrid3 integerValue];
    }
    else
    {
        val = [kPreferenceGrid2 integerValue];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", val] forKey:kToggleGrid];
    
    /************ LOG ************/
    [LogMng logChangeGridType:[NSString stringWithFormat:@"%ld", val]];
    /*****************************/
    
    //Update menu title
    [self updateGridMng];
    
    //Show toggle indicator
    if (gridToggle)
    {
        [gridToggle close];
    }

    gridToggle = [[GridToggleWindow alloc] initWithGridType:(int)val Ref:[self getActiveWindow]];
    [gridToggle showWindow:@"Grid Toggle"];
    [gridToggle.window setLevel:NSSubmenuWindowLevel];
    gridToggle.window.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = kGuideShowDuration;
        gridToggle.window.animator.alphaValue = 1;
    } completionHandler:^{
        [gridToggle close];
    }];
    
    [self configureMenuIcon];
}

- (void)toggleVisualGuide:(id)sender
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kToggleVisual];
    NSAssert(obj!=nil, @"kToggleVisual should not be nil in this place");
    BOOL val = [obj boolValue];
    val = !val;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", val] forKey:kToggleVisual];
    
    /************ LOG ************/
    [LogMng logChangeVGuidance:[NSString stringWithFormat:@"%d", val]];
    /*****************************/
    
    //Show toggle indicator
    if (visualToggle)
    {
        [visualToggle close];
    }
    visualToggle = [[VisualGuideToggle alloc] initWithOnOff:val Ref:[self getActiveWindow]];
    [visualToggle showWindow:@"VisualGuide Toggle"];
    [visualToggle.window setLevel:NSSubmenuWindowLevel];
    visualToggle.window.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = kGuideShowDuration;
        visualToggle.window.animator.alphaValue = 1;
    } completionHandler:^{
        [visualToggle close];
    }];
}

- (void)pickGridColor:(id)sender
{
    
}

- (void)quitApp:(id)sender
{
    [NSApp terminate:self];
}

#pragma mark - System Event
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

#pragma mark - Accessibility
- (CFTypeRef)getActiveWindow
{
    AXUIElementRef _systemWide = AXUIElementCreateSystemWide();
    CFArrayRef attrList;
    if (AXUIElementCopyAttributeNames(_systemWide, &attrList) == kAXErrorSuccess)
    {
        CFTypeRef focusApp;
        if (AXUIElementCopyAttributeValue(_systemWide, kAXFocusedApplicationAttribute, &focusApp) == kAXErrorSuccess)
        {
            CFTypeRef focusWin;
            if (AXUIElementCopyAttributeValue(focusApp, kAXFocusedWindowAttribute, &focusWin) == kAXErrorSuccess)
            {
                CFStringRef titleRef;
                if (AXUIElementCopyAttributeValue(focusWin, kAXTitleAttribute, (CFTypeRef *)&titleRef) == kAXErrorSuccess)
                {
                    NSString *title = (__bridge NSString *)titleRef;
                    NSLog(@"Active window name is:%@", title);
                }
                if (AXUIElementCopyAttributeValue(focusWin, kAXRoleDescriptionAttribute, (CFTypeRef *)&titleRef) == kAXErrorSuccess)
                {
                    NSString *title = (__bridge NSString *)titleRef;
                    NSLog(@"Active window kAXRoleDescriptionAttribute is:%@", title);
                    if ([title containsString:@"popover"] || [title containsString:@"彈出"])
                    {
                        return nil;
                    }
                }
                return focusWin;
            }
        }
    }
    return nil;
}

@end
