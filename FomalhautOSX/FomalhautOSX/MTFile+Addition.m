//
//  MTFile+Addition.m
//  FomalhautOSX
//
//  Created by User on 1/5/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTFile+Addition.h"
#import "MTUUID.h"

@implementation MTFile (Addition)

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.uuid = [MTUUID generateUUID];
    self.created = [NSDate timeIntervalSinceReferenceDate];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    NSURL *url = [self URLForBookmarkData:self.urlBookmark];
    self.url = [url absoluteString];
    self.name = [url lastPathComponent];
}

+ (MTFile *)createEntityWithURL:(NSURL *)url {
    MTFile *file = [MTFile MR_createEntity];
    file.name = [url lastPathComponent];
    file.url = [url absoluteString];
    file.urlBookmark = [file bookmarkDataForURL:url];
    return file;
}

- (NSData *)bookmarkDataForURL:(NSURL *)url {
    NSError *error = nil;
    NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&error];
    if (error || (bookmark == nil)) {
        DDLogWarn(@"failed to convert URL %@ to data: %@", url, error);
        return nil;
    }
    DDLogInfo(@"bookmark size: %lu", [bookmark length]);
    return bookmark;
}

- (NSURL *)URLForBookmarkData:(NSData *)bookmark {
    BOOL bookmarkIsStale = NO;
    NSError* error = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&error];
    if (error != nil) {
        DDLogWarn(@"failed to convert URL from data: %@", error);
        return nil;
    } else if (bookmarkIsStale) {
        DDLogInfo(@"bookmarkIsStale. %@", bookmarkURL);
    }
    return bookmarkURL;
}

@end
