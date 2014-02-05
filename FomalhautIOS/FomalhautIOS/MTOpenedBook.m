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

#import "MTOpenedBook.h"

@interface MTOpenedBook()

@property (nonatomic, strong) NSUUID *uuid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic) NSUInteger pageCount;

@end

@implementation MTOpenedBook

+ (MTOpenedBook *)bookWithUUID:(NSUUID *)uuid name:(NSString *)name pageCount:(NSUInteger)pageCount {
    MTOpenedBook *book = [[MTOpenedBook alloc] init];
    book.uuid = uuid;
    book.name = name;
    book.pageCount = pageCount;
    return book;
}

@end