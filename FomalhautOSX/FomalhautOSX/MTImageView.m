//
//  MTImageView.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTImageView.h"

@implementation MTImageView

// You need to override mouseDown: to - mouseUp: be called.
- (void)mouseDown:(NSEvent *)theEvent {
}

- (void)mouseUp:(NSEvent *)theEvent {
    [[self nextResponder] mouseUp:theEvent];
}

@end
