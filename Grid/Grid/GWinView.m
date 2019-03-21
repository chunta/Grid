//
//  GWinView.m
//  Grid
//
//  Created by ChunTa Chen on 5/6/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import "GWinView.h"
#import "GTextField.h"
#import "PrefeAndStyle.h"
@interface GWinView()
{
    NSRect indicatorRect;
    NSMutableArray *indicatorRects;
    NSInteger divisor;
}
@end

@implementation GWinView
-(instancetype)initWithFrame:(NSRect)frameRect Divisor:(NSInteger)adivisor
{
    self = [super initWithFrame:frameRect];
    self->divisor = adivisor;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here. blur curtain
    [[NSColor colorWithRed:0 green:0 blue:1 alpha:0.13] set];
    NSRectFill(dirtyRect);
    
    NSGraphicsContext *ctxt = [NSGraphicsContext currentContext];
    CGContextRef ctxtref = (CGContextRef)[ctxt graphicsPort];
    
    //View Size
    CGRect rect = self.frame;
    if (indicatorRects && indicatorRects.count)
    {
        float red = 0; float green = 0; float blue = 0;
        [PrefeAndStyle cellSelColorInR:&red G:&green B:&blue];
        [[NSColor colorWithRed:red green:green blue:blue alpha:0.8] set];
        for (NSInteger i = 0; i < indicatorRects.count; i++)
        {
            NSRect rect = [[indicatorRects objectAtIndex:i] rectValue];
            NSRectFill(rect);
        }
    }
    else if(NSIsEmptyRect(indicatorRect)==NO)
    {
        [[NSColor colorWithRed:100.0/255 green:167.0/255 blue:219.0/255 alpha:0.8] set];
        NSRectFill(indicatorRect);
    }
    
    //Draw Grid Line
    float red = 0; float green = 0; float blue = 0;
    [PrefeAndStyle borderSelColorInR:&red G:&green B:&blue];
    CGContextSetRGBStrokeColor(ctxtref, red, green, blue, 1);
    CGContextSetLineWidth(ctxtref, kGuideLineWidth);
    CGContextBeginPath(ctxtref);
    if (self.horizontalSplit3)
    {
        //Vertical
        CGContextMoveToPoint(ctxtref, rect.size.width/3, 0);
        CGContextAddLineToPoint(ctxtref, rect.size.width/3, rect.size.height);
        CGContextMoveToPoint(ctxtref, rect.size.width/3*2, 0);
        CGContextAddLineToPoint(ctxtref, rect.size.width/3*2, rect.size.height);
        CGContextDrawPath(ctxtref, kCGPathStroke);
        return;
    }
    if (divisor==3)
    {
        //Horizontal
        CGContextMoveToPoint(ctxtref, rect.origin.x, rect.size.height/3);
        CGContextAddLineToPoint(ctxtref, rect.size.width, rect.size.height/3);
        CGContextMoveToPoint(ctxtref, rect.origin.x, rect.size.height/3*2);
        CGContextAddLineToPoint(ctxtref, rect.size.width, rect.size.height/3*2);
        //Vertical
        CGContextMoveToPoint(ctxtref, rect.size.width/3, 0);
        CGContextAddLineToPoint(ctxtref, rect.size.width/3, rect.size.height);
        CGContextMoveToPoint(ctxtref, rect.size.width/3*2, 0);
        CGContextAddLineToPoint(ctxtref, rect.size.width/3*2, rect.size.height);
        CGContextDrawPath(ctxtref, kCGPathStroke);
    }
    else
    {
        //Horizontal
        CGContextMoveToPoint(ctxtref, rect.origin.x, rect.size.height/2);
        CGContextAddLineToPoint(ctxtref, rect.size.width, rect.size.height/2);
        //Vertical
        CGContextMoveToPoint(ctxtref, rect.size.width/2, 0);
        CGContextAddLineToPoint(ctxtref, rect.size.width/2, rect.size.height);
        CGContextDrawPath(ctxtref, kCGPathStroke);
    }
}

