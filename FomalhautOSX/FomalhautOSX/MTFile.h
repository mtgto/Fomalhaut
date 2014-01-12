//
//  MTFile.h
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MTFile : NSManagedObject

@property (nonatomic) NSTimeInterval created;
@property (nonatomic) NSTimeInterval lastOpened;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t readCount;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSData * urlBookmark;

@end
