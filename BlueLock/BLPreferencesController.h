//
//  BLPreferencesController.h
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
@class BLServiceController;

@interface BLPreferencesController : NSWindowController {
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *secondsIndicator;
    IBOutlet NSButton *onOffButton;
    IBOutlet NSButton *changeDeviceButton;
    IBOutlet NSSlider *timeTillLockSlider;
    IBOutlet NSPopUpButton *devicePopup;
    NSMutableArray * currentDevices;
}

- (IBAction)changeDevice:(id) sender;
- (IBAction)onOff:(id) sender;
- (IBAction)addDevice:(id) sender;
- (void)populateSelector;
- (IBAction)timeTillLockChanged:(id) sender;
- (void)blServiceChange:(NSNotification *)notification;
- (void)menuSetup;

@end
