//
//  PreferModifierSetting.m
//  Grid
//
//  Created by ChunTa Chen on 2017/7/25.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "PreferModifierSetting.h"
#import "LogMng.h"
@interface PreferModifierSetting ()
@property(nonatomic, strong)IBOutlet NSView *bgview;

@property(nonatomic, strong)IBOutlet NSButtonCell *btncell;

@property(nonatomic, strong)IBOutlet NSButton *mod01_ctl;
@property(nonatomic, strong)IBOutlet NSButton *mod01_cmd;
@property(nonatomic, strong)IBOutlet NSButton *mod01_opt;
@property(nonatomic, strong)IBOutlet NSButton *mod01_sht;

@property(nonatomic, strong)IBOutlet NSButton *mod02_ctl;
@property(nonatomic, strong)IBOutlet NSButton *mod02_cmd;
@property(nonatomic, strong)IBOutlet NSButton *mod02_opt;
@property(nonatomic, strong)IBOutlet NSButton *mod02_sht;

@property(nonatomic, strong)IBOutlet NSArray *mod01_list;
@property(nonatomic, strong)IBOutlet NSArray *mod02_list;

@property(nonatomic, assign)NSInteger mod01SelIndex;
@property(nonatomic, assign)NSInteger mod02SelIndex;
@end

static NSString* MFileNames[4] = {@"Control", @"Cmd", @"Opt", @"Shift"};
@implementation PreferModifierSetting

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    NSString *m01 = [[NSUserDefaults standardUserDefaults] objectForKey:kModifier01];
    NSString *m02 = [[NSUserDefaults standardUserDefaults] objectForKey:kModifier02];
    
    if (m01==nil || m02==nil)
    {
        
    }
    
    self.mod01SelIndex = [m01 integerValue];
    self.mod02SelIndex = [m02 integerValue];
    
    self.btncell.backgroundColor = [NSColor clearColor];
    
    self.mod01_list = [NSArray arrayWithObjects:self.mod01_ctl, self.mod01_cmd, self.mod01_opt, self.mod01_sht, nil];
    self.mod02_list = [NSArray arrayWithObjects:self.mod02_ctl, self.mod02_cmd, self.mod02_opt, self.mod02_sht, nil];
    
    [self cleanMod01];
    [self cleanMod02];
    NSButton *btn01 = [self.mod01_list objectAtIndex:self.mod01SelIndex];
    NSButton *btn02 = [self.mod02_list objectAtIndex:self.mod02SelIndex];
    NSString *filename01 = [NSString stringWithFormat:@"%@_Selected.png", MFileNames[self.mod01SelIndex]];
    NSString *filename02 = [NSString stringWithFormat:@"%@_Selected.png", MFileNames[self.mod02SelIndex]];
    [btn01 setImage:[NSImage imageNamed:filename01]];
    [btn02 setImage:[NSImage imageNamed:filename02]];
}

- (IBAction)onBack:(id)sender
{
    [self.delegate onModifierSettingBack];
}

- (void)cleanMod01
{
    //clean
    for (int i = 0; i < 4; i++)
    {
        NSString *name = MFileNames[i];
        NSButton *btn = [self.mod01_list objectAtIndex:i];
        NSString *filename = [NSString stringWithFormat:@"%@_Normal.png", name];
        [btn setImage:[NSImage imageNamed:filename]];
    }
}

- (void)cleanMod02
{
    //clean
    for (int i = 0; i < 4; i++)
    {
        NSString *name = MFileNames[i];
        NSButton *btn = [self.mod02_list objectAtIndex:i];
        NSString *filename = [NSString stringWithFormat:@"%@_Normal.png", name];
        [btn setImage:[NSImage imageNamed:filename]];
    }
}

- (IBAction)onBtnClick:(id)sender
{
    NSButton *btn = sender;
    NSInteger tag = btn.tag;
    if(tag < 10)
    {
        //clean
        [self cleanMod01];
        
        //update mod01
        NSInteger index = tag;
        NSString *name = MFileNames[index];
        NSButton *btn = [self.mod01_list objectAtIndex:index];
        NSString *filename = [NSString stringWithFormat:@"%@_Selected.png", name];
        [btn setImage:[NSImage imageNamed:filename]];
        
        self.mod01SelIndex = index;
        
        //update mod02
        if (self.mod01SelIndex==self.mod02SelIndex)
        {
            self.mod02SelIndex++;
            if(self.mod02SelIndex>=4)
            {
                self.mod02SelIndex = 0;
            }
            
            [self cleanMod02];
            
            NSString *name = MFileNames[self.mod02SelIndex];
            NSButton *btn = [self.mod02_list objectAtIndex:self.mod02SelIndex];
            NSString *filename = [NSString stringWithFormat:@"%@_Selected.png", name];
            [btn setImage:[NSImage imageNamed:filename]];
        }
    }
    else{
        
        //clean
        [self cleanMod02];
        
        //update mod02
        NSInteger index = tag - 10;
        NSString *name = MFileNames[index];
        NSButton *btn = [self.mod02_list objectAtIndex:index];
        NSString *filename = [NSString stringWithFormat:@"%@_Selected.png", name];
        [btn setImage:[NSImage imageNamed:filename]];
        
        self.mod02SelIndex = index;
        
        //update mod01
        if (self.mod02SelIndex==self.mod01SelIndex)
        {
            self.mod01SelIndex++;
            if(self.mod01SelIndex>=4)
            {
                self.mod01SelIndex = 0;
            }
            
            [self cleanMod01];
            
            NSString *name = MFileNames[self.mod01SelIndex];
            NSButton *btn = [self.mod01_list objectAtIndex:self.mod01SelIndex];
            NSString *filename = [NSString stringWithFormat:@"%@_Selected.png", name];
            [btn setImage:[NSImage imageNamed:filename]];
        }
    }
    
    [LogMng logChangeMod01:[NSString stringWithFormat:@"%ld", self.mod01SelIndex] Mod02:[NSString stringWithFormat:@"%ld", self.mod02SelIndex]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", self.mod01SelIndex] forKey:kModifier01];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", self.mod02SelIndex] forKey:kModifier02];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
