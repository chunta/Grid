//
//  ValidationHelper.h
//  Grid
//
//  Created by ChunTa Chen on 2017/6/4.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vm.h>
#import <Foundation/Foundation.h>

static NSString* getPlatformSerialNumber( void ) {
    io_registry_entry_t     rootEntry = IORegistryEntryFromPath( kIOMasterPortDefault, "IOService:/" );
    CFTypeRef serialAsCFString = NULL;
    
    serialAsCFString = IORegistryEntryCreateCFProperty( rootEntry,
                                                       CFSTR(kIOPlatformSerialNumberKey),
                                                       kCFAllocatorDefault,
                                                       0);
    
    IOObjectRelease( rootEntry );
    return (NULL != serialAsCFString) ? (__bridge NSString*)serialAsCFString : nil;
}

static NSDictionary* getCpuIds( void ) {
    NSMutableDictionary*    cpuInfo = [[NSMutableDictionary alloc] init];
    CFMutableDictionaryRef  matchClasses = NULL;
    kern_return_t           kernResult = KERN_FAILURE;
    mach_port_t             machPort;
    io_iterator_t           serviceIterator;
    
    io_object_t             cpuService;
    
    kernResult = IOMasterPort( MACH_PORT_NULL, &machPort );
    if( KERN_SUCCESS != kernResult ) {
        printf( "IOMasterPort failed: %d\n", kernResult );
    }
    
    matchClasses = IOServiceNameMatching( "processor" );
    if( NULL == matchClasses ) {
        printf( "IOServiceMatching returned a NULL dictionary" );
    }
    
    kernResult = IOServiceGetMatchingServices( machPort, matchClasses, &serviceIterator );
    if( KERN_SUCCESS != kernResult ) {
        printf( "IOServiceGetMatchingServices failed: %d\n", kernResult );
    }
    
    while( (cpuService = IOIteratorNext( serviceIterator )) ) {
        CFTypeRef CPUIDAsCFNumber = NULL;
        io_name_t nameString;
        IORegistryEntryGetNameInPlane( cpuService, kIOServicePlane, nameString );
        
        CPUIDAsCFNumber = IORegistryEntrySearchCFProperty( cpuService,
                                                          kIOServicePlane,
                                                          CFSTR( "IOCPUID" ),
                                                          kCFAllocatorDefault,
                                                          kIORegistryIterateRecursively);
        
        if( NULL != CPUIDAsCFNumber ) {
            //NSString* cpuName = [NSString stringWithCString:nameString];
            NSString *cpuName = [NSString stringWithCString:nameString encoding:NSASCIIStringEncoding];
            [cpuInfo setObject:(__bridge NSNumber*)CPUIDAsCFNumber forKey:cpuName];
        }
        
        if( NULL != CPUIDAsCFNumber ) {
            CFRelease( CPUIDAsCFNumber );
        }
    }
    
    IOObjectRelease( serviceIterator );
    
    return cpuInfo;
}
