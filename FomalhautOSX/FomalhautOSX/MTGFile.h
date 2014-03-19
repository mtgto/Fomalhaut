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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTGNormalBookmark;

@interface MTGFile : NSManagedObject

@property (nonatomic) NSTimeInterval created;
@property (nonatomic) BOOL isLost;
@property (nonatomic) NSTimeInterval lastOpened;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t readCount;
@property (nonatomic) int16_t state;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * urlBookmark;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSSet *bookmarks;
@end

@interface MTGFile (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(MTGNormalBookmark *)value;
- (void)removeBookmarksObject:(MTGNormalBookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

@end
