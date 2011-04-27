//
//  BLPreferencesController.m
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

#import "BLPreferencesController.h"
#import <IOBluetooth/IOBluetooth.h>
#import "BLServiceController.h"
#import "BlueLockAppDelegate.h"

@implementation BLPreferencesController

- (id)init
{
    if (![super initWithWindowNibName:@"BLPreferencesWindow"])
        return nil;
    
    if ([servControl isEnabled]) {
        [onOffButton setTitle:@"On"];
    } else {
        [onOffButton setTitle:@"Off"];
    }

    currentDevices = [[NSMutableArray alloc] init];
    [currentDevices retain];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)addDevice:(id) sender
{ 
    [[NSWorkspace sharedWorkspace] launchApplication:@"/System/Library/CoreServices/Bluetooth Setup Assistant.app"];
}

- (void)populateSelector
{
    int i;
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    IOBluetoothDevice *currentDevice;
    
    currentDevice = [servControl deviceOfInterest];
    NSString *device_id = nil;
    if (currentDevice != nil) {
        device_id = [[currentDevice getAddressString] uppercaseString];
    }
    
    [devicePopup removeAllItems];
    [currentDevices removeAllObjects];
    
    //            
    for (i = 0; i < [devices count]; i++) {
        IOBluetoothDevice *device = [devices objectAtIndex:i];
        NSString * deviceAddr = [[device getAddressString] uppercaseString];
        NSString * deviceName = [device getNameOrAddress];
        
        [currentDevices addObject:device];
        [devicePopup addItemWithTitle:deviceName];
        
        if (device_id != nil) {
            if ([deviceAddr isEqualToString:device_id]) {
                [devicePopup selectItemAtIndex:i];
            }
        }
        
    }

}

- (IBAction)showWindow:(id)sender
{
    if ([servControl isEnabled]) {
        [onOffButton setTitle:@"On"];
    } else {
        [onOffButton setTitle:@"Off"];
    }
    [self populateSelector];
    [secondsIndicator setIntegerValue:[servControl lockScreenAfterSecondsDisconnected]];
    [window setLevel:kCGDesktopWindowLevel + 1];
    [super showWindow:sender];
}

- (void)windowDidLoad
{
    if ([servControl isEnabled]) {
        [onOffButton setTitle:@"On"];
    } else {
        [onOffButton setTitle:@"Off"];
    }
    [self populateSelector];
    [timeTillLockSlider setIntegerValue:[servControl lockScreenAfterSecondsDisconnected]];
    [secondsIndicator setIntegerValue:[servControl lockScreenAfterSecondsDisconnected]];
    
}

- (IBAction)timeTillLockChanged:(id) sender
{
    NSInteger ttl; 
    ttl = [timeTillLockSlider integerValue];
    [servControl setLockScreenAfterSecondsDisconnected:ttl];
    [secondsIndicator setIntegerValue:ttl];
}

- (IBAction)changeDevice:(id) sender
{
    NSInteger which;
    IOBluetoothDevice *currentDevice, *selectedDevice;
    
    which = [devicePopup indexOfSelectedItem];
    currentDevice = [servControl deviceOfInterest];
    selectedDevice = [currentDevices objectAtIndex:which];
    NSString *curDeviceID, *selDeviceID;
    curDeviceID = [[currentDevice getAddressString] uppercaseString];
    selDeviceID = [[selectedDevice getAddressString] uppercaseString];
    if (![curDeviceID isEqualToString:selDeviceID]) {
        [servControl setDeviceOfInterest:selectedDevice];
    }
}

- (IBAction)onOff:(id) sender
{
    if ([servControl isEnabled]) {
        [onOffButton setTitle:@"Off"];
        [servControl disable];
    } else {
        [onOffButton setTitle:@"On"];
        [servControl enable];
    }

}

@end
