//
//  GWinView.h
//  Grid
//
//  Created by ChunTa Chen on 5/6/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GWinView : NSView
@property(nonatomic, copy)NSArray *displayTxtList; // For highlit indicator
@property(nonatomic, copy)NSArray *decoTxtList;    // For backgroundtext indicator
@property(nonatomic, assign)BOOL horizontalSplit3;
-(instancetype)initWithFrame:(NSRect)frameRect Divisor:(NSInteger)divisor;
@end
