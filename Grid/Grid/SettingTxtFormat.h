//
//  SettingTxtFormat.h
//  Grid
//
//  Created by Cindy on 2018/1/24.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingTxtFormat : NSFormatter {
    int maxLength;
}
- (void)setMaximumLength:(int)len;
- (int)maximumLength;

@end
