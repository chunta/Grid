//
//  Grid2x2Mng.m
//  Grid
//
//  Created by ChunTa Chen on 2017/5/13.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "Grid2x2Mng.h"
#import "GridSetting.h"
@interface Grid2x2Mng()
{
    
}
@end

@implementation Grid2x2Mng
- (void)snapWindowSize:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode KeyStr:(NSString*)keystr
{
    NSLog(@"keycode:%ld", keycode);
    BOOL process = NO;
    if (keycode >= 123 && keycode <= 126)
    {
        process = YES;
        NSLog(@"2x2 expand:%ld", keycode);
        
        /************ LOG ************/
        [LogMng logPressKey:[NSString stringWithFormat:@"%lu", (unsigned long)keycode]];
        /*****************************/
        
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
        
        //If complete snap in one or more cells //
        //1.How much cells intersect current window
        BOOL justsnap = NO;
        NSMutableArray *nums = [self genIntersectNumsForWinMovement:currect JustSnap:&justsnap Ref:windowRef];
        if (justsnap==NO && self.preNums == nil)
        {
            self.preNums = nums;
        }
        //02.Expane nums by keycode
        if (justsnap==NO)
        {
            [self expandNums:nums KeyCode:keycode];
            
            NSArray *sortedArray;
            sortedArray = [nums sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSInteger ia = [a integerValue];
                NSInteger ib = [b integerValue];
                return (ia>ib);
            }];
            
            //Check if we need to do contract
            if (self.preNums)
            {
                if ([self twoArrayEqual:nums Another:self.preNums])
                {
                    //Equal
                    NSLog(@"two array equal ............");
                    [self contractNums:nums KeyCode:keycode];
                }
            }
        }
        
        //Reverse previous
        self.preNums = nums;
        
        //03.Fill visual grid and move window
        NSArray *padnum = [NSArray arrayWithObjects:@"4",@"5",@"1",@"2", nil];
        NSMutableArray *cvtnum = [NSMutableArray new];
        for (NSInteger i = 0; i < nums.count; i++)
        {
            NSString *cvtstr = [padnum objectAtIndex:[[nums objectAtIndex:i] integerValue]];
            [cvtnum addObject:cvtstr];
        }
        [self showGuidanceWindowByNums:cvtnum Ref:windowRef];
        [self moveWindow:windowRef Nums:nums];
        return;
    }

    //Number
    NSInteger num = [keystr integerValue];
    
    //Mapping Custom if possible
    if (windowRef)
    {
        //WindRef--Start--
        if ([[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2])
        {
            NSLog(@"Preference 2x2");
            BOOL found = NO;
            NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2];
            if (list.count==2*2)
            {
                NSArray* convert = [NSArray arrayWithObjects:@"1",@"2",@"4",@"5", nil];
                for (int i = 0; i < list.count; i++)
                {
                    NSString* key = [list objectAtIndex:i];
                    key = [key uppercaseString];
                    keystr = [keystr uppercaseString];
                    if ([keystr isEqualToString:key])
                    {
                        num = [[convert objectAtIndex:i] integerValue];
                        keystr = [NSString stringWithFormat:@"%ld", num];
                        found = YES;
                        break;
                    }
                }
            }
            if (found && (num == 1 || num == 2 || num == 4 || num ==5))
            {
                process = YES;
                
                /************ LOG ************/
                [LogMng logPressKey:[NSString stringWithFormat:@"%ld", num]];
                /*****************************/
                
                self.preNums = nil;
                NSMutableArray *nums = [[NSMutableArray alloc] initWithObjects:keystr, nil];
                [self showGuidanceWindowByNums:nums Ref:windowRef];
                NSArray *padnum = [NSArray arrayWithObjects:@"4",@"5",@"1",@"2", nil];
                NSInteger index = [padnum indexOfObject:keystr];
                [self moveWindow:windowRef Nums:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", index], nil]];
            }
        }
        else if((num == 1 || num == 2 || num == 4 || num ==5))
        {
            NSLog(@"No user preference 2x2 %p",  [[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2]);
            process = YES;
            
            /************ LOG ************/
            [LogMng logPressKey:[NSString stringWithFormat:@"%ld", num]];
            /*****************************/
            
            self.preNums = nil;
            NSMutableArray *nums = [[NSMutableArray alloc] initWithObjects:keystr, nil];
            [self showGuidanceWindowByNums:nums Ref:windowRef];
            NSArray *padnum = [NSArray arrayWithObjects:@"4",@"5",@"1",@"2", nil];
            NSInteger index = [padnum indexOfObject:keystr];
            [self moveWindow:windowRef Nums:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", index], nil]];
        }
        //WindRef--End--
    }
    
    if (process==NO)
    {
        NSLog(@"clean..");
        self.preNums = nil;
    }
}

- (void)expandNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode
{
    /*
     @"0",@"1"
     @"2",@"3"
    */
    if (keycode==125)
    {
        //Down
        NSMutableArray *addition = [NSMutableArray new];
        for (NSInteger i = 0; i < nums.count; i++)
        {
            NSInteger num = [[nums objectAtIndex:i] integerValue];
            num = num + 2;
            if (num > 3)
            {
                continue;
            }
            //Check duplicate
            for (int j = 0; j < nums.count; j++)
            {
                NSString *old = [nums objectAtIndex:j];
                if (num==[old integerValue])
                {
                    break;
                }
            }
            NSString *strindex = [NSString stringWithFormat:@"%ld", (long)num];
            if (NSNotFound==[nums indexOfObject:strindex])
            {
                [addition addObject:strindex];
            }
        }
        [nums addObjectsFromArray:addition];
    }
    else if(keycode==126)
    {
        //Up
        NSMutableArray *addition = [NSMutableArray new];
        for (NSInteger i = 0; i < nums.count; i++)
        {
            NSInteger num = [[nums objectAtIndex:i] integerValue];
            num = num - 2;
            if(num>=0)
            {
                //Check duplicate
                BOOL duplicate = NO;
                for (int j = 0; j < nums.count; j++)
                {
                    NSString *old = [nums objectAtIndex:j];
                    if (num==[old integerValue])
                    {
                        duplicate = YES;
                        break;
                    }
                }
                if (duplicate==NO)
                {
                    [addition addObject:[NSString stringWithFormat:@"%ld", (long)num]];
                }
            }
        }
        [nums addObjectsFromArray:addition];
    }
    else if(keycode==123)
    {
        //Left
        NSMutableArray *addition = [NSMutableArray new];
        for (NSInteger i = 0; i < nums.count; i++)
        {
            NSInteger num = [[nums objectAtIndex:i] integerValue];
            int row = (int)num/2;
            int col = num%2;
            col--;
            if (col < 0)
            {
                continue;
            }
            num = row*2 + col;
            
            //Check duplicate
            for (int j = 0; j < nums.count; j++)
            {
                NSString *old = [nums objectAtIndex:j];
                if (num==[old integerValue])
                {
                    break;
                }
            }
            NSString *strindex = [NSString stringWithFormat:@"%ld", (long)num];
            if (NSNotFound==[nums indexOfObject:strindex])
            {
                [addition addObject:strindex];
            }
        }
        [nums addObjectsFromArray:addition];
    }
    else if(keycode==124)
    {
        //Right
        NSMutableArray *addition = [NSMutableArray new];
        for (NSInteger i = 0; i < nums.count; i++)
        {
            NSInteger num = [[nums objectAtIndex:i] integerValue];
            int row = (int)num/2;
            int col = num%2;
            col++;
            if (col > 1)
            {
                continue;
            }
            num = row*2 + col;
            
            //Check duplicate
            for (int j = 0; j < nums.count; j++)
            {
                NSString *old = [nums objectAtIndex:j];
                if (num==[old integerValue])
                {
                    break;
                }
            }
            NSString *strindex = [NSString stringWithFormat:@"%ld", (long)num];
            if (NSNotFound==[nums indexOfObject:strindex])
            {
                [addition addObject:strindex];
            }
        }
        [nums addObjectsFromArray:addition];
    }
}

- (void)contractNums:(NSMutableArray*)nums KeyCode:(NSUInteger)keycode
{
    /*
     @"0",@"1"
     @"2",@"3"
     */
    if (keycode==125)
    {
        //Down
        NSMutableSet *set = [NSMutableSet setWithArray:nums];
        if ([set containsObject:@"0"] || [set containsObject:@"1"])
        {
            [set removeObject:@"0"];
            [set removeObject:@"1"];
            [nums removeAllObjects];
            [nums addObjectsFromArray:[set allObjects]];
        }
    }
    else if(keycode==126)
    {
        //Up
        NSMutableSet *set = [NSMutableSet setWithArray:nums];
        if ([set containsObject:@"2"] || [set containsObject:@"3"])
        {
            [set removeObject:@"2"];
            [set removeObject:@"3"];
            [nums removeAllObjects];
            [nums addObjectsFromArray:[set allObjects]];
        }
    }
    else if(keycode==123)
    {
        //Left
        NSMutableSet *set = [NSMutableSet setWithArray:nums];
        if ([set containsObject:@"1"] || [set containsObject:@"3"])
        {
            [set removeObject:@"1"];
            [set removeObject:@"3"];
            [nums removeAllObjects];
            [nums addObjectsFromArray:[set allObjects]];
        }
    }
    else if(keycode==124)
    {
        //Right
        NSMutableSet *set = [NSMutableSet setWithArray:nums];
        if ([set containsObject:@"0"] || [set containsObject:@"2"])
        {
            [set removeObject:@"0"];
            [set removeObject:@"2"];
            [nums removeAllObjects];
            [nums addObjectsFromArray:[set allObjects]];
        }
    }
}

- (void)showGuidanceWindowByNums:(NSArray*)nums Ref:(CFTypeRef)ref
{
    if ([self isPreferenceOn:kToggleVisual]==NO)
    {
        return;
    }
    
    NSRect mainDisplayRect = [GHelper getActiveUntrimScreenRectByRef:ref];
    NSWindow *guideWindow = [[NSWindow alloc] initWithContentRect:mainDisplayRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
    GWinView *contentview = [[GWinView alloc] initWithFrame:mainDisplayRect Divisor:2];
    
    //Background text from User preference if necessary
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2])
    {
        contentview.decoTxtList = [[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2];
    }
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

- (void)moveWindow:(CFTypeRef)windowRef Nums:(NSArray*)nums
{
    if([nums count]==0)return;
    
    double divide = 1.0/2.0;
    NSRect vfrm = [GHelper getActiveScreenRectByRef:windowRef];
    float width = vfrm.size.width * divide;
    float height = vfrm.size.height * divide;
    float minx = INT_MAX;
    float miny = INT_MAX;
    float maxw = INT_MIN;
    float maxh = INT_MIN;
    
    for (int i = 0; i < nums.count; i++)
    {
        NSString *str = [nums objectAtIndex:i];
        NSInteger num = [str integerValue];
        int row = (int)num/2;
        int col = num%2;
        float fx = col*width;
        float fy = row*height;
        float fw = fx + width;
        float fh = fy + height;
        if (fx<minx)
        {
            minx = fx;
        }
        if (fy<miny)
        {
            miny = fy;
        }
        if (fw>maxw)
        {
            maxw = fw;
        }
        if (fh>maxh)
        {
            maxh = fh;
        }
    }
    
    //Position && Size
    CGPoint cgorg = CGPointMake(vfrm.origin.x + minx, miny + kTopBarHeight);
    CGSize cgsize = CGSizeMake(maxw-minx, maxh-miny);
    
    //Set Size
    CFTypeRef sizeref = AXValueCreate(kAXValueCGSizeType, &cgsize);
    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, sizeref);
    CFRelease(sizeref);
    
    //Set Position
    CFTypeRef orgref = AXValueCreate(kAXValueCGPointType, &cgorg);
    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, orgref);
    CFRelease(orgref);
    
    //Set Size Again to make sure we display correct size after positioning
    CFTypeRef fix_sizeref = AXValueCreate(kAXValueCGSizeType, &cgsize);
    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, fix_sizeref);
    CFRelease(fix_sizeref);
}

- (NSMutableArray*)genIntersectNumsForWinMovement:(NSRect)rect JustSnap:(BOOL*)bjustsnap Ref:(CFTypeRef)ref
{
    double divide = 1.0/2.0;
    NSRect vfrm = [GHelper getActiveScreenRectByRef:ref];
    float width = vfrm.size.width * divide;
    float height = vfrm.size.height * divide;
    float total_area = width * height;
    NSInteger index = 0;
    NSMutableArray *nums = [NSMutableArray new];
    int total_intersect = 0;
    float total_ratio = 0;
    for (NSInteger row = 0; row < 2; row++)
    {
        for (NSInteger col = 0; col < 2; col++)
        {
            NSRect grid_piece = NSMakeRect(vfrm.origin.x + col*width, row*height + kTopBarHeight, width, height);
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
    }
    
    //Just snap or can expand by keycode
    if (total_intersect * (1-kCellOccupiedAreaRatio) > total_ratio)
    {
        *bjustsnap = YES;
    }
    return nums;
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
