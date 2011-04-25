//
//  BLServiceController.m
//  BlueLock
//
//  Created by Gordon Willem Klok on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLServiceController.h"


@implementation BLServiceController

- (id)initWithDevice:(IOBluetoothDevice *) device: (double) secondsUntilTimeout
{
    [super init];
    if (self) {
        NSLog(@"initWithDevice");
        deviceOfInterest = device;
        lockScreenAfterSecondsDisconnected = secondsUntilTimeout;
        lastDeviceConnect = [[NSDate alloc] init];
        [lastDeviceConnect retain];
        
        idleTimer = [[HIDIdleTime alloc] init];
        [idleTimer retain];
        
        ssControl = [[ScreenSaverController controller] retain];
        if (!ssControl) {
            NSLog(@"Couldn't acquire screen saver controller!");
        }
                    
        timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)5
                                                    target:self
                                                   selector:@selector(handleTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
        [timer retain];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [ssControl release];
    [timer invalidate];
    timer = nil;
    [idleTimer release];
    
}

- (void)invalidate
{
    [ssControl release];
    [timer invalidate];
    timer = nil;
    [idleTimer release];
}

- (void)handleTimer:(NSTimer *)t
{
    NSLog(@"called");
    if (![self check_connect]) {
        NSLog(@"not connected");
        if (lastDeviceConnect != nil) {
            NSTimeInterval timeInterval = [lastDeviceConnect timeIntervalSinceNow];
            NSLog([NSString stringWithFormat:@"Elapsed time: %f", timeInterval]);
            NSLog([NSString stringWithFormat:@"lockScreenAfterSecondsDisconnected: %f", lockScreenAfterSecondsDisconnected]);
            if (![ssControl screenSaverIsRunning]) {
                int idleTime = [idleTimer idleTimeInSeconds];
                NSLog (@"idle time in seconds: %i", idleTime);
                
                if (fabs(timeInterval) > lockScreenAfterSecondsDisconnected) {
                    if (idleTime > lockScreenAfterSecondsDisconnected ) {
                        NSLog(@"Locking Screen");
                        [ssControl screenSaverStartNow];
                    } else {
                        NSLog(@"Would have locked screen but the user is still around");
                    }
                }
            }
        }
        
    } else {
        if (lastDeviceConnect != nil) {
            [lastDeviceConnect release];
        }
        
        lastDeviceConnect = [[NSDate alloc] init];
        [lastDeviceConnect retain];
        printf("connected\n");
    }
}

- (bool) check_connect
{
    if ([deviceOfInterest remoteNameRequest:nil] == kIOReturnSuccess) {
        return TRUE;
    }
    
    return FALSE;
}

@synthesize lockScreenAfterSecondsDisconnected;
@synthesize deviceOfInterest;
@end
