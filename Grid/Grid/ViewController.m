//
//  ViewController.m
//  Grid
//
//  Created by ChunTa Chen on 4/30/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.view.layer.borderWidth = 4;
    NSAlert* a = [NSAlert new];
    [a setShowsHelp:YES];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
@end
