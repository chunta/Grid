//
//  GTextField.m
//  Grid
//
//  Created by ChunTa Chen on 5/6/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import "GTextField.h"
#import "GTextFieldCell.h"
@implementation GTextField

+(Class)cellClass
{
    return [GTextFieldCell class];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
}

@end
