//
//  ValidateForm.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/5.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol ValidateReminderDelegate
- (void)onValidateReminderClkRegister;
- (void)onValidateReminderClkBuyLicensekey;
- (void)onValidateReminderClose;
@end

@interface ValidateReminder : NSViewController

@property(nonatomic, weak)id<ValidateReminderDelegate> delegate;
@end
