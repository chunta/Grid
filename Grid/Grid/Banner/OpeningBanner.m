//
//  OpeningBanner.m
//  Grid
//
//  Created by ChunTa Chen on 2017/8/19.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "OpeningBanner.h"

@interface OpeningBanner ()
{
    NSString* adurl;
    id<OpeningBannerDelegate> delegate;
}
@end

@implementation OpeningBanner
-(instancetype)initImg:(NSImage*)img IsGif:(BOOL)agif Link:(NSString*)url Size:(NSSize)size Del:(id<OpeningBannerDelegate>)del
{
    self = [super init];
    NSImageView *imgv = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)];
    imgv.image = img;
    imgv.canDrawSubviewsIntoLayer = agif;
    imgv.animates = agif;
    [self.view addSubview:imgv];
    
    NSButton *btn = [[NSButton alloc] initWithFrame:imgv.frame];
    [btn setTitle:@""];
    btn.transparent = YES;
    btn.alphaValue = 0;
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor clearColor].CGColor;
    [self.view addSubview:btn];
    [btn setTarget:self];
    [btn setAction:@selector(linkAction:)];
    
    adurl = url;
    delegate = del;
    
    //White background
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    return self;
}
    
- (void)linkAction:(NSButton*)sender
{
    NSLog(@"%@", adurl);
    NSURL *myURL = [NSURL URLWithString:adurl];
    [[NSWorkspace sharedWorkspace] openURL:myURL];
    [delegate didClickOpeningBannerLink];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
