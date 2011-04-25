//
//  BlueLockAppDelegate.h
//  BlueLock
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BLPreferencesController;

@interface BlueLockAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    BLPreferencesController * preferencesController;
}

- (IBAction)changePreferences:(id) sender;

@property (assign) IBOutlet NSWindow *window;

@end
