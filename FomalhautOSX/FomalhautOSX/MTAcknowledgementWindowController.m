//
//  MTAcknowledgementWindowController.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTAcknowledgementWindowController.h"

@interface MTAcknowledgementWindowController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation MTAcknowledgementWindowController

- (id)init
{
    return [super initWithWindowNibName:@"MTAcknowledgementWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.textView readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"acknowledgements" ofType:@"rtf"]];
}

@end