- (void)setDisplayTxtList:(NSArray *)displayTxtList
{
    indicatorRects = [NSMutableArray new];
    float tw = self.frame.size.width/divisor;
    float th = self.frame.size.height/divisor;
    
    //JKL---
    if (self.horizontalSplit3)
    {
        tw = self.frame.size.width/3;
        th = self.frame.size.height;
        for (NSInteger i = 0; i < displayTxtList.count; i++)
        {
            NSString *txt = [displayTxtList objectAtIndex:i];
            if ([[txt lowercaseString] isEqualToString:@"j"])
            {
                NSRect rect = NSMakeRect(0, 0, tw, th);
                [indicatorRects addObject:[NSValue valueWithRect:rect]];
            }
            else if ([[txt lowercaseString] isEqualToString:@"k"])
            {
                NSRect rect = NSMakeRect(tw, 0, tw, th);
                [indicatorRects addObject:[NSValue valueWithRect:rect]];
            }
            else if ([[txt lowercaseString] isEqualToString:@"l"])
            {
                NSRect rect = NSMakeRect(2*tw, 0, tw, th);
                [indicatorRects addObject:[NSValue valueWithRect:rect]];
            }
        }
        
        //J K L
        NSArray *txts = @[@"J", @"K", @"L"];
        for (int t = 0; t < txts.count; t++)
        {
            GTextField *textField;
            textField = [[GTextField alloc] initWithFrame:NSMakeRect(tw*t, 0, tw, th)];
            [textField setFont:[NSFont boldSystemFontOfSize:kGuideTxtSize]];
            [textField setTextColor:[NSColor whiteColor]];
            [textField setStringValue:[txts objectAtIndex:t]];
            [textField setBezeled:NO];
            [textField setDrawsBackground:YES];
            [textField setEditable:NO];
            [textField setSelectable:NO];
            [textField setAlignment:NSTextAlignmentCenter];
            [textField.cell setUsesSingleLineMode:YES];
            [textField setBackgroundColor:[NSColor clearColor]];
            [self addSubview:textField];
        }
        return;
    }
    //------
    
    if (divisor==3)
    {
        for (NSInteger i = 0; i < displayTxtList.count; i++)
        {
            NSString *txt = [displayTxtList objectAtIndex:i];
            NSInteger num = [txt integerValue]-1;
            int row = (int)num/divisor;
            int col = num%(int)divisor;
            NSRect rect = NSMakeRect(col*tw, row*th, tw, th);
            [indicatorRects addObject:[NSValue valueWithRect:rect]];
        }
    
        //From 1 ~ 9
        int inditxt = 1;
        for (int row = 0; row < divisor; row++)
        {
            for (int col = 0; col < divisor; col++)
            {
                GTextField *textField;
                textField = [[GTextField alloc] initWithFrame:NSMakeRect(col*tw, row*th, tw, th)];
                [textField setFont:[NSFont boldSystemFontOfSize:kGuideTxtSize]];
                [textField setTextColor:[NSColor whiteColor]];
                if (self.decoTxtList && self.decoTxtList.count == 9)
                {
                    [textField setStringValue:[self.decoTxtList objectAtIndex:inditxt-1]];
                }
                else
                {
                   [textField setStringValue:[NSString stringWithFormat:@"%d",inditxt]];
                }
                [textField setBezeled:NO];
                [textField setDrawsBackground:YES];
                [textField setEditable:NO];
                [textField setSelectable:NO];
                [textField setAlignment:NSTextAlignmentCenter];
                [textField.cell setUsesSingleLineMode:YES];
                [textField setBackgroundColor:[NSColor clearColor]];
                [self addSubview:textField];
                inditxt++;
            }
        }
    }
    else
    {
        for (NSInteger i = 0; i < displayTxtList.count; i++)
        {
            NSString *txt = [displayTxtList objectAtIndex:i];
            NSInteger num = [txt integerValue];
            int row = 0;
            int col = 0;
            if (num!=1 && num!=2 && num!=4 && num!=5)continue;
            if (num==1)
            {
                row = 0;
                col = 0;
            }
            else if (num==2)
            {
                row = 0;
                col = 1;
            }
            else if (num==4)
            {
                row = 1;
                col = 0;
            }
            else if (num==5)
            {
                row = 1;
                col = 1;
            }
            NSRect rect = NSMakeRect(col*tw, row*th, tw, th);
            [indicatorRects addObject:[NSValue valueWithRect:rect]];
        }
        
        //From 1, 2, 4, 5
        NSArray *txtlist = [NSArray arrayWithObjects:@"1",@"2",@"4",@"5", nil];
        for (NSInteger i = 0; i < txtlist.count; i++)
        {
            NSString *txt = [txtlist objectAtIndex:i];
            NSInteger num = [txt integerValue];
            int row = 0;
            int col = 0;
            if (num!=1 && num!=2 && num!=4 && num!=5)continue;
            if (num==1)
            {
                row = 0;
                col = 0;
            }
            else if (num==2)
            {
                row = 0;
                col = 1;
            }
            else if (num==4)
            {
                row = 1;
                col = 0;
            }
            else if (num==5)
            {
                row = 1;
                col = 1;
            }
            GTextField *textField;
            textField = [[GTextField alloc] initWithFrame:NSMakeRect(col*tw, row*th, tw, th)];
            [textField setFont:[NSFont boldSystemFontOfSize:kGuideTxtSize]];
            [textField setTextColor:[NSColor whiteColor]];
            if (self.decoTxtList && self.decoTxtList.count == 4)
            {
                [textField setStringValue:[self.decoTxtList objectAtIndex:row*2+col]];
            }
            else
            {
               [textField setStringValue:[NSString stringWithFormat:@"%ld",num]];
            }
            [textField setBezeled:NO];
            [textField setDrawsBackground:YES];
            [textField setEditable:NO];
            [textField setSelectable:NO];
            [textField setAlignment:NSTextAlignmentCenter];
            [textField.cell setUsesSingleLineMode:YES];
            [textField setBackgroundColor:[NSColor clearColor]];
            [self addSubview:textField];
        }
    }
}
@end
