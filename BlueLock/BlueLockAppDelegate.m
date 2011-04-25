//
//  BlueLockAppDelegate.m
//  BlueLock
//
//  Created by Gordon Willem Klok on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlueLockAppDelegate.h"

@implementation BlueLockAppDelegate

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

@end
