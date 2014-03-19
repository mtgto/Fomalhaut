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

#import "MTGPage.h"

@implementation MTGPage

- (NSString *)fileName {
    DDLogError(@"You need to implement `- (NSString *)fileName`.");
    return nil;
}

- (NSData *)data {
    DDLogError(@"You need to implement `- (NSData *)data`.");
    return nil;
}

- (NSImage *)image {
    DDLogError(@"You need to implement `- (NSImage *)image`.");
    return nil;
}

@end
