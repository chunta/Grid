//
//  PrefeAndStyle.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/17.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "PrefeAndStyle.h"
@implementation PrefeAndStyle
+(void)borderSelColorInR:(float*)red G:(float*)green B:(float*)blue
{
    NSString *bindex = [[NSUserDefaults standardUserDefaults] objectForKey:kBorderSelectIndex];
    if (bindex==nil)
    {
        bindex = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:bindex forKey:kBorderSelectIndex];
    }
    NSInteger index = [bindex integerValue];
    [GHelper colorWithHexColorString:BorderColorsRepo[index] r:red g:green b:blue];
}

+(void)cellSelColorInR:(float*)red G:(float*)green B:(float*)blue
{
    NSString *bindex = [[NSUserDefaults standardUserDefaults] objectForKey:kCellSelectIndex];
    if (bindex==nil)
    {
        bindex = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:bindex forKey:kCellSelectIndex];
    }
    NSInteger index = [bindex integerValue];
    [GHelper colorWithHexColorString:CellColorsRepo[index] r:red g:green b:blue];
}

+(NSColor*)borderSelColor
{
    NSString *bindex = [[NSUserDefaults standardUserDefaults] objectForKey:kBorderSelectIndex];
    if (bindex==nil)
    {
        bindex = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:bindex forKey:kCellSelectIndex];
    }
    NSString* hex = BorderColorsRepo[[bindex integerValue]];
    return [GHelper colorWithHexColorString:hex];
}

+(NSColor*)cellSelColor
{
    NSString *bindex = [[NSUserDefaults standardUserDefaults] objectForKey:kCellSelectIndex];
    if (bindex==nil)
    {
        bindex = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:bindex forKey:kCellSelectIndex];
    }
    NSString* hex = BorderColorsRepo[[bindex integerValue]];
    return [GHelper colorWithHexColorString:hex];
}

+(NSInteger)defaultModifier01
{
    return 0; // kCGEventFlagMaskControl
}

+(NSInteger)defaultModifier02
{
    return 2; // - kCGEventFlagMaskAlternate
}
@end
