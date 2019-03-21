//
//  UHelper.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/17.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "GHelper.h"

@implementation GHelper
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}

+ (void)colorWithHexColorString:(NSString*)inColorString r:(float*)outr g:(float*)outg b:(float*)outb
{
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    (*outr) = (float)redByte / 0xff;
    (*outg) = (float)greenByte / 0xff;
    (*outb) = (float)blueByte / 0xff;
}

+ (NSArray*)getScreenSizeList
{
    NSMutableArray* list = [NSMutableArray new];
    NSRect screenRect;
    NSArray *screenArray = [NSScreen screens];
    NSUInteger screenCount = [screenArray count];
    NSInteger index  = 0;
    for (index = 0; index < screenCount; index++)
    {
        NSScreen *screen = [screenArray objectAtIndex: index];
        screenRect = [screen visibleFrame];
        screenRect.origin.y = 0;
        [list addObject:[NSValue valueWithRect:screenRect]];
    }
    return list;
}

+ (NSArray*)getUntrimScreenSizeList
{
    NSMutableArray* list = [NSMutableArray new];
    NSRect screenRect;
    NSArray *screenArray = [NSScreen screens];
    NSUInteger screenCount = [screenArray count];
    NSInteger index  = 0;
    for (index = 0; index < screenCount; index++)
    {
        NSScreen *screen = [screenArray objectAtIndex: index];
        screenRect = [screen visibleFrame];
        [list addObject:[NSValue valueWithRect:screenRect]];
    }
    return list;
}

+ (NSInteger)getScreenBelongIndex
{
    NSRect screenRect;
    NSArray *screenArray = [NSScreen screens];
    NSUInteger screenCount = [screenArray count];
    
    //Mouse location
    NSPoint mouseLoc;
    mouseLoc = [NSEvent mouseLocation];
    
    for (NSUInteger index = 0; index < screenCount; index++)
    {
        NSScreen *screen = [screenArray objectAtIndex: index];
        screenRect = [screen visibleFrame];
        if(NSPointInRect(mouseLoc, screenRect))
        {
            return index;
        }
    }
    return 0;
}

+ (NSString*)modifierConvertToString:(NSInteger)index
{
    NSAssert(index<4, @"Modifier out of index");
    uint64_t m = GModifier[index];
    switch (m) {
        case kCGEventFlagMaskControl:
            return @"⌃ Ctrl";
        case kCGEventFlagMaskCommand:
            return @"⌘ Cmd";
        case kCGEventFlagMaskAlternate:
            return @"⌥ Opt";
        case kCGEventFlagMaskShift:
            return @"⇧ Shift";
        default:
            break;
    }
    return @"Undefine";
}

+ (NSRect)getActiveScreenRect
{
    NSInteger index = [self getScreenBelongIndex];
    return [[[self getScreenSizeList] objectAtIndex:index] rectValue];
}

+ (NSRect)getActiveUntrimScreenRect
{
    NSInteger index = [self getScreenBelongIndex];
    return [[[self getUntrimScreenSizeList] objectAtIndex:index] rectValue];
}

+ (NSRect)getActiveScreenRectByRef:(CFTypeRef)windowRef
{
    NSArray* list = [GHelper getScreenSizeList];
    if (windowRef==nil)
    {
        return [[list objectAtIndex:0] rectValue];
    }

    if (kActiveScreenByCursorLoc)
    {
        return [self getActiveScreenRect];
    }
    
    //Get position and size, if rect
    CFTypeRef posref;
    CGPoint pos;
    AXUIElementCopyAttributeValue(windowRef, kAXPositionAttribute, (CFTypeRef *)&posref);
    AXValueGetValue(posref, kAXValueCGPointType, &pos);
    CFTypeRef sizeref;
    CGSize size;
    AXUIElementCopyAttributeValue(windowRef, kAXSizeAttribute, (CFTypeRef *)&sizeref);
    AXValueGetValue(sizeref, kAXValueCGSizeType, &size);
    
    //Current rect
    NSRect currect = NSMakeRect(pos.x, pos.y, size.width, size.height);
    float carea = currect.size.width * currect.size.height;
    int selindex = 0;
    
    
    for (int i = 0; i < list.count; i++)
    {
        NSRect rect = [[list objectAtIndex:i] rectValue];
        rect.origin.y = 0;
        if (NSIntersectsRect(currect, rect))
        {
            NSRect intersect = NSIntersectionRect(currect, rect);
            float interarea = intersect.size.width * intersect.size.height;
            if (interarea>=carea*0.5)
            {
                selindex = i;
            }
        }
    }
    
    return [[list objectAtIndex:selindex] rectValue];
}

