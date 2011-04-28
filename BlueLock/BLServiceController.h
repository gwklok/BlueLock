//
//  BLServiceController.h
//  BlueLock
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

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "ScreenSaverControl.h"
#import "HIDIdleTime.h"

@interface BLServiceController : NSObject {
@private
    NSInteger lockScreenAfterSecondsDisconnected;
    NSDate * lastDeviceConnect;
    HIDIdleTime * idleTimer;
    ScreenSaverController *ssControl;
    NSTimer *timer;
    IOBluetoothDevice *deviceOfInterest;
    BOOL currentlyRunning;
    NSThread *connectionThread;
    NSUserDefaults *defaults;
}
// Private methods
- (bool) check_connect;
- (void)handleTimer:(NSTimer *)t;
- (void)threadSetup;

// Public methods
- (void)enable;
- (void)disable;
- (bool)isEnabled;
- (bool)couldRun;

@property (readonly) BOOL isDeviceConnected;                     
@property(copy) IOBluetoothDevice * deviceOfInterest;
@property NSInteger lockScreenAfterSecondsDisconnected;

@end
