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
#import "MTSpreadPage.h"

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
    NSArray *pages = [document getPages];
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger count = [pages count];
    for (NSUInteger i=0; i < count;) {
        if (i == 0) {
            MTPage *firstPage = pages[i];
            [array addObject:[[MTSpreadPage alloc] initWithFirstPage:firstPage secondPage:nil]];
            i++;
        } else {
            MTPage *firstPage = pages[i];
            MTPage *secondPage = i+1 < count ? pages[i+1] : nil;
            [array addObject:[[MTSpreadPage alloc] initWithFirstPage:firstPage secondPage:secondPage]];
            i+=2;
        }
    }
    self.pages = array;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.arrayController selectNext:self];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [self.arrayController selectPrevious:self];
}

@end
