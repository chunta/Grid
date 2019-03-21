//
//  VersionMng.h
//  Grid
//
//  Created by ChunTa Chen on 2017/7/5.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol VersionMngDelegate
- (void)stayInForceUpdate;
@end
@interface VersionMng : NSObject
- (instancetype)initWithTopButton:(NSButton*)top Delegate:(id<VersionMngDelegate>)delegate;
- (BOOL)needForceUpdate;
@end
