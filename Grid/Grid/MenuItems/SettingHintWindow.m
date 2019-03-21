//
//  SettingHintWindow.m
//  Grid
//
//  Created by Cindy on 1/27/18.
//  Copyright © 2018 ChunTa Chen. All rights reserved.
//

#import "SettingHintWindow.h"

@interface SettingHintWindow ()
@property(nonatomic, strong)IBOutlet NSTextField* hintTxt;
@end

@implementation SettingHintWindow

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    self.hintTxt.stringValue = NSLocalizedStringFromTable(@"HintForCustomKey", @"Localization", @"");
}
@end
