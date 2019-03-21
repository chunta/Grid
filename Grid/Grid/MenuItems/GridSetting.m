//
//  GridSetting.m
//  Grid
//
//  Created by Cindy on 2018/1/23.
//  Copyright © 2018年 ChunTa Chen. All rights reserved.
//

#import "GridSetting.h"
#import "SettingTxtFormat.h"
#import "UserInfoTextField.h"
#import "GridTextInputFormatter.h"
#import "SettingHintWindow.h"
#import "LogMng.h"
@interface GridSetting ()
{
    SettingTxtFormat* format;
    NSMutableArray* repo3x3;
    NSMutableArray* repo2x2;
    NSPopover* menuPopover;
    
    NSArray *default3x3;
    NSArray *default2x2;
}

typedef enum SyncType : NSUInteger {
    kG3x3,
    kG2x2
} SyncType;

@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_09;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_08;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_07;

@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_06;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_05;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_04;

@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_03;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_02;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g33_01;

@property(nonatomic, strong)IBOutlet UserInfoTextField* g22_05;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g22_04;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g22_02;
@property(nonatomic, strong)IBOutlet UserInfoTextField* g22_01;

@property(nonatomic, strong)IBOutlet NSButton* hintbtn;

@end



@implementation GridSetting
- (void)viewDidLoad {
    [super viewDidLoad];
 
    format = [[SettingTxtFormat alloc] init];
    format.maximumLength = 1;
    NSArray* views = self.view.subviews;
    int c = 0;
    for (NSView* view in views)
    {
 
        if([view isKindOfClass:[NSTextField class]])
        {
            c++;
            NSLog(@"%d", c);
            ((NSTextField*)view).formatter = format;
            ((NSTextField*)view).delegate = self;
        }
    }
    
    default3x3 = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    default2x2 = [NSArray arrayWithObjects:@"1", @"2", @"4", @"5", nil];
    
    /************ LOG ************/
    [LogMng logOpenCustomKeySetting];
    /*****************************/
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    [self syncSettingWithKeyboard:kG3x3];
    [self syncSettingWithKeyboard:kG2x2];
    
    [self.g33_09 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_08 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_07 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_06 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_05 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_04 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_03 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_02 setFocusRingType:NSFocusRingTypeNone];
    [self.g33_01 setFocusRingType:NSFocusRingTypeNone];
    
    self.g33_07.next = self.g33_08;
    self.g33_08.next = self.g33_09;
    self.g33_09.next = self.g33_04;
    
    self.g33_04.next = self.g33_05;
    self.g33_05.next = self.g33_06;
    self.g33_06.next = self.g33_01;
    
    self.g33_01.next = self.g33_02;
    self.g33_02.next = self.g33_03;
    self.g33_03.next = self.g22_04;
    
    [self.g22_05 setFocusRingType:NSFocusRingTypeNone];
    [self.g22_04 setFocusRingType:NSFocusRingTypeNone];
    [self.g22_02 setFocusRingType:NSFocusRingTypeNone];
    [self.g22_01 setFocusRingType:NSFocusRingTypeNone];
    
    self.g22_04.next = self.g22_05;
    self.g22_05.next = self.g22_01;
    self.g22_01.next = self.g22_02;
    self.g22_02.next = nil;
    
    //Formatter
    GridTextInputFormatter* format = [[GridTextInputFormatter alloc] init];
    self.g33_01.formatter = format;
    self.g33_02.formatter = format;
    self.g33_03.formatter = format;
    self.g33_04.formatter = format;
    self.g33_05.formatter = format;
    self.g33_06.formatter = format;
    self.g33_07.formatter = format;
    self.g33_08.formatter = format;
    self.g33_09.formatter = format;
    self.g22_04.formatter = format;
    self.g22_05.formatter = format;
    self.g22_01.formatter = format;
    self.g22_02.formatter = format;
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    [self checkValidationAndSync];
}

