//
//  BLPreferencesController.h
//  BlueLock
//
//  Copyright 2011 Gordon Willem Klok. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLServiceController;

@interface BLPreferencesController : NSWindowController {
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *deviceLabel;
    IBOutlet NSButton *onOffButton;
    IBOutlet NSButton *changeDeviceButton;
    IBOutlet NSSlider *timeTillLockSlider;
    BLServiceController *servControl;
}

- (IBAction)changeDevice:(id) sender;
- (IBAction)onOff:(id) sender;

@end
