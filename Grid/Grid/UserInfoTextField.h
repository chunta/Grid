//
//  UserInfoTextField.h
//  Grid
//
//  Created by Cindy on 2018/1/25.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UserInfoTextField : NSTextField
@property(nonatomic,strong)NSTextField* next;
- (void)showWarning;
- (void)hideWarning;
@end
