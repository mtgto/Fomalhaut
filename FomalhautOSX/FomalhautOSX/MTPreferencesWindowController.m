//
//  MTPreferencesWindowController.m
//  FomalhautOSX
//
//  Created by User on 1/9/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTPreferencesWindowController.h"

extern NSString *const SERVER_INT_PORT_CONFIG_KEY;
extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;
extern NSString *const SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY;

@interface MTPreferencesWindowController ()

@end

@implementation MTPreferencesWindowController

- (id)init
{
    return [super initWithWindowNibName:@"MTPreferencesWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
