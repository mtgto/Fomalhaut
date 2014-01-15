//
//  MTFile.h
//  FomalhautOSX
//
//  Created by User on 1/16/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTNormalBookmark;

@interface MTFile : NSManagedObject

@property (nonatomic) BOOL created;
@property (nonatomic) int16_t state;
@property (nonatomic) NSTimeInterval lastOpened;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t readCount;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * urlBookmark;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic) BOOL isLost;
@property (nonatomic, retain) NSSet *bookmarks;
@end

@interface MTFile (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(MTNormalBookmark *)value;
- (void)removeBookmarksObject:(MTNormalBookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

@end
