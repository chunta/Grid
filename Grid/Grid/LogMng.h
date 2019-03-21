//
//  LogMng.h
//  Grid
//
//  Created by ChunTa Chen on 6/27/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogMng : NSObject
//Log user idel
+(void)monitorIdle;

//Log when user open our app
+(void)logLaunchEvent;

//Log when user open topmenu
+(void)logOpenTopMenuEvent;

//Log when notification is fine to show
+(void)logNotificationArrivedEvent;

//Log when notification is close to show
+(void)logNotificationOffEvent;

//Log when change grid type
+(void)logChangeGridType:(NSString*)type;

//Log when change visual guidance
+(void)logChangeVGuidance:(NSString*)guidance;

//Log when change launch guidance
+(void)logChangeLaunch:(NSString*)onoff;

//Log when change cell color
+(void)logChangeCellColor:(NSString*)color;

//Log when change border color
+(void)logChangeBorderColor:(NSString*)color;

//Log when change modifier
+(void)logChangeMod01:(NSString*)mod01 Mod02:(NSString*)mod02;

//Log when press key
+(void)logPressKey:(NSString*)key;

//Log when user go to modifier setting
+(void)logOpenModifierSetting;

//Log when user open custom setting
+(void)logOpenCustomKeySetting;

//Log when user click on hint button in custom setting
+(void)logOpenHintInCustomKeySetting;

//Log when user see opening banner
+(void)logOpeningBannerArrivedEvent;
@end
