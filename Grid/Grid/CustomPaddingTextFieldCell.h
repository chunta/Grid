//
//  CustomPaddingTextFieldCell.h
//  Grid
//
//  Created by Cindy on 2018/1/25.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomPaddingTextFieldCell : NSTextFieldCell
//IBInspectable CGFloat leftPadding = 10.0;
//IBInspectable CGFloat topPadding;
@property (nonatomic) IBInspectable CGFloat topPadding;
@end
