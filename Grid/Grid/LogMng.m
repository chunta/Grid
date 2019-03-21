//
//  LogMng.m
//  Grid
//
//  Created by ChunTa Chen on 6/27/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import "LogMng.h"
#import "GHelper.h"
#import "ValidationHelper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static double tstampe = 0;
const static int delay = 60;

@interface LogMng()<NSURLSessionDelegate>
{
 
}
@end
@implementation LogMng
+(void)checkDelay
{
    double now = CACurrentMediaTime();
    if ((now-tstampe)>delay)
    {
        [LogMng logIdle];
        tstampe = now;
    }
}

//Log user Idle
+(void)logIdle
{
    NSLog(@"Log idle....");
    [LogMng logImplEvent:@"userIdle" Action:@"keepalive" Label:@"idle"];
}

+(void)monitorIdle
{
    //NSTimer workable since MacOSX 10.0 or later
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target:[LogMng class] selector:@selector(checkDelay) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

//Log when user open our app
+(void)logLaunchEvent
{
    [LogMng logImplEvent:@"application" Action:@"launch" Label:@"application"];
    [LogMng monitorIdle];
}

//Log when user open topmenu
+(void)logOpenTopMenuEvent
{
    [LogMng logImplEvent:@"topmenu" Action:@"open" Label:@"topmenu"];
}

//Log when notification is fine to show
+(void)logNotificationArrivedEvent
{
    [LogMng logImplEvent:@"notification" Action:@"arrive" Label:@"notification"];
}

//Log when notification is close to show
+(void)logNotificationOffEvent
{
    [LogMng logImplEvent:@"notification" Action:@"turnoff" Label:@"notification"];
}

//Log when change grid type
+(void)logChangeGridType:(NSString*)type
{
    [LogMng logImplEvent:@"gridtype" Action:type Label:@"grid"];
}

//Log when change visual guidance
+(void)logChangeVGuidance:(NSString*)guidance
{
    [LogMng logImplEvent:@"visual_guidance" Action:guidance Label:@"visual_guidance"];
}

//Log when change launch guidance
+(void)logChangeLaunch:(NSString*)onoff
{
    [LogMng logImplEvent:@"launchOnOff" Action:onoff Label:@"launchOnOff"];
}

//Log when change cell color
+(void)logChangeCellColor:(NSString*)color
{
    [LogMng logImplEvent:@"cellcolor" Action:color Label:@"color"];
}

//Log when change border color
+(void)logChangeBorderColor:(NSString*)color
{
    [LogMng logImplEvent:@"bordercolor" Action:color Label:@"color"];
}

//Log when change modifier
+(void)logChangeMod01:(NSString*)mod01 Mod02:(NSString*)mod02
{
    
    NSString* label = @"modifierkey";
    int imod01 = [mod01 intValue];
    switch (imod01) {
        case 0:
            mod01 = @"control";
            break;
        case 1:
            mod01 = @"command";
            break;
        case 2:
            mod01 = @"option";
            break;
        case 3:
            mod01 = @"shift";
            break;
        default:
            break;
    }
    int imod02 = [mod02 intValue];
    switch (imod02) {
        case 0:
            mod02 = @"control";
            break;
        case 1:
            mod02 = @"command";
            break;
        case 2:
            mod02 = @"option";
            break;
        case 3:
            mod02 = @"shift";
            break;
        default:
            break;
    }
    [LogMng logImplEvent:@"keypress" Action:[NSString stringWithFormat:@"%@ %@", mod01, mod02] Label:label];
}

//Log when press key
+(void)logPressKey:(NSString*)key
{
    NSString* label = @"misc";
    if([key isEqualToString:@"126"])
    {
        key = @"up";
        label = @"arrowkey";
    }
    else if([key isEqualToString:@"124"])
    {
        key = @"right";
        label = @"arrowkey";
    }
    else if([key isEqualToString:@"123"])
    {
        key = @"left";
        label = @"arrowkey";
    }
    else if([key isEqualToString:@"125"])
    {
        key = @"down";
        label = @"arrowkey";
    }
    [LogMng logImplEvent:@"keypress" Action:key Label:label];
}

//Log when user go to modifier setting
+(void)logOpenModifierSetting
{
    [LogMng logImplEvent:@"modifiermenu" Action:@"open" Label:@"modifierkey"];
}

+(void)logOpenHintInCustomKeySetting
{
    [LogMng logImplEvent:@"customkeysetting" Action:@"openhint" Label:@"customkeysetting"];
}

+(void)logOpenCustomKeySetting
{
    [LogMng logImplEvent:@"customkeysetting" Action:@"open" Label:@"customkeysetting"];
}

+(void)logOpeningBannerArrivedEvent
{
    [LogMng logImplEvent:@"openingbanner" Action:@"arrive" Label:@"banner"];
}

+ (void)logImplEvent:(NSString*)eventname Action:(NSString*)action Label:(NSString*)label
{
    //NSLog(@"logImplEvent--> %@ %@", action, label);
    
    //Update idle time
    tstampe = CACurrentMediaTime();
    
    NSString *cid = getPlatformSerialNumber();
    // 1.创建一个网络路径
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google-analytics.com/collect"]];
    // 2.创建一个网络请求，分别设置请求方法、请求参数
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *args = [NSString stringWithFormat:@"cid=%@&tid=%@&v=%d&t=%@&dp=%@&dt=%@&ec=%@&ea=%@&el=%@&ev=%@",
                      (cid)?:@"Unknown userid",
                      TID,
                      1,
                      @"event",
                      [NSString stringWithFormat:@"%@_dp", eventname],
                      [NSString stringWithFormat:@"%@_dt", eventname],
                      eventname, //category
                      action,    //action
                      label,     //label
                      @"2"];
    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    
    // 3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 4.根据会话对象，创建一个Task任务
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Log has error %@", [error description]);
        }
    }];
    
    //5.最后一步，执行任务，(resume也是继续执行)。
    [sessionDataTask resume];
}

+ (void)logImpl:(NSString*)eventname
{
    NSString *cid = getPlatformSerialNumber();
    // 1.创建一个网络路径
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google-analytics.com/collect"]];
    // 2.创建一个网络请求，分别设置请求方法、请求参数
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *args = [NSString stringWithFormat:@"cid=%@&tid=%@&v=%d&t=%@&dp=%@&dt=%@&ec=%@&ea=%@&el=%@&ev=%@",
                      (cid)?:@"Unknown userid",
                      TID,
                      1,
                      @"event",
                      [NSString stringWithFormat:@"%@_dp", eventname], /*@"notificationpresent_dp",*/
                      [NSString stringWithFormat:@"%@_dt", eventname], /*@"notificationpresent_dt",*/
                      [NSString stringWithFormat:@"%@_ec", eventname], /*@"notificationpresent_ec",*/
                      [NSString stringWithFormat:@"%@_ea", eventname], /*@"notificationpresent_ea",*/
                      [NSString stringWithFormat:@"%@_el", eventname], /*@"notificationpresent_el",*/
                      @"2"];
    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    
    // 3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 4.根据会话对象，创建一个Task任务
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"从服务器获取到数据");
        if (error)
        {
            NSLog(@"Launch event has error %@", [error description]);
        }
    }];
    
    //5.最后一步，执行任务，(resume也是继续执行)。
    [sessionDataTask resume];
}
@end
