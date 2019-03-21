//
//  ValidateForm.m
//  Grid
//
//  Created by ChunTa Chen on 2017/6/5.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "UpdateReminder.h"
@interface UpdateReminder ()
@property(nonatomic, strong)IBOutlet NSButton* inlinebtn;
@property(nonatomic, strong)IBOutlet NSTextField* vtxt;
@end

@implementation UpdateReminder
-(IBAction)onBuyLicense:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    if (self.force)
    {
        NSColor *color = [NSColor blackColor];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:NSLocalizedStringFromTable(@"Update", @"Localization", @"") attributes:attrsDictionary];
        [self.inlinebtn setAttributedTitle:attrString];
    }
    else
    {
        NSColor *color = [NSColor blackColor];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:NSLocalizedStringFromTable(@"Update", @"Localization", @"") attributes:attrsDictionary];
        [self.inlinebtn setAttributedTitle:attrString];
    }
    
    self.vtxt.stringValue = self.update_version;
}

- (IBAction)onUpdate:(id)sender
{ 
    NSURL *myURL = [NSURL URLWithString:WEBSITE_URL];
    [[NSWorkspace sharedWorkspace] openURL:myURL];
}
@end
