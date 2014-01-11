//
//  MTBookWindowController.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTBookWindowController.h"
#import "MTDocument.h"

@interface MTBookWindowController ()
@property (weak) IBOutlet NSImageView *imageView;

@end

@implementation MTBookWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    MTDocument *document = (MTDocument *)self.document;
    NSImage *image = [[NSImage alloc] initWithData:[document dataOfIndex:0]];
    [self.imageView setImage:image];
}

@end