+ (NSRect)getActiveUntrimScreenRectByRef:(CFTypeRef)windowRef
{
    NSArray* list = [GHelper getUntrimScreenSizeList];
    if (windowRef==nil)
    {
        return [[list objectAtIndex:0] rectValue];
    }
    
    if (kActiveScreenByCursorLoc)
    {
        return [self getActiveUntrimScreenRect];
    }
    
    //Get position and size, if rect
    CFTypeRef posref;
    CGPoint pos;
    AXUIElementCopyAttributeValue(windowRef, kAXPositionAttribute, (CFTypeRef *)&posref);
    AXValueGetValue(posref, kAXValueCGPointType, &pos);
    CFTypeRef sizeref;
    CGSize size;
    AXUIElementCopyAttributeValue(windowRef, kAXSizeAttribute, (CFTypeRef *)&sizeref);
    AXValueGetValue(sizeref, kAXValueCGSizeType, &size);
    
    //Current rect
    NSRect currect = NSMakeRect(pos.x, pos.y, size.width, size.height);
    float carea = currect.size.width * currect.size.height;
    int selindex = 0;
    
    
    for (int i = 0; i < list.count; i++)
    {
        NSRect rect = [[list objectAtIndex:i] rectValue];
        rect.origin.y = 0;
        if (NSIntersectsRect(currect, rect))
        {
            NSRect intersect = NSIntersectionRect(currect, rect);
            float interarea = intersect.size.width * intersect.size.height;
            if (interarea>=carea*0.5)
            {
                selindex = i;
            }
        }
    }
    
    return [[list objectAtIndex:selindex] rectValue];
}
/*
+ (NSArray*)getWindowList
{
    NSMutableArray *titles = [NSMutableArray new];
    
    AXUIElementRef _systemWide = AXUIElementCreateSystemWide();
    CFArrayRef attrList;
    if (AXUIElementCopyAttributeNames(_systemWide, &attrList) == kAXErrorSuccess)
    {
        CFTypeRef focusApp;
        if (AXUIElementCopyAttributeValue(_systemWide, kAXFocusedApplicationAttribute, &focusApp) == kAXErrorSuccess)
        {
            CFTypeRef focusWin;
            if (AXUIElementCopyAttributeValue(focusApp, kAXFocusedWindowAttribute, &focusWin) == kAXErrorSuccess)
            {
                CFStringRef titleRef;
                if (AXUIElementCopyAttributeValue(focusWin, kAXTitleAttribute, (CFTypeRef *)&titleRef) == kAXErrorSuccess)
                {
                    NSString *title = (__bridge NSString *)titleRef;
                    NSLog(@"Active window name is:%@", title);
                    [titles addObject:title];
                }
                if (AXUIElementCopyAttributeValue(focusWin, kAXRoleDescriptionAttribute, (CFTypeRef *)&titleRef) == kAXErrorSuccess)
                {
                    NSString *title = (__bridge NSString *)titleRef;
                    NSLog(@"Active window kAXRoleDescriptionAttribute is:%@", title);
                    if ([title containsString:@"popover"] || [title containsString:@"彈出"])
                    {
                        return nil;
                    }
                }
                return focusWin;
            }
        }
    }
    return nil;
}*/
@end
