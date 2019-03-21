//
//  EULAView.m
//  Grid
//
//  Created by ChunTa Chen on 2017/8/3.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "EULAView.h"
#import "RFOverlayScrollView.h"
#import "RFOverlayScroller.h"
@interface EULAView ()
@property(nonatomic, strong)IBOutlet RFOverlayScrollView* usscl;
@property(nonatomic, strong)IBOutlet RFOverlayScrollView* tcscl;
@property(nonatomic, strong)IBOutlet RFOverlayScrollView* scscl;
@end

@implementation EULAView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* language = [[languages objectAtIndex:0] uppercaseString];
    if([language containsString:@"ZH-HANT"])
    {
        self.usscl.hidden = YES;
        self.tcscl.hidden = NO;
        self.scscl.hidden = YES;
    }
    else if([language containsString:@"ZH-HANS"])
    {
        self.usscl.hidden = YES;
        self.tcscl.hidden = YES;
        self.scscl.hidden = NO;
    }
    else
    {
        self.usscl.hidden = NO;
        self.tcscl.hidden = YES;
        self.scscl.hidden = YES;
    }
    /* zh-Hant-US, en-US, zh-Hans-US */
}

- (IBAction)onBack:(id)sender
{
    [self.delegate onEULABack];
}

@end
