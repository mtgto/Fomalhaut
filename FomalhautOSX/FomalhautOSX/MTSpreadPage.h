//
//  MTSpreadPage.h
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

@import Foundation;
#import "MTPage.h"

@interface MTSpreadPage : NSObject

@property (readonly, strong) MTPage *firstPage;

/**
 * It may be nil.
 */
@property (readonly, strong) MTPage *secondPage;

- (id)initWithFirstPage:(MTPage *)firstPage secondPage:(MTPage *)secondPage;

@end
