//
//  MTBookmarkUnread.h
//  FomalhautOSX
//
//  Created by User on 1/8/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

@import Foundation;
#import "MTBookmark.h"

@interface MTBookmarkUnread : NSObject<MTBookmark>

+ (MTBookmarkUnread *)sharedInstance;

@end
