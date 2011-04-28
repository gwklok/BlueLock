//
//  BLServiceController.m
//  BlueLock
//
//Copyright (c) 2011, Gordon Willem Klok <gwk@gwk.ca>
//
//Permission to use, copy, modify, and/or distribute this software for any
//purpose with or without fee is hereby granted, provided that the above
//copyright notice and this permission notice appear in all copies.
//
//THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
//ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
//OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#import "BLServiceController.h"


@implementation BLServiceController

- (id)init
{
    [super init];
    
    if (self) {
        idleTimer = [[HIDIdleTime alloc] init];
        [idleTimer retain];
        
        ssControl = [[ScreenSaverController controller] retain];
        if (!ssControl) {
            return nil;
        }
                    
    
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"NO", @"currentlyRunning",
                                    nil]];
        
        NSString *device_id = nil;
        lockScreenAfterSecondsDisconnected = 45;
        currentlyRunning = [defaults boolForKey:@"currentlyRunning"];
        device_id = [defaults stringForKey:@"deviceID"];
        lockScreenAfterSecondsDisconnected = [defaults doubleForKey:@"lockScreenAfterSecondsDisconnected"];
        
        if (lockScreenAfterSecondsDisconnected < 45) {
            [defaults setInteger:45 forKey:@"lockScreenAfterSecondsDisconnected"];
            [defaults synchronize];
        }
        
        if (device_id == nil) {
            currentlyRunning = NO;
        } else {
            NSArray * devices = [IOBluetoothDevice pairedDevices];
            IOBluetoothDevice *targetDevice = nil;
            //            
            for (id devicesElement in devices) {
                IOBluetoothDevice *device = devicesElement;
                NSString * foo = [[device getAddressString] uppercaseString];
                        
                if ([foo isEqualToString:device_id]) {
                    targetDevice = device;
                    break;
                }
            }
            if (targetDevice != nil) {
                deviceOfInterest = targetDevice;
            } else {
                currentlyRunning = NO;
            }

        }
        if (currentlyRunning) {
            [self enable];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)disable
{
    currentlyRunning = NO;
    [connectionThread cancel];
    [defaults setBool:NO forKey:@"currentlyRunning"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLServiceStatusChange" object:self];
}

- (void)enable
{
    if (deviceOfInterest != nil) {
        if (connectionThread == nil || [connectionThread isCancelled]) {
            connectionThread = [[NSThread alloc] initWithTarget:self 
                                                   selector:@selector(threadSetup) object:nil];
            [connectionThread start];
            [defaults setBool:YES forKey:@"currentlyRunning"];
            [defaults synchronize];
            currentlyRunning = YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLServiceStatusChange" object:self];
    }
}

- (bool)isEnabled
{
    return currentlyRunning;
}

- (bool)couldRun
{
    if (deviceOfInterest == nil)
        return NO;
    return YES;
}

- (void)threadSetup
{
    NSAutoreleasePool* threadPool = [[NSAutoreleasePool alloc] init];
    NSRunLoop * runloop = [NSRunLoop currentRunLoop];
    
    lastDeviceConnect = [NSDate date];
    [lastDeviceConnect retain];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)5
                                             target:self
                                           selector:@selector(handleTimer:)
                                           userInfo:nil
                                            repeats:YES];
    lastDeviceConnect = [NSDate date];
    [lastDeviceConnect retain];
    
    //[timer retain];
    [runloop run];
    
    [timer release];
    [threadPool release];
}

- (void)handleTimer:(NSTimer *)t
{
    
    if ([[NSThread currentThread] isCancelled]) {
        [timer invalidate];
        [lastDeviceConnect release];
        timer = nil;
        [NSThread exit];
    }
    
    if (![self check_connect]) {
#if defined (DEBUG)
        NSLog(@"not connected");
#endif
        if (lastDeviceConnect != nil) {
            NSTimeInterval timeInterval = [lastDeviceConnect timeIntervalSinceNow];
#if defined (DEBUG)
            NSLog([NSString stringWithFormat:@"Elapsed time: %f", timeInterval]);
            NSLog([NSString stringWithFormat:@"lockScreenAfterSecondsDisconnected: %ld",lockScreenAfterSecondsDisconnected]);
#endif
            if (![ssControl screenSaverIsRunning]) {
                int idleTime = [idleTimer idleTimeInSeconds];
#if defined (DEBUG)
                NSLog (@"idle time in seconds: %i", idleTime);
#endif                
                if (fabs(timeInterval) > lockScreenAfterSecondsDisconnected) {
                    if (idleTime > lockScreenAfterSecondsDisconnected ) {
#if defined (DEBUG)
                        NSLog(@"Locking Screen");
#endif
                        [ssControl screenSaverStartNow];
                    } else {
#if defined (DEBUG)
                        NSLog(@"Would have locked screen but the user is still around");
#endif
                    }
                }
            }
        }
        
    } else {
#if defined (DEBUG)
        NSLog(@"connected");
#endif
        if (lastDeviceConnect != nil) {
            [lastDeviceConnect release];
        }
        lastDeviceConnect = [NSDate date];
        [lastDeviceConnect retain];
    }
}

- (bool) check_connect
{
    if ([deviceOfInterest remoteNameRequest:nil] == kIOReturnSuccess) {
        return TRUE;
    }
    
    return FALSE;
}

- (bool) isDeviceConnected
{
    if (currentlyRunning) {
        NSTimeInterval timeInterval = [lastDeviceConnect timeIntervalSinceNow];
        if (timeInterval < 60) {
            return YES;
        }
    }
    return NO;
}

- (void)setDeviceOfInterest:(IOBluetoothDevice *)device
{
    NSString * foo = [[device getAddressString] uppercaseString];
    [defaults setObject:foo forKey:@"deviceID"];
    [defaults synchronize];
    [deviceOfInterest release];
    deviceOfInterest = device;
}

- (void)setLockScreenAfterSecondsDisconnected:(NSInteger)seconds
{
    [defaults setInteger:seconds forKey:@"lockScreenAfterSecondsDisconnected"];
    [defaults synchronize];
    lockScreenAfterSecondsDisconnected = seconds;
}

@synthesize lockScreenAfterSecondsDisconnected;
@synthesize deviceOfInterest;
@end
