//
//  VersionMng.m
//  Grid
//
//  Created by ChunTa Chen on 2017/7/5.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "VersionMng.h"
#import "UpdateReminder.h"
#define DELAY_AFTER_ERROR 120 //2 min
#define DELAY_NORMAL 120 //2 min
#define DELAY_START 20
#define DELAY_REMINDER 18
@interface VersionMng()
{
    NSTimer *timer;
    NSPopover *reminderpopover;
    UpdateReminder *reminder;
    NSButton *topbtn;
    BOOL forceUpdate;
}
@property(nonatomic, weak)id<VersionMngDelegate> delegate;
@end
@implementation VersionMng
- (instancetype)initWithTopButton:(NSButton*)top Delegate:(id<VersionMngDelegate>)del
{
    self = [super init];
    self.delegate = del;
    topbtn = top;
    [self startCheck:DELAY_START];
    return self;
}

- (void)startCheckImp
{
    //----------------
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // example: 1.0.0
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *vb = [NSString stringWithFormat:@"%@.%@",appVersion,buildNumber];
    
    NSString *strurl = [NSString stringWithFormat:@"%@", VERSION_REQUEST_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strurl]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"version=%@", vb];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   //Error or state handling
                                   if (!connectionError)
                                   {
                                       NSError* error;
                                       NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       if (json && [json objectForKey:@"status"])
                                       {
                                           NSString* stauts = [json objectForKey:@"status"];
                                           if([[stauts lowercaseString] isEqualToString:@"ok"])
                                           {
                                               NSLog(@"Currentversion is the latest");
                                               [self startCheck:DELAY_NORMAL];
                                           }
                                           else
                                           {
                                               NSLog(@"Show reminder");
                                               //沒有必要資訊 強制更新
                                               NSString* msg = [json objectForKey:@"msg"];
                                               if (!msg || msg.length==0)
                                               {
                                                   [self showForceReminder:@""];
                                                   return;
                                               }
                                               //版本資訊格式錯誤 強制更新
                                               NSArray *vl = [msg componentsSeparatedByString:@"."];
                                               if (vl==nil || vl.count==0)
                                               {
                                                   [self showForceReminder:@""];
                                                   return;
                                               }
                                               //奇數為強制更新
                                               NSInteger lastv = [[vl lastObject] integerValue];
                                               if (lastv%2!=0)
                                               {
                                                   [self showForceReminder:msg];
                                                   return;
                                               }
                                               
                                               //軟更新
                                               [self showSoftReminder:msg];
                                               [self startCheck:DELAY_NORMAL];
                                           }
                                       }
                                       else
                                       {
                                           NSLog(@"Error in verify version");
                                           [self startCheck:DELAY_AFTER_ERROR];
                                       }
                                   }
                                   else
                                   {
                                       NSLog(@"Error in verify version");
                                       [self startCheck:DELAY_AFTER_ERROR];
                                   }
                                   //-------
                               });
                               
                           }];
    //----------------------------
}

- (void)startCheck:(NSInteger)delay
{
    [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(startCheckImp) userInfo:nil repeats:NO];
}

- (void)showSoftReminder:(NSString*)version
{
    if (reminderpopover)
    {
        [reminderpopover close];
    }
    if (reminder)
    {
        [reminder removeFromParentViewController];
    }
    
    reminder = [[UpdateReminder alloc] init];
    reminder.update_version = version;
    reminderpopover = [[NSPopover alloc] init];
    reminderpopover.contentViewController = reminder;
    reminderpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [reminderpopover showRelativeToRect:topbtn.bounds ofView:topbtn preferredEdge:NSRectEdgeMaxY];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_REMINDER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (reminderpopover)
        {
            [reminderpopover close];
        }
        if (reminder)
        {
            [reminder removeFromParentViewController];
        }
    });
}

- (void)showForceReminder:(NSString*)version
{
    forceUpdate = YES;
    
    if (reminderpopover)
    {
        [reminderpopover close];
    }
    if (reminder)
    {
        [reminder removeFromParentViewController];
    }
    
    reminder = [[UpdateReminder alloc] init];
    reminder.update_version = version;
    reminder.force = YES;
    reminderpopover = [[NSPopover alloc] init];
    reminderpopover.contentViewController = reminder;
    reminderpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [reminderpopover showRelativeToRect:topbtn.bounds ofView:topbtn preferredEdge:NSRectEdgeMaxY];
    
    [self.delegate stayInForceUpdate];
}

- (BOOL)needForceUpdate
{
    return forceUpdate;
}
@end
