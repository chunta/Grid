//
//  NSTextField+HyperLink.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/11.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (HyperLink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end
