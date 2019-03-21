//
//  GridJKLMng.m
//  Grid
//
//  Created by ChunTa Chen on 2017/7/12.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridFullScreenMng.h"
#import "GHelper.h"

@implementation GridFullScreenMng
- (void)snapWindowSize:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode KeyStr:(NSString*)keystr
{
    if (windowRef)
    {
        NSString *lower = [keystr lowercaseString];
        NSLog(@"ENTER:%@", lower);
        if([lower isEqualToString:@"enter"] || [lower isEqualToString:@"[return]"])
        {
            //[self showGuidanceWindowByNums:@[lower] Ref:windowRef];
            [self moveWindow:windowRef Nums:[NSArray arrayWithObjects:lower, nil]];
        }
    }
}

- (void)expandNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode
{

}

- (void)showGuidanceWindowByNums:(NSArray*)nums Ref:(CFTypeRef)ref
{
    if ([self isPreferenceOn:kToggleVisual]==NO)
    {
        return;
    }
    
    NSRect mainDisplayRect = [GHelper getActiveUntrimScreenRectByRef:ref];
    NSWindow *guideWindow = [[NSWindow alloc] initWithContentRect:mainDisplayRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
    GWinView *contentview = [[GWinView alloc] initWithFrame:mainDisplayRect Divisor:3];
    contentview.horizontalSplit3 = YES;
    contentview.displayTxtList = nums;
    
    [contentview setNeedsDisplay:YES];
    [guideWindow setContentView: contentview];
    [guideWindow setOpaque:NO];
    [guideWindow setBackgroundColor:[NSColor clearColor]];
    [guideWindow setLevel:NSStatusWindowLevel];
    [guideWindow makeKeyAndOrderFront:nil];
    [guideWindow setAlphaValue:0];
    [guideWindow setReleasedWhenClosed:YES];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = kGuideShowDuration;
        guideWindow.animator.alphaValue = 1;
    } completionHandler:^{
        [guideWindow orderOut:nil];
    }];
}

- (NSMutableArray*)genIntersectNumsForWinMovement:(NSRect)rect JustSnap:(BOOL*)bjustsnap Ref:(CFTypeRef)ref
{
    double divide = 1.0/3.0;
    NSRect vfrm = [GHelper getActiveScreenRectByRef:ref];
    float width = vfrm.size.width * divide;
    float height = vfrm.size.height * 1;
    float total_area = width * height;
    NSInteger index = 0;
    NSMutableArray *nums = [NSMutableArray new];
    int total_intersect = 0;
    float total_ratio = 0;
  
    for (NSInteger col = 0; col < 3; col++)
    {
        NSRect grid_piece = NSMakeRect(vfrm.origin.x + col*width, height + kTopBarHeight, width, height);
        NSRect interrect = NSIntersectionRect(grid_piece, rect);
        //If intersect and intersect area is not too small
        float area = floorf(interrect.size.width)*floorf(interrect.size.height);
        float ratio = area / total_area;
        if (NO==NSIsEmptyRect(interrect) && ratio > kCellOccupiedAreaRatio)
        {
            [nums addObject:[NSString stringWithFormat:@"%ld", (long)index]];
            total_intersect++;
            total_ratio += ratio;
        }
        index++;
    }
    
    //Just snap or can expand by keycode
    if (total_intersect * (1-kCellOccupiedAreaRatio) > total_ratio)
    {
        *bjustsnap = YES;
    }
    return nums;
}

- (void)moveWindow:(CFTypeRef)windowRef Nums:(NSArray*)nums
{
    if([nums count]==0)return;
    
    //double divide = 1.0/3.0;
    NSRect vfrm = [GHelper getActiveScreenRectByRef:windowRef];

    float minx = 0;
    float miny = 0;
    float maxw = vfrm.size.width;
    float maxh = vfrm.size.height;
    
    //Position && Size
    CGPoint cgorg = CGPointMake(vfrm.origin.x + minx, miny + kTopBarHeight);
    CGSize cgsize = CGSizeMake(maxw-minx, maxh-miny);
    
    //Set Position
    CFTypeRef orgref = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&cgorg));
    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, orgref);
    CFRelease(orgref);
    
    //Set Size
    CFTypeRef sizeref = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&cgsize));
    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, sizeref);
    CFRelease(sizeref);
}
- (BOOL)isPreferenceOn:(NSString*)preferenceName
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:preferenceName];
    if (obj==nil)
    {
        return NO;
    }
    NSString *str = obj;
    if ([str integerValue]==1)
    {
        return YES;
    }
    return NO;
}
@end
