//
//  MTOSXAppDelegate.h
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

@import Foundation;
#import "MTWebServer.h"

@interface MTOSXAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet MTWebServer *server;
@property (weak) IBOutlet NSMenuItem *startServerMenuItem;

@end
