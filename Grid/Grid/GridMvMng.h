//
//  GridMvMng.h
//  Grid
//
//  Created by ChunTa Chen on 2017/8/2.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GridMvMng : NSObject
- (void)moveWindow:(CFTypeRef)windowRef KeyCode:(NSUInteger)keycode;
@end
