//
//  BlueLockAppDelegate.m
//  BlueLock
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlueLockAppDelegate.h"

@implementation BlueLockAppDelegate
#import "BLPreferencesController.h"

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"BL"];
    [statusItem setHighlightMode:YES];
    
}

- (IBAction) changePreferences:(id) sender
{
    if (!preferencesController) {
        NSLog(@"alloc");
         preferencesController = [[BLPreferencesController alloc] init];
    }
    
    [preferencesController showWindow:self];
    
}

@end
