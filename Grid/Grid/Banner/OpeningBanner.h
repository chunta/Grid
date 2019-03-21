//
//  OpeningBanner.h
//  Grid
//
//  Created by ChunTa Chen on 2017/8/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol OpeningBannerDelegate
- (void)didClickOpeningBannerLink;
@end

@interface OpeningBanner : NSViewController
-(instancetype)initImg:(NSImage*)img IsGif:(BOOL)agif Link:(NSString*)url Size:(NSSize)size Del:(id<OpeningBannerDelegate>)delegate;
@end
