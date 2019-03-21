//
//  GridEdgeDragMng.h
//  Grid
//
//  Created by Cindy on 2017/12/28.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyLogger.h"
@interface GridEdgeDragMng : NSObject
- (instancetype)initWithKeyLogger:(KeyLogger*)logger;
-(void)start;
@end
