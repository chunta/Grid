//
//  TintedSegmentedControl.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/15.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "TintedSegmentedControl.h"
#import "TintedSegmentedCell.h"
//@implementation TintedSegmentedControl
//
//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    
//    // Drawing code here.
//}
//
//@end


@implementation TintedSegmentedControl

+ (Class)cellClass
{
    return [TintedSegmentedCell class];
}

@end
