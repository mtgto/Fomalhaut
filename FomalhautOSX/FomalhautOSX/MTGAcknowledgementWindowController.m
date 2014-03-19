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

#import "MTGAcknowledgementWindowController.h"

@interface MTGAcknowledgementWindowController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation MTGAcknowledgementWindowController

- (id)init
{
    return [super initWithWindowNibName:@"MTGAcknowledgementWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.textView readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"acknowledgements" ofType:@"rtf"]];
}

@end
