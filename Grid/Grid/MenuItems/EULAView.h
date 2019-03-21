//
//  EULAView.h
//  Grid
//
//  Created by ChunTa Chen on 2017/8/3.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol EULAViewDelegate
- (void)onEULABack;
@end
@interface EULAView : NSViewController
@property(nonatomic, weak)id<EULAViewDelegate> delegate;
@end
