//
//  GridToggleWindow.h
//  Grid
//
//  Created by ChunTa Chen on 2017/5/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GridToggleWindow : NSWindowController
-(instancetype)initWithGridType:(int)aType Ref:(CFTypeRef)windowRef;
@end
