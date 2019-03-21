//
//  SettingTxtFormat.m
//  Grid
//
//  Created by Cindy on 2018/1/24.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "SettingTxtFormat.h"

@implementation SettingTxtFormat

- (id)init {
    
    if(self = [super init]){
        
        maxLength = INT_MAX;
    }
    
    return self;
}

- (void)setMaximumLength:(int)len {
    maxLength = len;
}

- (int)maximumLength {
    return maxLength;
}

- (NSString *)stringForObjectValue:(id)object {
    return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
    *object = string;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error
{
    NSUInteger size = [*partialStringPtr length];
    if ( size > maxLength ) {
        if (origSelRange.location == [origString length]) {
            // 如果修改的位置在原来字符串的最后，则不做修改，只是拒绝内容修改
        } else {
            // 如果修改的位置在原来字符串的中间，就根据剩余的可用的长度把新增加的字符串进行截取
            NSUInteger preLen = origSelRange.location + (maxLength - [origString length]) + origSelRange.length;
            *partialStringPtr = [NSString stringWithFormat:@"%@%@",
                                 [*partialStringPtr substringToIndex:preLen],
                                 [origString substringFromIndex:origSelRange.location+origSelRange.length]];
            
            (*proposedSelRangePtr).location = preLen;
        }
        
        return NO;
    }
    return YES;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
    return nil;
}

@end
