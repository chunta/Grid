//
//  AppDelegate.m
//  GridLauncher
//
//  Created by ChunTa Chen on 2017/5/23.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "AppDelegate.h"


#if DEV
#define MainAppName @"Grid_DEV"
#define MainAppBundleIdentifier @"com.mildgrind.grid-dev"
#elif UAT
#define MainAppName @"Grid_UAT"
#define MainAppBundleIdentifier @"com.mildgrind.grid-uat"
#else
#define MainAppName @"Grid"
#define MainAppBundleIdentifier @"com.mildgrind.grid"
#endif

#define TerminateNotification @"TERMINATEHELPER"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"%@", MainAppName);
    NSLog(@"%@", MainAppBundleIdentifier);
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running)
    {
        if ([[app bundleIdentifier] isEqualToString:MainAppBundleIdentifier])
        {
            alreadyRunning = YES;
        }
    }
    
    if (alreadyRunning)
    {
        [self killApp];
    }
    else
    {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(killApp) name:TerminateNotification object:MainAppBundleIdentifier];
        
        // Launch main app
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:MainAppName];
        NSString *mainAppPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:mainAppPath];
    }
}

-(void)killApp
{
    [NSApp terminate:nil];
}

@end
