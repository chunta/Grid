//
//  GridCtlServer.m
//  Grid
//
//  Created by ChunTa Chen on 10/4/17.
//  Copyright © 2017 ChunTa Chen. All rights reserved.
//


#import "GCDAsyncSocket.h"
#import "GridCtlServer.h"

@interface GridCtlServer()<GCDAsyncSocketDelegate>
{
    NSNetService *netService;
    GCDAsyncSocket *asyncSocket;
    NSMutableArray *connectedSockets;
    dispatch_queue_t socketQueue;
}
@end

@implementation GridCtlServer
- (instancetype)init
{
    self = [super init];
    
    // Create our socket.
    // We tell it to invoke our delegate methods on the main thread.
    __weak id ws = self;
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:ws delegateQueue:socketQueue];
    
    // Create an array to hold accepted incoming connections.
    connectedSockets = [[NSMutableArray alloc] init];
    
    return self;
}
    
- (void)start
{
    NSError *err = nil;
    if ([asyncSocket acceptOnPort:0 error:&err])
    {
        // So what port did the OS give us?
        
        UInt16 port = [asyncSocket localPort];
        
        // Create and publish the bonjour service.
        // Obviously you will be using your own custom service type.
        netService = [[NSNetService alloc] initWithDomain:@"local."
                                                     type:@"_MildGrid._tcp."
                                                     name:@""
                                                     port:port];
        
        [netService setDelegate:self];
        [netService publish];
    }
    else
    {
        NSLog(@"Error in acceptOnPort:error: -> %@", err);
    }
}
   
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
        
    // The newSocket automatically inherits its delegate & delegateQueue from its parent.
    [connectedSockets addObject:newSocket];
    
    
    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:welcomeData withTimeout:-1 tag:1];
    
    [[connectedSockets lastObject] readDataWithTimeout:-1 tag:0];
}
    
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Socket Disconnect:%@", [sock connectedAddress]);
    [connectedSockets removeObject:sock];
}
    
- (void)netServiceDidPublish:(NSNetService *)ns
{
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
                  [ns domain], [ns type], [ns name], (int)[ns port]);
}
    
- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    // Override me to do something here...
    // Note: This method in invoked on our bonjour thread.
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
                   [ns domain], [ns type], [ns name], errorDict);
}
    
#pragma mark - GCSAynsDelegate
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{

}
    
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString * read = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%ld %@", data.length, read);
    
    CGKeyCode keyCode = 0;
    if ([[read lowercaseString] containsString:@"left"])
    {
        keyCode = 123;
    }
    else if([[read lowercaseString] containsString:@"right"])
    {
        keyCode = 124;
    }
    else if([[read lowercaseString] containsString:@"up"])
    {
        keyCode = 126;
    }
    else if([[read lowercaseString] containsString:@"down"])
    {
        keyCode = 125;
    }
    if (keyCode>0)
    {
        CGEventRef eventRef = CGEventCreateKeyboardEvent (NULL, keyCode, true);
        CGEventPost(kCGSessionEventTap, eventRef);
        CFRelease(eventRef);
        eventRef = CGEventCreateKeyboardEvent (NULL, keyCode, false);
        CGEventPost(kCGSessionEventTap, eventRef);
        CFRelease(eventRef);
    }
    
    [[connectedSockets lastObject] readDataWithTimeout:-1 tag:0];
    

}
@end
