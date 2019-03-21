//
//  BannerMng.m
//  Grid
//
//  Created by ChunTa Chen on 7/1/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//
#import "LogMng.h"
#import "BannerMng.h"
#import "OpeningBanner.h"

//Delay N second to dismiss sliding banner
#define BANNER_DISMISS_TIME 10

#define SHOW_BANNER_TIME 60*20

//Delay N second to dismiss banner
#define DELAY_OPENING_BANNER 30

//Delay N second to pull opening banner again
#define RETRY_DELAY 60*2

//For Sliding Banner
@interface Banner : NSObject
@property(nonatomic, assign)double timedelay;
@property(nonatomic, strong)NSUserNotification *notification;
@end
@implementation Banner

@end

@interface BannerMng()<NSUserNotificationCenterDelegate, OpeningBannerDelegate>
{
    NSMutableArray* bannerlist;
    NSButton *topbtn;
    NSPopover *openingadpopover;
    OpeningBanner *openingbanner;
}
@end

@implementation BannerMng
- (instancetype)initWithTopButton:(NSButton*)top
{
    self = [super init];
    topbtn = top;
    [self initBanner];
    return self;
}

- (void)initBanner
{
    bannerlist = [[NSMutableArray alloc] init];
    
    //For Opening Banner
    [self requestOpeningBanner];
    
    //For Sliding-in Banner
    //[self requestBanner];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkBanner) userInfo:nil repeats:YES];
}

- (void)checkBanner
{
    if ([bannerlist count])
    {
        Banner *first = [bannerlist firstObject];
        if ((CACurrentMediaTime()-first.timedelay)>BANNER_DISMISS_TIME)
        {
            [bannerlist removeObjectAtIndex:0];
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:first.notification];
            NSLog(@"remove one notification");
        }
    }
}

- (void)requestOpeningBanner
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:OPENING_BANNER_REQUEST_URL]];
    NSLog(@"URL->%@", request.URL.absoluteString);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            //Error or state handling
            if(!connectionError)
            {
                NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", newStr);
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if ([[[json objectForKey:@"status"] lowercaseString] isEqualToString:@"ok"])
                {
                    int r = (rand() % 10) + 2;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(r * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self createOpeningBanner:json];
                    });
                }
                else if ([[json objectForKey:@"code"] integerValue]==1002)
                {
                    //We have banners, but not in the timespan.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RETRY_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self requestOpeningBanner];
                    });
                }
            }
            else
            {
                NSLog(@"Get opening banner failure~~");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RETRY_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self requestOpeningBanner];
                });
            }
        });
        //
    }];
}
    
- (void)createOpeningBanner:(NSDictionary*)json
{
    if (openingadpopover)
    {
        [openingadpopover close];
    }
    if (openingbanner)
    {
        [openingbanner removeFromParentViewController];
    }
    NSDictionary* msg = [json objectForKey:@"msg"];
    NSString* loc = [msg objectForKey:@"location"];
    NSArray* infos = [loc componentsSeparatedByString:@"@"];
    if (infos.count==2)
    {
        BOOL isGif = NO;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[infos firstObject]]];
        if([request.URL.absoluteString containsString:@".gif"])
        {
            isGif = YES;
        }
        NSString *link = [infos objectAtIndex:1];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError && data)
            {
                //Ok - start -
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSImage *img = [[NSImage alloc] initWithData:data];
                    if (img)
                    {
                        NSLog(@"%f %f", img.size.width, img.size.height);
                        //Create Opening Banner------------------------------------------------
                        float ratio = img.size.height/img.size.width;
                        float fixw = 100;
                        openingbanner = [[OpeningBanner alloc] initImg:img IsGif:isGif Link:link Size:NSMakeSize(fixw, fixw*ratio) Del:self];
                        openingbanner.view.frame = NSMakeRect(0, 0, fixw, fixw*ratio);
                        openingadpopover = [[NSPopover alloc] init];
                        openingadpopover.contentViewController = openingbanner;
                        openingadpopover.behavior = NSPopoverBehaviorApplicationDefined;
                        [openingadpopover showRelativeToRect:topbtn.bounds ofView:topbtn preferredEdge:NSRectEdgeMaxY];
                        
                        /************ LOG ************/
                        [LogMng logOpeningBannerArrivedEvent];
                        /*****************************/
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_OPENING_BANNER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (openingadpopover)
                            {
                                [openingadpopover close];
                                openingadpopover = nil;
                            }
                            if (openingbanner)
                            {
                                [openingbanner removeFromParentViewController];
                                openingbanner = nil;
                            }
                        });
                        //--------------------------------------------------------------------
                    }
                });
                //Ok - end -
            }
        }];
    }
}
    
