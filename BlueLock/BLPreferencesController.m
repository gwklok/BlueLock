//
//  BLPreferencesController.m
//  BlueLock
//
//

#import "BLPreferencesController.h"
#import <IOBluetooth/IOBluetooth.h>
#import "BLServiceController.h"

@implementation BLPreferencesController

- (id)init
{
    if (![super initWithWindowNibName:@"BLPreferencesWindow"])
        return nil;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)showWindow:(id)sender
{
    if (servControl != nil) {
        [onOffButton setTitle:@"On"];
    } else {
        [onOffButton setTitle:@"Off"];
    }
    [super showWindow:sender];
}

- (void)windowDidLoad
{
}

- (IBAction)changeDevice:(id) sender
{
    NSLog(@"change device");
}

- (IBAction)onOff:(id) sender
{
    if (servControl == nil) {
        [onOffButton setTitle:@"On"];
        NSLog(@"am off");
        
        NSArray * devices = [IOBluetoothDevice pairedDevices];
        //        
        int i;
        char device_name[18];
        IOBluetoothDevice *targetDevice = nil;
        //            
        for (i = 0; i < [devices count]; i++) {
                IOBluetoothDevice *device = [devices objectAtIndex:i];
                NSString * foo = [[device getAddressString] uppercaseString];
        //                
                sprintf(device_name, "%s", [foo UTF8String]);
                NSLog(@"%s", device_name);
                //Iphone: 64-B9-E8-81-81-C0
        //      //moto phone: 00-21-36-ED-B5-21
                if (strcmp(device_name, "00-21-36-ED-B5-21") == 0) {
                    printf("found my target device\n");
                    targetDevice = device;
                    break;
                }
        }
        if (targetDevice != nil) {
            servControl = [[BLServiceController alloc] initWithDevice:targetDevice : 45];
            [servControl retain];
        }
    } else {
        [onOffButton setTitle:@"Off"];
        [servControl invalidate];
        [servControl release];
        servControl = nil;
        NSLog(@"am on");
    }

}

@end
