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

#import "MTGFile+Addition.h"
#import "MTGUUID.h"
@import Quartz;

@implementation MTGFile (Addition)

- (int16_t)getState {
    int16_t state = MTFileNormal;
    if (self.readCount == 0)
        state |= MTFileUnread;
    if (self.isLost)
        state |= MTFileNotExists;
    return state;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.uuid = [MTGUUID generateUUID];
    self.created = [NSDate timeIntervalSinceReferenceDate];
    self.state = [self getState];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    NSURL *url = [self URLForBookmarkData:self.urlBookmark];
    if (url) { // if file is already deleted, url is nil.
        self.url = [url absoluteString];
        self.name = [url lastPathComponent];
        self.state = [self getState];
    }
}

+ (MTGFile *)createEntityWithURL:(NSURL *)url {
    MTGFile *file = [MTGFile MR_createEntity];
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

#pragma mark - IKImageBrowserItem

- (NSString *)imageUID {
    return self.uuid;
}

- (NSString *)imageRepresentationType {
    if (self.thumbnailData) {
        return IKImageBrowserNSDataRepresentationType;
    } else {
        return IKImageBrowserIconRefPathRepresentationType;
    }
}

- (id)imageRepresentation {
    if (self.thumbnailData) {
        return self.thumbnailData;
    } else {
        return [[NSURL URLWithString:self.url] path];
    }
}

- (NSString *)imageTitle {
    return self.name;
}

@end
