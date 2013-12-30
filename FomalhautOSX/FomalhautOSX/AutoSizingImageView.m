//
//  AutoSizingImageView.m
//  FomalhautOSX
//
//  Created by User on 12/31/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "AutoSizingImageView.h"

@implementation AutoSizingImageView

- (void)setFrameSize:(NSSize)newSize {
    NSScrollView *scrollView = [self enclosingScrollView];
    if (scrollView) {
        [super setFrameSize:scrollView.frame.size];
    } else {
        [super setFrameSize:newSize];
    }
}

@end
