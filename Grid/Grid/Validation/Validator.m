//
//  Validator.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/28.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "Validator.h"

#import <IOKit/IOKitLib.h>

#import "ValidationHelper.h"
#import "ValidateReminder.h"
#import "ValidateInputForm.h"

#define INTERVAL_NOT_REGISTER 10
#define INTERVAL_AFTER_SUCCESS 30
static NSDictionary* getCpuIds( void );
static NSString* getPlatformSerialNumber( void );

@interface Validator()<NSAlertDelegate, NSPopoverDelegate, ValidateReminderDelegate, ValidateFormDelegate>
{
    id appdelegate;
    NSMenu *topMenu;
    NSButton *topBtn;
    ValidateReminder *validateReminder;
    ValidateInputForm *validateInputForm;
    NSTimer *validateTimer;
    NSPopover *validatePopover;
}
@end

@implementation Validator
-(instancetype)initWithAppDelegate:(id)aAppDelegate TopBtn:(NSButton*)aTopBtn
{
    self = [super init];
    [self validateByInterval:INTERVAL_NOT_REGISTER];
    appdelegate = aAppDelegate;
    topBtn = aTopBtn;
    return self;
}

- (void)validateByInterval:(NSInteger)aInterval
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (validateTimer)
        {
            [validateTimer invalidate];
            validateTimer = nil;
        }
        validateTimer = [NSTimer scheduledTimerWithTimeInterval:aInterval target:self selector:@selector(validate) userInfo:nil repeats:NO];
    });
}

- (void)validate
{
    /*
    id licenseKey = [[NSUserDefaults standardUserDefaults] objectForKey:kRegistrationKey];
    id email = [[NSUserDefaults standardUserDefaults] objectForKey:kRegistrationMail];
    if (!licenseKey || !email)
    {
        //If no registration code, show alert
        [self showPopOverReminder];
    }
    else
    {
        //If has, validation with website
        NSString *stremail = (NSString*)email;
        NSString *strlicenseKey = (NSString*)licenseKey;
        [self validateWithServerEmail:stremail LicenseKey:strlicenseKey];
    }
    */
}

- (void)validateWithServerEmail:(NSString*)email LicenseKey:(NSString*)licenseKey
{
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/product/validate", kDBURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *post = [NSString stringWithFormat:@"email=%@&licensekey=%@&sno=%@", email, licenseKey, getPlatformSerialNumber()];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];

    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        BOOL hasError = connectionError!=nil;
        if([data length] > 0 && !hasError)
        {
            //收到正確的資料，而且沒有連線錯誤
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *status = [dict objectForKey:@"status"];
            NSString *code = [[dict objectForKey:@"code"] stringValue];
            if (status)
            {
                if ([[status uppercaseString] isEqualToString:@"OK"])
                {
                    [self onRegisterSuccess];
                }
                else
                {
                    if ([code isEqualToString:CODE_LICENSEKEY_INCORRECT])
                    {
                        [self showLicenseInputWindow];
                    }
                    else if([code isEqualToString:CODE_EMAIL_INCORRECT])
                    {
                        [self showLicenseInputWindow];
                    }
                    else if([code isEqualToString:CODE_SNO_MISMATCH])
                    {
                        [self showLicenseInputWindow];
                    }
                    else if([code isEqualToString:CODE_ORDER_ERROR])
                    {
                        [self validateByInterval:INTERVAL_NOT_REGISTER];
                    }
                    else if ([code isEqualToString:CODE_UNKNOWN_ERROR])
                    {
                        [self validateByInterval:INTERVAL_NOT_REGISTER];
                    }
                }
            }
            else
            {
                [self validateByInterval:INTERVAL_NOT_REGISTER];
            }
        }
        else if ( data!=nil && [data length] == 0 && !hasError)
        {
            //沒有資料，而且連線沒錯誤，
            [self validateByInterval:INTERVAL_NOT_REGISTER];
        }
        else
        {
            //連線有錯誤 or 沒網路
            [self validateByInterval:INTERVAL_NOT_REGISTER];
        }
    }];
}

#pragma mark - PopOverDelegate
- (BOOL)popoverShouldClose:(NSPopover *)popover
{
    return YES;
}

#pragma mark - Licenseinput window
- (void)showPopOverReminder
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (validatePopover)
        {
            [validatePopover close];
        }
        if (validateReminder)
        {
            [validateReminder removeFromParentViewController];
        }

        validateReminder = [[ValidateReminder alloc] init];
        validateReminder.delegate = self;
        validatePopover = [[NSPopover alloc] init];
        validatePopover.contentViewController = validateReminder;
        validatePopover.behavior = NSPopoverBehaviorApplicationDefined;
        validatePopover.delegate = self;
        [validatePopover showRelativeToRect:topBtn.bounds ofView:topBtn preferredEdge:NSRectEdgeMaxY];
    });
}

- (void)showLicenseInputWindow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (validatePopover)
        {
            [validatePopover close];
        }
        if (validateReminder)
        {
            [validateReminder removeFromParentViewController];
        }
    
        validateInputForm = [[ValidateInputForm alloc] init];
        validateInputForm.delegate = self;
        validatePopover = [[NSPopover alloc] init];
        validatePopover.contentViewController = validateInputForm;
        validatePopover.behavior = NSPopoverBehaviorApplicationDefined;
        validatePopover.delegate = self;
        [validatePopover showRelativeToRect:topBtn.bounds ofView:topBtn preferredEdge:NSRectEdgeMaxY];
    });
}

#pragma mark - ValidationForm 
- (void)onValidateFormRegisterOK
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [validatePopover close];
        [self onRegisterSuccess];
    });
}

- (void)onValidateFormClose
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [validatePopover close];
        [self validateByInterval:INTERVAL_NOT_REGISTER];
    });
}

#pragma mark - Reminder
- (void)onValidateReminderClkRegister
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [validatePopover close];
        [self showLicenseInputWindow];
    });
}

- (void)onValidateReminderClkBuyLicensekey
{
    NSURL * url = [NSURL URLWithString:@"https://mildgrind.com"];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    [workspace openURL: url];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [validatePopover close];
        [self validateByInterval:INTERVAL_NOT_REGISTER];
    });
}

- (void)onValidateReminderClose
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [validatePopover close];
           [self validateByInterval:INTERVAL_NOT_REGISTER];
    });
}

#pragma mark - Alert
- (void)showAlert:(NSString*)aMsg Info:(NSString*)aInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:aMsg];
        [alert setInformativeText:aInfo];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
    });
}

#pragma mark - Window delegate
- (void)onRegisterSuccess
{
    [self validateByInterval:INTERVAL_AFTER_SUCCESS];
}
- (void)onValidationCancel
{
    [self validateByInterval:INTERVAL_NOT_REGISTER];
}
- (void)onValidateFormExpand:(NSInteger)hValue
{
    NSRect rect = validateInputForm.view.bounds;
    rect.size.height = hValue;
    [validatePopover setContentSize:rect.size];
    validatePopover.animates = YES;
}
@end
