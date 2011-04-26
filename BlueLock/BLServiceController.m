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
        lastDeviceConnect = [[NSDate alloc] init];
        [lastDeviceConnect retain];
        
        idleTimer = [[HIDIdleTime alloc] init];
        [idleTimer retain];
        
        ssControl = [[ScreenSaverController controller] retain];
        if (!ssControl) {
            NSLog(@"Couldn't acquire screen saver controller!");
        }
                    
    
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"NO", @"currentlyRunning",
                                    @"00-21-36-ED-B5-21", @"deviceID",
                                    nil]];
        [defaults retain];
        
        NSString *device_id;
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
            int i;
            IOBluetoothDevice *targetDevice = nil;
            //            
            for (i = 0; i < [devices count]; i++) {
                IOBluetoothDevice *device = [devices objectAtIndex:i];
                NSString * foo = [[device getAddressString] uppercaseString];
                        
                if ([foo isEqualToString:device_id]) {
                    printf("found my target device\n");
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
    NSLog(@"disable called");
    [connectionThread cancel];
    [defaults setDouble:NO forKey:@"currentlyRunning"];
    [defaults synchronize];
    
}

- (void)enable
{
    NSLog(@"enable called");
    if (connectionThread == nil || [connectionThread isCancelled]) {
        connectionThread = [[NSThread alloc] initWithTarget:self 
                                                   selector:@selector(threadSetup) object:nil];
        [connectionThread start];
        [defaults setDouble:YES forKey:@"currentlyRunning"];
        [defaults synchronize];
        currentlyRunning = YES;
    }
}

- (void)threadSetup
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop * runloop = [NSRunLoop currentRunLoop];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)5
                                             target:self
                                           selector:@selector(handleTimer:)
                                           userInfo:nil
                                            repeats:YES];
    [timer retain];
    [runloop run];
    [pool release];
}

- (void)handleTimer:(NSTimer *)t
{
    NSLog(@"called");
    
    if ([[NSThread currentThread] isCancelled]) {
        [timer invalidate];
        [timer release];
        timer = nil;
        [NSThread exit];
    }
    
    if (![self check_connect]) {
        NSLog(@"not connected");
        if (lastDeviceConnect != nil) {
            NSTimeInterval timeInterval = [lastDeviceConnect timeIntervalSinceNow];
            NSLog([NSString stringWithFormat:@"Elapsed time: %f", timeInterval]);
            NSLog([NSString stringWithFormat:@"lockScreenAfterSecondsDisconnected: %ld", lockScreenAfterSecondsDisconnected]);
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

- (bool)isEnabled
{
    return currentlyRunning;
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
    NSLog(@"set lockScreenAfterSecondsDisconnected(%ld)", seconds); 
}

@synthesize lockScreenAfterSecondsDisconnected;
@synthesize deviceOfInterest;
@end
