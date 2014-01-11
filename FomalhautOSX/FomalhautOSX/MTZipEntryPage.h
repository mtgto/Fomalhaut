//
//  MTZipEntryPage.h
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTPage.h"
#import <zipzap/zipzap.h>

@interface MTZipEntryPage : MTPage

- (id)initWithZipEntry:(ZZArchiveEntry *)entry;

@end