- (void)didClickOpeningBannerLink
{
    if (openingadpopover)
    {
        [openingadpopover close];
        openingadpopover = nil;
    }
    if (openingbanner)
    {
        [openingbanner removeFromParentViewController];
        openingbanner = nil;
    }
}
    
- (void)requestBanner
{
    [NSTimer scheduledTimerWithTimeInterval:SHOW_BANNER_TIME target:self selector:@selector(requestBannerImp) userInfo:nil repeats:YES];
}

- (void)requestBannerImp
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:BANNER_REQUEST_URL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       //Error or state handling
                                       if(!connectionError)
                                       {
                                           NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           NSLog(@"%@", newStr);
                                           NSError* error;
                                           NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           if ([[[json objectForKey:@"status"] lowercaseString] isEqualToString:@"ok"])
                                           {
                                               //init noti -----------------------
                                               NSDictionary *info = [json objectForKey:@"msg"];
                                               NSString *title = [info objectForKey:@"summary"];
                                               NSString *body = [info objectForKey:@"description"];
                                               NSString *urls = [info objectForKey:@"location"];
                                               //URL
                                               NSString *imgurl = @"";
                                               NSString *directurl = @"";
                                               NSArray *urllist = [urls componentsSeparatedByString:@"@"];
                                               if (urllist && urllist.count)
                                               {
                                                   imgurl = [urllist objectAtIndex:0];
                                                   if (urllist.count>=2)
                                                   {
                                                       directurl = [urllist objectAtIndex:1];
                                                   }
                                               }
                                               //Logo image
                                               NSImage *logoimg = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgurl]];
                                               //Initalize new notification
                                               NSUserNotification *notification = [[NSUserNotification alloc] init];
                                               //Custome image
                                               [notification setContentImage:logoimg];
                                               //Set the title of the notification
                                               [notification setTitle:title];
                                               //Set the text of the notification
                                               [notification setInformativeText:body];
                                               //Set the time and date on which the nofication will be deliverd (for example 20 secons later than the current date and time)
                                               [notification setDeliveryDate:[NSDate dateWithTimeInterval:1 sinceDate:[NSDate date]]];
                                               //Set the sound, this can be either nil for no sound, NSUserNotificationDefaultSoundName for the default sound (tri-tone) and a string of a .caf file that is in the bundle (filname and extension)
                                               [notification setSoundName:nil];
                                               [notification setHasActionButton: YES];
                                               [notification setActionButtonTitle:@"馬上前往"];
                                               [notification setOtherButtonTitle: @"下次再說"];
                                               [notification setValue:@YES forKey:@"_showsButtons"];
                                               //Direct url
                                               if (directurl && directurl.length)
                                               {
                                                   NSDictionary* uinfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:directurl,nil]
                                                                                                     forKeys:[NSArray arrayWithObjects:@"url",nil]];
                                                   [notification setUserInfo:uinfo];
                                               }
                                               //Get the default notification center
                                               NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
                                               //Scheldule our NSUserNotification
                                               [center scheduleNotification:notification];
                                               
                                               //end. noti -----------------------
                                           }
                                       }
                                       else
                                       {
                                           NSLog(@"Get banner failure~~");
                                       }
                                       //-------
                                   });
                                   
                               }];
}

#pragma mark - NSUserNotificationCenterDelegate
// Sent to the delegate when a notification delivery date has arrived. At this time, the notification has either been presented to the user or the notification center has decided not to present it because your application was already frontmost.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    if (notification.isPresented)
    {
        Banner *banner = [Banner new];
        banner.timedelay = CACurrentMediaTime();
        banner.notification = notification;
        [bannerlist addObject:banner];
        
        //Log for turn-on
        [LogMng logNotificationArrivedEvent];
    }
    else
    {
        //Log for turn-off
        [LogMng logNotificationOffEvent];
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    //Log when user click
    NSDictionary *uinfo = notification.userInfo;
    if (uinfo && [uinfo objectForKey:@"url"])
    {
        NSString *urlstr = [uinfo objectForKey:@"url"];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}
@end
