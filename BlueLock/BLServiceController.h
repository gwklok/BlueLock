//
//  BLServiceController.h
//  BlueLock
//
//  Created by Gordon Willem Klok on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "ScreenSaverControl.h"
#import "HIDIdleTime.h"

@interface BLServiceController : NSObject {
@private
    double lockScreenAfterSecondsDisconnected;
    NSDate * lastDeviceConnect;
    HIDIdleTime * idleTimer;
    ScreenSaverController *ssControl;
    NSTimer *timer;
    IOBluetoothDevice *deviceOfInterest;
}

- (bool) check_connect;
- (void)handleTimer:(NSTimer *)t;

- (id)initWithDevice:(IOBluetoothDevice *) device: (double) secondsUntilTimeout;
- (void)invalidate;
                     
@property(copy) IOBluetoothDevice * deviceOfInterest;
@property double lockScreenAfterSecondsDisconnected;

@end
