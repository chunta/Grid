//
//  EULAWindow.m
//  Grid
//
//  Created by Chen Rex on 17/10/2017.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import "EULAWindow.h"

@interface EULAWindow ()<NSWindowDelegate>
@property(nonatomic, strong)IBOutlet NSButton *checkbtn;
@property(nonatomic, strong)IBOutlet NSScrollView *enScl;
@property(nonatomic, strong)IBOutlet NSScrollView *tcScl;
@property(nonatomic, strong)IBOutlet NSScrollView *scScl;
@property(nonatomic, strong)IBOutlet NSButton *agrBtn;
@property(nonatomic, strong)IBOutlet NSButton *accBtn;
@property(nonatomic, strong)IBOutlet NSButton *canBtn;
@end

@implementation EULAWindow

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* language = [[languages objectAtIndex:0] uppercaseString];
    if([language containsString:@"ZH-HANT"])
    {
        self.enScl.hidden = YES;
        self.tcScl.hidden = NO;
        self.scScl.hidden = YES;
    }
    else if([language containsString:@"ZH-HANS"])
    {
        self.enScl.hidden = YES;
        self.tcScl.hidden = YES;
        self.scScl.hidden = NO;
    }
    else
    {
        self.enScl.hidden = NO;
        self.tcScl.hidden = YES;
        self.scScl.hidden = YES;
    }
    /* zh-Hant-US, en-US, zh-Hans-US */
    [self.agrBtn setTitle:NSLocalizedStringFromTable(@"CheckEULA", @"Localization", @"")];
    [self.accBtn setTitle:NSLocalizedStringFromTable(@"Accept", @"Localization", @"")];
    [self.canBtn setTitle:NSLocalizedStringFromTable(@"Cancel", @"Localization", @"")];
    
}

- (IBAction)onConfirm:(id)sender
{
    if (self.checkbtn.state == NSControlStateValueOn)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:AGREE_EULA];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.window close];
        });
    }
}

- (IBAction)onCancel:(id)sender
{
    [self.delegate eulawindowClose];
    [self close];
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
    [self.delegate eulawindowClose];
    return true;
}
@end
