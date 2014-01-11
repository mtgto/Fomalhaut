//
//  MTBookWindowController.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTBookWindowController.h"
#import "MTDocument.h"
#import "MTPage.h"

@interface MTBookWindowController ()
@property (weak) IBOutlet NSImageView *imageView;
@property (strong) NSArray *pages;

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
    self.pages = [document getPages];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.arrayController selectNext:self];
    MTPage *page = [self.arrayController selectedObjects][0];
    if (page) {
        [self.imageView setImage:[page image]];
    }
}

@end
