//
//  MTBookmark.h
//  FomalhautOSX
//
//  Created by User on 1/8/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Foundation;

@protocol MTBookmark <NSObject>

- (NSString *)displayName;

- (NSPredicate *)predicate;

@end
