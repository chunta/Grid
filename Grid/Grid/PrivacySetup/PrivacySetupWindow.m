//
//  PrivacySetupWindow.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/16.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "PrivacySetupWindow.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface PrivacySetupWindow ()
{
    AVPlayer* player;
}
@property (weak) IBOutlet AVPlayerView *playerView;
@property (strong) IBOutlet NSButton *restartBtn;
@property (strong) IBOutlet NSTextField *txtfield;
    
@property (strong) IBOutlet NSTextField *title01;
@property (strong) IBOutlet NSTextField *title02;
    //"Unlock User Privacy" = "Unlock User Privacy";
@end

@implementation PrivacySetupWindow
- (id)init
{
    self = [super initWithWindowNibName:@"PrivacySetupWindow"];
    self.window.backgroundColor = [NSColor whiteColor];
    [self.window center];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName: NSWindowWillCloseNotification
                                                                            object: nil
                                                                             queue: nil
                                                                        usingBlock: ^(NSNotification *note) {
                                                                            [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                            observer = nil;
                                                                            [NSApp terminate:nil];
                                                                        }];

    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"privacysetup" ofType:@"mov"]];

    player = [AVPlayer playerWithURL:videoURL];
    self.playerView.player = player;

    [player play];
        self.playerView.controlsStyle = AVCaptureViewControlsStyleInlineDeviceSelection;
    player.rate = 0.8;
    
    self.txtfield.stringValue = NSLocalizedStringFromTable(@"Finish All Steps", @"Localization", @"");
    [self.restartBtn setTitle: NSLocalizedStringFromTable(@"Relaunch Grid", @"Localization", @"")];
    self.window.title = NSLocalizedStringFromTable(@"Setup Privacy Accessibility", @"Localization", @"");
    
    self.title01.stringValue =  NSLocalizedStringFromTable(@"Unlock User Privacy", @"Localization", @"");
    self.title01.stringValue = [NSString stringWithFormat:@"01. %@", self.title01.stringValue];
    self.title02.stringValue = NSLocalizedStringFromTable(@"Relaunch Grid And See Top Menu", @"Localization", @"");
    self.title02.stringValue = [NSString stringWithFormat:@"02. %@", self.title02.stringValue];
}

- (IBAction)onQuit:(id)sender
{
    [self RelaunchCurrentApp];
    [self.window close];
    //[NSApp terminate:nil];
}

-(void)RelaunchCurrentApp
{
    // Get the path to the current running app executable
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* executablePath = [mainBundle executablePath];
    const char* execPtr = [executablePath UTF8String];
    
#if ATEXIT_HANDLING_NEEDED
    // Get the pid of the parent process
    pid_t originalParentPid = getpid();
    
    // Fork a child process
    pid_t pid = fork();
    if (pid != 0) // Parent process - exit so atexit() is called
    {
        exit(0);
    }
    
    // Now in the child process
    
    // Wait for the parent to die. When it does, the parent pid changes.
    while (getppid() == originalParentPid)
    {
        usleep(250 * 1000); // Wait .25 second
    }
#endif
    
    // Do the relaunch
    execl(execPtr, execPtr, NULL);
}
@end
