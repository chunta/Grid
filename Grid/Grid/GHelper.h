//
//  UHelper.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/17.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHelper : NSObject
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString;
+ (void)colorWithHexColorString:(NSString*)inColorString r:(float*)outr g:(float*)outg b:(float*)outb;
+ (NSString*)modifierConvertToString:(NSInteger)index;

+ (NSArray*)getScreenSizeList;
+ (NSArray*)getUntrimScreenSizeList;

+ (NSArray*)getWindowList;

+ (NSRect)getActiveScreenRectByRef:(CFTypeRef)windowRef;
+ (NSRect)getActiveUntrimScreenRectByRef:(CFTypeRef)windowRef;

+ (NSInteger)getScreenBelongIndex;


@end
