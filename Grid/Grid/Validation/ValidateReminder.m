//
//  ValidateForm.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/5.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "ValidateReminder.h"
#define CD 10
@interface ValidateReminder ()
@property(nonatomic, assign)NSInteger iCD;
@property(nonatomic, strong)NSTimer *cdTimer;
@property(nonatomic, strong)IBOutlet NSTextField *cdTxt;
@end

@implementation ValidateReminder
-(IBAction)onBuyLicense:(id)sender
{
    [self.delegate onValidateReminderClkBuyLicensekey];
}

- (IBAction)onRegister:(id)sender
{
    [self.cdTimer invalidate];
    self.cdTimer = nil;
    
    [self.delegate onValidateReminderClkRegister];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.iCD = CD;
    [self.cdTxt setStringValue:[NSString stringWithFormat:@"%ld", (long)self.iCD]];
    self.cdTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(validateImp) userInfo:nil repeats:YES];
}

- (void)validateImp
{
    self.iCD--;
    [self.cdTxt setStringValue:[NSString stringWithFormat:@"%.02ld", (long)self.iCD]];
    if (self.iCD==0)
    {
        [self.delegate onValidateReminderClose];
        [self.cdTimer invalidate];
        self.cdTimer = nil;
    }
}
@end
