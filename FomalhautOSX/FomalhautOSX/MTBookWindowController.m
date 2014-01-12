/*
 Fomalhaut
 Copyright (C) 2014 mtgto

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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

- (void)keyDown:(NSEvent *)theEvent
{
    switch ([[theEvent charactersIgnoringModifiers] characterAtIndex:0]) {
        case NSUpArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            [self.arrayController selectPrevious:self];
            break;
        case NSDownArrowFunctionKey:
        case NSRightArrowFunctionKey:
        case 0x20: // space
            [self.arrayController selectNext:self];
            break;
        default:
            break;
    }
    
}

@end