- (void)syncSettingWithKeyboard:(SyncType)type
{
    if (type==kG3x3)
    {
        NSArray* s3x3 = [[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting3x3];
        if (s3x3)
        {
            repo3x3 = [[NSMutableArray alloc] initWithArray:s3x3];
        }
        else
        {
            repo3x3 = [[NSMutableArray alloc] initWithArray:default3x3];
        }
        if (repo3x3.count!=9)
        {
            repo3x3 = [[NSMutableArray alloc] initWithArray:default3x3];
        }
        self.g33_01.stringValue = [repo3x3 objectAtIndex:0];
        self.g33_02.stringValue = [repo3x3 objectAtIndex:1];
        self.g33_03.stringValue = [repo3x3 objectAtIndex:2];
        self.g33_04.stringValue = [repo3x3 objectAtIndex:3];
        self.g33_05.stringValue = [repo3x3 objectAtIndex:4];
        self.g33_06.stringValue = [repo3x3 objectAtIndex:5];
        self.g33_07.stringValue = [repo3x3 objectAtIndex:6];
        self.g33_08.stringValue = [repo3x3 objectAtIndex:7];
        self.g33_09.stringValue = [repo3x3 objectAtIndex:8];
    }
    if(type==kG2x2)
    {
        NSArray* s2x2 = [[NSUserDefaults standardUserDefaults] objectForKey:CustomSetting2x2];
        if (s2x2)
        {
            repo2x2 = [[NSMutableArray alloc] initWithArray:s2x2];
        }
        else
        {
            repo2x2 = [[NSMutableArray alloc] initWithArray:default2x2];
        }
        if (repo2x2.count!=4)
        {
            repo2x2 = [[NSMutableArray alloc] initWithArray:default2x2];
        }
        self.g22_01.stringValue = [repo2x2 objectAtIndex:0];
        self.g22_02.stringValue = [repo2x2 objectAtIndex:1];
        self.g22_04.stringValue = [repo2x2 objectAtIndex:2];
        self.g22_05.stringValue = [repo2x2 objectAtIndex:3];
    }
}

- (void)writeSettingWithKeyboard:(SyncType)type Src:(NSArray*)src
{
    if (type==kG3x3)
    {
        if (src && src.count==9)
            repo3x3 = [[NSMutableArray alloc] initWithArray:src];
        else
            repo3x3 = [[NSMutableArray alloc] initWithArray:default3x3];
        
        if (repo3x3.count!=9)
        {
            repo3x3 = [[NSMutableArray alloc] initWithArray:default3x3];
        }
        self.g33_01.stringValue = [repo3x3 objectAtIndex:0];
        self.g33_02.stringValue = [repo3x3 objectAtIndex:1];
        self.g33_03.stringValue = [repo3x3 objectAtIndex:2];
        self.g33_04.stringValue = [repo3x3 objectAtIndex:3];
        self.g33_05.stringValue = [repo3x3 objectAtIndex:4];
        self.g33_06.stringValue = [repo3x3 objectAtIndex:5];
        self.g33_07.stringValue = [repo3x3 objectAtIndex:6];
        self.g33_08.stringValue = [repo3x3 objectAtIndex:7];
        self.g33_09.stringValue = [repo3x3 objectAtIndex:8];
        
        NSLog(@"Write to 3x3");
        if (src && src.count==9)
        {
            [[NSUserDefaults standardUserDefaults] setObject:repo3x3 forKey:CustomSetting3x3];
        }
        else
        {
            NSLog(@"Clear C3x3");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:CustomSetting3x3];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (type==kG2x2)
    {
        if (src && src.count==4)
            repo2x2 = [[NSMutableArray alloc] initWithArray:src];
        else
            repo2x2 = [[NSMutableArray alloc] initWithArray:default2x2];
        
        if (repo2x2.count!=4)
        {
            repo2x2 = [[NSMutableArray alloc] initWithArray:default2x2];
        }
        self.g22_01.stringValue = [repo2x2 objectAtIndex:0];
        self.g22_02.stringValue = [repo2x2 objectAtIndex:1];
        self.g22_04.stringValue = [repo2x2 objectAtIndex:2];
        self.g22_05.stringValue = [repo2x2 objectAtIndex:3];
        
        NSLog(@"Write to 2x2");
        if (src && src.count==4)
        {
            [[NSUserDefaults standardUserDefaults] setObject:repo2x2 forKey:CustomSetting2x2];
        }
        else
        {
            NSLog(@"Clear C2x2");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:CustomSetting2x2];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)awakeFromNib
{
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
        [self keyDown:aEvent];
        return aEvent;
    }];
}

- (IBAction)onReset3x3:(id)sender
{    
    //Clear warning border
    [self cleanWarning:kG3x3];
    
    //Write into preference
    [self writeSettingWithKeyboard:kG3x3 Src:default3x3];
}

- (IBAction)onReset2x2:(id)sender
{
    //Clear warning border
    [self cleanWarning:kG2x2];
    
    //Write into preference
    [self writeSettingWithKeyboard:kG2x2 Src:default2x2];
}

- (IBAction)onBack:(id)sender
{
    [self.delegate onGridSettingBack];
}

- (IBAction)onTextChange:(id)obj
{
    NSTextField *txt = (NSTextField*)obj;
    if(txt.stringValue.length==0)
    {
        txt.wantsLayer = YES;
        txt.layer.borderColor = [NSColor redColor].CGColor;
        txt.layer.borderWidth = 1;
    }
    else
    {
        txt.layer.borderWidth = 0;
    }
}

- (void)cleanWarning:(SyncType)type
{
    if (type==kG3x3)
    {
        NSArray *g3x3 = [NSArray arrayWithObjects:self.g33_01, self.g33_02, self.g33_03,
                         self.g33_04, self.g33_05, self.g33_06,
                         self.g33_07, self.g33_08, self.g33_09, nil];
        
        //Clear warning border
        for (int i = 0; i < g3x3.count; i++)
        {
            UserInfoTextField* utxt = [g3x3 objectAtIndex:i];
            [utxt hideWarning];
        }
    }
    if (type==kG2x2)
    {
        NSArray *g2x2 = [NSArray arrayWithObjects:self.g22_01, self.g22_02, self.g22_04, self.g22_05, nil];

        //Clear warning border
        for (int i = 0; i < g2x2.count; i++)
        {
            UserInfoTextField* utxt = [g2x2 objectAtIndex:i];
            [utxt hideWarning];
        }
    }
}

- (void)checkValidationAndSync
{
    //Clean 3x3 && 2x2
    [self cleanWarning:kG3x3];
    [self cleanWarning:kG2x2];
    
    //Scan 3x3
    NSArray *g3x3 = [NSArray arrayWithObjects:self.g33_01, self.g33_02, self.g33_03,
                                              self.g33_04, self.g33_05, self.g33_06,
                                              self.g33_07, self.g33_08, self.g33_09, nil];
    //Warning
    bool g33warning = false;
    
    //Check if empty
    for (int i = 0; i < g3x3.count; i++)
    {
        UserInfoTextField* utxt = [g3x3 objectAtIndex:i];
        if (utxt.stringValue.length==0)
        {
            [utxt showWarning];
            g33warning = true;
        }
    }
    
    //Check if duplicate
    NSMutableDictionary* hashTxt33 = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < g3x3.count; i++)
    {
        UserInfoTextField* utxt = [g3x3 objectAtIndex:i];
        UserInfoTextField* prev = [hashTxt33 objectForKey:utxt.stringValue];
        if (prev)
        {
            [utxt showWarning];
            [prev showWarning];
            g33warning = true;
        }
        else
        {
            [hashTxt33 setObject:utxt forKey:utxt.stringValue];
        }
    }
    
    //Write to user preference if possible
    if (!g33warning)
    {
        
        NSArray *src = [NSArray arrayWithObjects:self.g33_01.stringValue, self.g33_02.stringValue, self.g33_03.stringValue,
                         self.g33_04.stringValue, self.g33_05.stringValue, self.g33_06.stringValue,
                         self.g33_07.stringValue, self.g33_08.stringValue, self.g33_09.stringValue, nil];
        [self writeSettingWithKeyboard:kG3x3 Src:src];
    }
    
    //Scan 2x2
    NSArray *g2x2 = [NSArray arrayWithObjects:self.g22_01, self.g22_02, self.g22_04, self.g22_05, nil];
    
    //Warning
    bool g22warning = false;
    
    //Check if empty
    for (int i = 0; i < g2x2.count; i++)
    {
        UserInfoTextField* utxt = [g2x2 objectAtIndex:i];
        if (utxt.stringValue.length==0)
        {
            [utxt showWarning];
            g22warning = true;
        }
    }
    
    //Check if duplicate
    NSMutableDictionary* hashTxt22 = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < g2x2.count; i++)
    {
        UserInfoTextField* utxt = [g2x2 objectAtIndex:i];
        UserInfoTextField* prev = [hashTxt22 objectForKey:utxt.stringValue];
        if (prev)
        {
            [utxt showWarning];
            [prev showWarning];
            g22warning = true;
        }
        else
        {
            [hashTxt22 setObject:utxt forKey:utxt.stringValue];
        }
    }
    
    //Write to user preference if possible
    if (!g22warning)
    {
        NSArray *src = [NSArray arrayWithObjects:self.g22_01.stringValue, self.g22_02.stringValue,
                        self.g22_04.stringValue, self.g22_05.stringValue, nil];
        [self writeSettingWithKeyboard:kG2x2 Src:src];
    }
}

