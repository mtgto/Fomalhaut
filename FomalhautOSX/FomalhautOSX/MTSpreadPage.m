//
//  MTSpreadPage.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTSpreadPage.h"

@interface MTSpreadPage()

@property (strong) MTPage *firstPage;

@property (strong) MTPage *secondPage;

@end

@implementation MTSpreadPage

- (id)initWithFirstPage:(MTPage *)firstPage secondPage:(MTPage *)secondPage {
    if (self = [super init]) {
        self.firstPage = firstPage;
        self.secondPage = secondPage;
    }
    return self;
}

@end
