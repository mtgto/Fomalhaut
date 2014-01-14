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
    if (url) { // if file is already deleted, url is nil.
        self.url = [url absoluteString];
        self.name = [url lastPathComponent];
    }
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
