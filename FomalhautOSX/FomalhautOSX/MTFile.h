//
//  MTFile.h
//  FomalhautOSX
//
//  Created by User on 1/5/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MTFile : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * readCount;
@property (nonatomic, retain) NSDate * created;

@end
