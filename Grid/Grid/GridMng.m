//
//  GridMng.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/13.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridMng.h"
#import "GridJKLMng.h"
@interface GridMng()
{
    
}
@end
@implementation GridMng
- (void)snapWindowSize:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode KeyStr:(NSString*)keystr
{

}

- (void)expandNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode
{
    
}

- (void)contractNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode
{
    
}

- (void)showGuidanceWindowByNums:(NSArray*)nums Ref:(CFTypeRef)ref
{
    
}

- (NSMutableArray*)genIntersectNumsForWinMovement:(NSRect)rect JustSnap:(BOOL*)bjustsnap Ref:(CFTypeRef)ref
{
    return nil;
}

- (void)moveWindow:(CFTypeRef)windowRef Nums:(NSArray*)nums
{
    
}

- (BOOL)isPreferenceOn:(NSString*)preferenceName
{
    return YES;
}

- (BOOL)twoArrayEqual:(NSArray*)a Another:(NSArray*)b
{
    NSSet *set1 = [NSSet setWithArray:a];
    NSSet *set2 = [NSSet setWithArray:b];
    if ([set1 isEqualToSet:set2])
    {
        return YES;
    }
    return NO;
}
@end
