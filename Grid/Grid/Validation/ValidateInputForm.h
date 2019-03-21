//
//  ValidateInputForm.h
//  Grid
//
//  Created by nmi on 2017/6/7.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ValidateFormDelegate
- (void)onValidateFormRegisterOK;
- (void)onValidateFormClose;
- (void)onValidateFormExpand:(NSInteger)hValue;
@end

@interface ValidateInputForm : NSViewController
@property(nonatomic, weak)id<ValidateFormDelegate> delegate;
@end
