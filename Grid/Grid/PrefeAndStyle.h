//
//  PrefeAndStyle.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/17.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHelper.h"
@interface PrefeAndStyle : NSObject
+(void)borderSelColorInR:(float*)red G:(float*)green B:(float*)blue;
+(void)cellSelColorInR:(float*)red G:(float*)green B:(float*)blue;
+(NSColor*)borderSelColor;
+(NSColor*)cellSelColor;
+(NSInteger)defaultModifier01;
+(NSInteger)defaultModifier02;
@end
