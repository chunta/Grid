//
//  GridMng.h
//  Grid
//
//  Created by ChunTa Chen on 2017/5/13.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWinView.h"
#import "GHelper.h"
#import "LogMng.h"
@interface GridMng : NSObject
@property(nonatomic, copy)NSArray *preNums;
- (void)snapWindowSize:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode KeyStr:(NSString*)keystr;
- (void)expandNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode;
- (void)contractNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode;
- (void)showGuidanceWindowByNums:(NSArray*)nums Ref:(CFTypeRef)ref;
- (NSMutableArray*)genIntersectNumsForWinMovement:(NSRect)rect JustSnap:(BOOL*)bjustsnap Ref:(CFTypeRef)ref;
- (void)moveWindow:(CFTypeRef)windowRef Nums:(NSArray*)nums;
- (BOOL)isPreferenceOn:(NSString*)preferenceName;
- (BOOL)twoArrayEqual:(NSArray*)a Another:(NSArray*)b;
@end
