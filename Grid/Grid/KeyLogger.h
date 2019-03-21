//
//  KeyLogger.h
//  Grid
//
//  Created by ChunTa Chen on 2017/5/20.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol KeyLoggerDelegate
- (void)validInput:(NSUInteger)aKeyCode Str:(NSString*)aStr;
@end
@interface KeyLogger : NSObject
@property(nonatomic, weak)id<KeyLoggerDelegate> delegate;
- (instancetype)initWithDelegate:(id<KeyLoggerDelegate>)delegate;
- (bool)isModifierPressed;
@end
