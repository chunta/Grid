//
//  UserInfoTextField.m
//  Grid
//
//  Created by Cindy on 2018/1/25.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "UserInfoTextField.h"

@implementation UserInfoTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)showWarning
{
    //self.backgroundColor = [NSColor colorWithRed:1 green:0 blue:0 alpha:0.1];
    self.wantsLayer = YES;
    self.layer.borderColor = [NSColor colorWithRed:1 green:0 blue:0 alpha:0.2].CGColor;
    self.layer.borderWidth = 2;
}

- (void)hideWarning
{
   //self.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.wantsLayer = NO;
}

@end
