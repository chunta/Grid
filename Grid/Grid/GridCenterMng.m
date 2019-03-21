//
//  GridCenterMng.m
//  Grid
//
//  Created by Cindy on 2018/1/20.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "GridCenterMng.h"
@implementation GridCenterMng
- (void)snapWindowSize:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode KeyStr:(NSString*)keystr
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDisableCenterHotkey];
    if (obj)
    {
        NSLog(@"Disable Center Window");
        return;
    }
    if (windowRef)
    {
        //Pref sync
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:kZeroOrSpaceForCenterWindow];
        if (str==nil)
        {
            str = @"0";
            [[NSUserDefaults standardUserDefaults] setObject:str forKey:kZeroOrSpaceForCenterWindow];
        }
        if ([str isEqualToString:@"Space"])
        {
            str = @" ";
        }
        NSString *lower = [keystr lowercaseString];
        NSLog(@"%@", lower);
        if ([keystr isEqualToString:str])
        {
            [self showGuidanceWindowByNums:@[lower] Ref:windowRef];
            [self moveWindow:windowRef Nums:[NSArray arrayWithObjects:lower, nil]];
            [LogMng logPressKey:keystr];
        }
    }
}

- (void)showGuidanceWindowByNums:(NSArray*)nums Ref:(CFTypeRef)ref
{
    if ([self isPreferenceOn:kToggleVisual]==NO)
    {
        return;
    }
}

- (void)moveWindow:(CFTypeRef)windowRef Nums:(NSArray*)nums
{
    if([nums count]==0)return;
    
    //Get position and size, if rect
    CFTypeRef posref;
    CGPoint pos;
    AXUIElementCopyAttributeValue(windowRef, kAXPositionAttribute, (CFTypeRef *)&posref);
    AXValueGetValue(posref, kAXValueCGPointType, &pos);
    CFTypeRef sizeref;
    CGSize size;
    AXUIElementCopyAttributeValue(windowRef, kAXSizeAttribute, (CFTypeRef *)&sizeref);
    AXValueGetValue(sizeref, kAXValueCGSizeType, &size);
    
    //Form rect
    NSRect rect = NSMakeRect(pos.x, pos.y, size.width, size.height);
    
    //Check which screen
    NSRect curscreen = NSZeroRect;
    NSArray* wlist = [GHelper getScreenSizeList];
    for (int i = 0; i < wlist.count; i++)
    {
        NSRect r = [[wlist objectAtIndex:i] rectValue];
        NSRect inter = NSIntersectionRect(r, rect);
        if (NSIsEmptyRect(inter)==NO)
        {
            NSLog(@"Area:%f", inter.size.width*inter.size.height);
            float area = inter.size.width*inter.size.height;
            if (area >= rect.size.width*rect.size.height*0.12)
            {
                NSLog(@"intersect:%d", i);
                //selindex = i;
                curscreen = r;
                break;
            }
        }
    }
    
    if (NSIsEmptyRect(curscreen))
    {
        NSLog(@"Window size too small or something weired happened");
        return;
    }
    
    float scaleW = kDefault_CenterWindow_Scale_W;
    float scaleH = kDefault_CenterWindow_Scale_H;
    
    int slideW = kDefault_Slider_W;
    int slideH = kDefault_Slider_H;
    
    //Synchornize
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreW] && [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreH])
    {
        NSString* w = [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreW];
        slideW = [w intValue];
        
        NSString* h = [[NSUserDefaults standardUserDefaults] objectForKey:kCenterPreH];
        slideH = [h intValue];
        NSLog(@"W:%d H:%d", slideW, slideH);
    }
    int rw = kDefault_CenterWindow_Scale_W*100 - kCenterWindow_AvailableValueToScaleDown * (1-(slideW / 100.0));
    int rh = kDefault_CenterWindow_Scale_H*100 - kCenterWindow_AvailableValueToScaleDown * (1-(slideH / 100.0));
    scaleW = rw / 100.0;
    scaleH = rh / 100.0;
    NSLog(@"rw:%d rh:%d", rw, rh);
    NSLog(@"sw:%f sh:%f", scaleW, scaleH);

    NSRect vfrm = [GHelper getActiveScreenRectByRef:windowRef];
    vfrm = curscreen;
    float width = vfrm.size.width * scaleW;
    float height = vfrm.size.height * scaleH;
    float marginx = vfrm.origin.x + (vfrm.size.width - width) * 0.5;
    float marginy = vfrm.origin.y + (vfrm.size.height - height) * 0.5;
    
    //Position && Size
    CGPoint cgorg = CGPointMake(marginx,  marginy + kTopBarHeight);
    CGSize cgsize = CGSizeMake(width, height);
    
    //Set Size
    CFTypeRef sizeref_ = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&cgsize));
    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, sizeref_);
    CFRelease(sizeref);
    
    //Set Position
    CFTypeRef orgref = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&cgorg));
    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, orgref);
    CFRelease(orgref);
    
    //Set Size Again to make sure we display correct size after positioning
    CFTypeRef fix_sizeref = AXValueCreate(kAXValueCGSizeType, &cgsize);
    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, fix_sizeref);
    CFRelease(fix_sizeref);

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
