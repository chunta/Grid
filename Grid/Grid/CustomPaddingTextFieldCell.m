//
//  CustomPaddingTextFieldCell.m
//  Grid
//
//  Created by Cindy on 2018/1/25.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "CustomPaddingTextFieldCell.h"

@implementation CustomPaddingTextFieldCell
-(NSRect)drawingRectForBounds:(NSRect)rect
{
    NSRect rectInset = NSMakeRect(rect.origin.x, rect.origin.y + _topPadding, rect.size.width, rect.size.height - _topPadding);
    return [super drawingRectForBounds:rectInset];
}
@end