#pragma mark TextFieldDelegate
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return YES;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    UserInfoTextField* uinfo = obj.object;
    if (uinfo.stringValue.length > 1)
    {
        uinfo.stringValue = [uinfo.stringValue substringWithRange:NSMakeRange(0, 1)];
    }
    [self checkValidationAndSync];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    if([obj.object isKindOfClass:[UserInfoTextField class]])
    {
        NSText *fieldEditor = [[obj userInfo] objectForKey:@"NSFieldEditor"];
        [fieldEditor setString:[[fieldEditor string] uppercaseString]];
        
        if (((UserInfoTextField*)obj.object).stringValue.length>0)
        {
            UserInfoTextField *control = ((UserInfoTextField*)obj.object);
            if (control.next)
            {
                [control.next becomeFirstResponder];
            }
        }
        [self checkValidationAndSync];
    }
}

//Turn off beep beep
- (void)keyDown:(NSEvent *)theEvent
{
    return;
}

- (IBAction)onHint:(id)sender
{
    if (menuPopover)
    {
        [menuPopover close];
        menuPopover = nil;
    }
    
    SettingHintWindow* hint = [[SettingHintWindow alloc] initWithNibName:@"SettingHintWindow" bundle:[NSBundle mainBundle]];
    
    menuPopover = [[NSPopover alloc] init];
    menuPopover.animates = NO;
    menuPopover.contentViewController = hint;
    [menuPopover setContentSize: hint.view.frame.size];
    [menuPopover setBehavior: NSPopoverBehaviorTransient];
    [menuPopover showRelativeToRect:NSZeroRect ofView:self.hintbtn preferredEdge:NSRectEdgeMaxY];
    
    /************ LOG ************/
    [LogMng logOpenHintInCustomKeySetting];
    /*****************************/
}

@end
