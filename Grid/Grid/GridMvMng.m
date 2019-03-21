//
//  GridMvMng.m
//  Grid
//
//  Created by ChunTa Chen on 2017/8/2.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GridMvMng.h"
#import "GWinView.h"
#import "GHelper.h"
#import "LogMng.h"
@implementation GridMvMng
- (void)moveWindow:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode
{
    NSLog(@"KeyCode %ld", keycode);
    
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
    
    NSRect newrect = NSZeroRect;
    if (keycode==43)
    {
        NSLog(@"***** PREV *****");
        NSArray* wlist = [GHelper getScreenSizeList];
        int selindex = -1;
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
                    selindex = i;
                    break;
                }
            }
        }
        if(selindex!=0)
        {
            NSRect current = [[wlist objectAtIndex:selindex] rectValue];
            NSLog(@"Current Display Rect->%@", NSStringFromRect(current));
            float dx = pos.x-current.origin.x;
            float dy = pos.y-current.origin.y;
            float rx = dx/current.size.width;
            float ry = dy/current.size.height;
            float sx = size.width/current.size.width;
            float sy = size.height/current.size.height;
            
            NSRect pre = [[wlist objectAtIndex:--selindex] rectValue];
            NSLog(@"Pre Display Rect->%@", NSStringFromRect(pre));
            NSLog(@"ScaleH:%f RH:%f", sy, sy*pre.size.height);
            
            newrect = NSMakeRect(pre.origin.x+rx*pre.size.width,
                                 ry*pre.size.height,
                                 sx*pre.size.width,
                                 sy*pre.size.height);
            NSLog(@"RY:%f", ry*pre.size.height);
        }
    }
    else if(keycode==47)
    {
        NSLog(@"***** NEXT *****");
        NSArray* wlist = [GHelper getScreenSizeList];
        int selindex = -1;
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
                    selindex = i;
                    break;
                }
            }
        }
        if (selindex>=0 && selindex<(wlist.count-1))
        {
            //Calculate new rect
            NSRect current = [[wlist objectAtIndex:selindex] rectValue];
            NSLog(@"Current Display Rect->%@", NSStringFromRect(current));
            float dx = pos.x-current.origin.x;
            float dy = pos.y-current.origin.y;
            float rx = dx/current.size.width;
            float ry = dy/current.size.height;
            float sx = size.width/current.size.width;
            float sy = size.height/current.size.height;
            
            NSRect next = [[wlist objectAtIndex:++selindex] rectValue];
            NSLog(@"Next Display Rect->%@", NSStringFromRect(next));
            NSLog(@"ScaleH:%f RH:%f", sy, sy*next.size.height);
            
            newrect = NSMakeRect(next.origin.x+rx*next.size.width,
                                 ry*next.size.height,
                                 sx*next.size.width,
                                 sy*next.size.height);
        }
    }
    
    //Set position
    if (NSIsEmptyRect(newrect)==NO)
    {
        //Position && Size
        CGPoint cgorg = newrect.origin;
        CGSize cgsize = newrect.size;
  
        //Set Size
        CFTypeRef sizeref = AXValueCreate(kAXValueCGSizeType, &cgsize);
        AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, sizeref);
        CFRelease(sizeref);
        
        //Set Position
        CFTypeRef orgref = AXValueCreate(kAXValueCGPointType, &cgorg);
        AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, orgref);
        CFRelease(orgref);
        
        //Set Size - Again to make sure we display correct size after positioning
        CFTypeRef fix_sizeref = AXValueCreate(kAXValueCGSizeType, &cgsize);
        AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, fix_sizeref);
        CFRelease(fix_sizeref);
    }

}
@end
