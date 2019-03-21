//
//  GridTextInputFormatter.m
//  Grid
//
//  Created by Cindy on 1/27/18.
//  Copyright © 2018 ChunTa Chen. All rights reserved.
//

#import "GridTextInputFormatter.h"

@implementation GridTextInputFormatter

- (NSString *)stringForObjectValue:(id)obj {
    return obj;
}

- (BOOL)getObjectValue:(__autoreleasing id *)obj
             forString:(NSString *)string
      errorDescription:(NSString *__autoreleasing *)error {
    *obj = string;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing  _Nullable *)newString errorDescription:(NSString *__autoreleasing  _Nullable *)error
{
    for (int i = 0; i < [partialString length]; i++) {
        unichar c = [partialString characterAtIndex:i];
        printf("CCC->%c\n",c);
        //J、K、L、Space and G
        //if (c=='0')return NO;
        if (c==' ')return NO;
        if (c=='g')return NO;
        if (c=='G')return NO;
        if (c=='j')return NO;
        if (c=='J')return NO;
        if (c=='k')return NO;
        if (c=='K')return NO;
        if (c=='l')return NO;
        if (c=='L')return NO;
    }
    
    return YES;
}
@end
