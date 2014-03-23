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

#import <RoutingHTTPServer/RoutingHTTPServer.h>
#import <GRMustache/GRMustache.h>
#import "MTGWebServer.h"
#import "MTGFile.h"
#import "MTGDocument.h"
#import "MTNormalBookmark+Addition.h"
#import "MTGSmartBookmark.h"
#import "NSArray+Function.h"
#import "MTGSession.h"
#import "MTGSessionRepository.h"

NSString *const API_ERROR_MESSAGE_KEY = @"message";

NSString *const API_ERROR_MESSAGE_NOT_FOUND = @"Not found";

NSString *const API_ERROR_MESSAGE_INVALID_PARAM = @"Invalid parameter";

NSString *const API_ERROR_MESSAGE_INVALID_SECRET = @"Invalid secret";

NSString *const API_ERROR_MESSAGE_NEED_SECRET = @"Need a secret";

@interface MTGWebServer()

@property (strong) RoutingHTTPServer *server;
@property (strong) MTGDocument *selectedDocument;
@property (strong) NSDateFormatter *dateFormatter;
@property (strong) MTGSessionRepository *sessionRepository;

/**
 * key is <secret> string.
 */
@property (strong) NSMutableDictionary *unauthorizedSessions;

- (NSSortDescriptor *)sortDescriptorByRequest:(RouteRequest *)request;

- (NSDictionary *)dictionaryWithMTFile:(MTGFile *)file;

@end

@implementation MTGWebServer

- (id)init {
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%S%z" allowNaturalLanguage:NO];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        self.sessionRepository = [MTGSessionRepository sharedInstance];
        self.unauthorizedSessions = [NSMutableDictionary dictionary];
        self.server = [[RoutingHTTPServer alloc] init];
        [self.server setDefaultHeader:@"Server" value:[NSString stringWithFormat:@"Fomalhaut/%@", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]]];
        [self.server get:@"/" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"text/html"];
            NSArray *files = [MTGFile MR_findAll];
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"list.html" bundle:[NSBundle mainBundle] error:nil];
            [response respondWithString:[template renderObject:@{@"items": files} error:nil]];
        }];
        [self.server get:@"/assets/css/:file" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *cssFileName = [request param:@"file"];
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:cssFileName withExtension:nil]];
            if ([cssFileName hasSuffix:@".css"] && data) {
                [response setHeader:@"Content-Type" value:@"text/css"];
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }
        }];
        [self.server get:@"/assets/js/:file" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *jsFileName = [request param:@"file"];
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:jsFileName withExtension:nil]];
            if ([jsFileName hasSuffix:@".js"] && data) {
                [response setHeader:@"Content-Type" value:@"application/javascript"];
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }
        }];
        [self.server get:@"/assets/fonts/:file" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *fontFileName = [request param:@"file"];
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:fontFileName withExtension:nil]];
            if ([fontFileName hasSuffix:@".woff"] && data) {
                [response setHeader:@"Content-Type" value:@"application/x-font-woff"];
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }
        }];
        [self.server get:@"/book/:uuid" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            MTGFile *selectedFile = [MTGFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
            if (selectedFile) {
                NSURL *fileURL = [NSURL URLWithString:selectedFile.url];
                NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
                self.selectedDocument = [documentController makeDocumentWithContentsOfURL:fileURL ofType:[documentController typeForContentsOfURL:fileURL error:nil] error:nil];
                selectedFile.readCount++;
                selectedFile.lastOpened = [NSDate timeIntervalSinceReferenceDate];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
            if (self.selectedDocument) {
                NSUInteger count = [self.selectedDocument numberOfPages];
                NSMutableArray *pageIndexes = [NSMutableArray arrayWithCapacity:count];
                for (NSUInteger i=0; i<count; i++) {
                    [pageIndexes addObject:[NSNumber numberWithInteger:i]];
                }
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"book.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"uuid": uuid, @"title": selectedFile.name, @"pageIndexes": pageIndexes} error:nil]];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }

        }];
        [self.server get:@"/book/:uuid/:index" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            NSInteger index = [[request param:@"index"] integerValue];
            MTGFile *selectedFile = [MTGFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
            NSURL *fileURL = [NSURL URLWithString:selectedFile.url];
            NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
            self.selectedDocument = [documentController makeDocumentWithContentsOfURL:fileURL ofType:[documentController typeForContentsOfURL:fileURL error:nil] error:nil];
            CGSize screenSize = CGSizeZero;
            NSString *requestCookieHeader = [request header:@"Cookie"];
            if (requestCookieHeader) {
                NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:@{@"Set-Cookie": [request header:@"Cookie"]} forURL:[request url]];
                for (NSHTTPCookie *cookie in cookies) {
                    if ([[cookie name] isEqualToString:@"screen"]) {
                        NSArray *components = [[[cookie value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                        if ([components count] == 2) {
                            screenSize = CGSizeMake([components[0] floatValue], [components[1] floatValue]);
                        }
                        break;
                    }
                }
            }
            NSData *data;
            if (screenSize.width > 0 && screenSize.height > 0) {
                data = [self.selectedDocument dataOfIndex:index withSize:screenSize];
            } else {
                data = [self.selectedDocument dataOfIndex:index];
            }
            if (self.selectedDocument && data) {
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }

        }];
        [self.server post:@"/api/v1/authorizations" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
            NSDictionary *params = [self dictionaryWithPostData:request.body];
            NSString *secret = params[@"secret"];
            NSError *error = nil;
            if (secret) {
                MTGSession *session = self.unauthorizedSessions[secret];
                if (session) {
                    [self.sessionRepository store:session];
                    [response setStatusCode:201];
                    [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{@"token": session.token}
                                                                              options:0
                                                                                error:&error]];
                } else {
                    [response setStatusCode:400];
                    [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_INVALID_SECRET}
                                                                              options:0
                                                                                error:&error]];
                }
            } else {
                NSString *secret = [NSString stringWithFormat:@"%04d", arc4random() % 10000];
                NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x", arc4random_uniform(0xfffffffu), arc4random_uniform(0xfffffffu), arc4random_uniform(0xfffffffu), arc4random_uniform(0xfffffffu)];
                MTGSession *session = [[MTGSession alloc] initWithToken:token note:params[@"note"]];
                self.unauthorizedSessions[secret] = session;
                [response setStatusCode:401];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NEED_SECRET}
                                                                          options:0
                                                                            error:&error]];
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERT_SECRET_TITLE_FORMAT", nil), session.note, secret];
                [self performSelectorOnMainThread:@selector(showAlertWithMessage:) withObject:message waitUntilDone:NO];
            }
        }];
        [self.server get:@"/api/v1/bookmarks" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSError *error = nil;
            [response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
            NSString *token = [request param:@"access_token"];
            if (![self.sessionRepository loadWithToken:token]) {
                [response setStatusCode:401];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_INVALID_SECRET}
                                                                          options:0
                                                                            error:&error]];
            } else {
                NSArray *normalBookmarks = [[MTGNormalBookmark MR_findAllSortedBy:@"name" ascending:YES] mapWithBlocks:^id(id obj) {
                    MTGNormalBookmark *bookmark = (MTGNormalBookmark *)obj;
                    NSDate *created = [NSDate dateWithTimeIntervalSinceReferenceDate:bookmark.created];
                    return @{@"uuid": bookmark.uuid,
                             @"name": bookmark.name,
                             @"type": @"normal",
                             @"created": [self.dateFormatter stringFromDate:created]};
                }];
                NSArray *smartBookmarks = [[MTGSmartBookmark MR_findAllSortedBy:@"name" ascending:YES] mapWithBlocks:^id(id obj) {
                    MTGSmartBookmark *bookmark = (MTGSmartBookmark *)obj;
                    return @{@"uuid": bookmark.uuid,
                             @"name": bookmark.name,
                             @"type": @"smart",
                             @"created": [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:bookmark.created]]};
                }];
                NSError *error = nil;
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:[normalBookmarks arrayByAddingObjectsFromArray:smartBookmarks]
                                                                          options:0
                                                                            error:&error]];
            }
        }];
        [self.server get:@"/api/v1/bookmarks/:uuid" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
            NSString *uuid = [request param:@"uuid"];
            NSSortDescriptor *sortDescriptor = [self sortDescriptorByRequest:request];
            if (!sortDescriptor) {
                [response setStatusCode:400];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_INVALID_PARAM} options:0 error:nil]];
                return;
            }
            NSArray *files = nil;
            NSString *name = nil;
            MTGNormalBookmark *normalBookmark = [MTGNormalBookmark MR_findFirstByAttribute:@"uuid" withValue:uuid];
            if (normalBookmark) {
                files = [[normalBookmark entries] sortedArrayUsingDescriptors:@[sortDescriptor]];
                name = normalBookmark.name;
            } else {
                MTGSmartBookmark *smartBookmark = [MTGSmartBookmark MR_findFirstByAttribute:@"uuid" withValue:uuid];
                if (smartBookmark) {
                    files = [MTGFile MR_findAllSortedBy:sortDescriptor.key ascending:sortDescriptor.ascending withPredicate:smartBookmark.predicate];
                    name = smartBookmark.name;
                }
            }
            if (files) {
                files = [files mapWithBlocks:^id(id obj) {
                    return [self dictionaryWithMTFile:(MTGFile *)obj];
                }];
                NSDictionary *dic = @{@"uuid": uuid,
                                      @"name": name,
                                      @"books": files};
                NSError *error = nil;
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:&error]];
            } else {
                [response setStatusCode:404];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NOT_FOUND} options:0 error:nil]];
            }
        }];
        [self.server get:@"/api/v1/books/all" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
            NSSortDescriptor *sortDescriptor = [self sortDescriptorByRequest:request];
            if (!sortDescriptor) {
                [response setStatusCode:400];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_INVALID_PARAM} options:0 error:nil]];
                return;
            }
            NSArray *files = [[MTGFile MR_findAllSortedBy:sortDescriptor.key ascending:sortDescriptor.ascending] mapWithBlocks:^id(id obj) {
                return [self dictionaryWithMTFile:(MTGFile *)obj];
            }];
            NSError *error = nil;
            [response respondWithData:[NSJSONSerialization dataWithJSONObject:files options:0 error:&error]];
        }];
        [self.server get:@"/api/v1/books/:uuid" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
            NSString *uuid = [request param:@"uuid"];
            MTGFile *selectedFile = [MTGFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
            if (selectedFile) {
                NSURL *fileURL = [NSURL URLWithString:selectedFile.url];
                NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
                self.selectedDocument = [documentController makeDocumentWithContentsOfURL:fileURL ofType:[documentController typeForContentsOfURL:fileURL error:nil] error:nil];
                selectedFile.readCount++;
                selectedFile.lastOpened = [NSDate timeIntervalSinceReferenceDate];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
            if (self.selectedDocument) {
                NSUInteger count = [self.selectedDocument numberOfPages];
                NSDictionary *dic = [self dictionaryWithMTFile:selectedFile pageCount:count];
                NSError *error = nil;
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:&error]];
            } else {
                [response setStatusCode:404];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NOT_FOUND} options:0 error:nil]];
            }
        }];
        [self.server get:@"/api/v1/books/:uuid/thumbnail" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            MTGFile *selectedFile = [MTGFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
            NSData *data = selectedFile.thumbnailData;
            if (data) {
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NOT_FOUND} options:0 error:nil]];
            }
        }];
        [self.server get:@"/api/v1/books/:uuid/image/:index" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            NSInteger index = [[request param:@"index"] integerValue];
            MTGFile *selectedFile = [MTGFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
            NSURL *fileURL = [NSURL URLWithString:selectedFile.url];
            NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
            self.selectedDocument = [documentController makeDocumentWithContentsOfURL:fileURL ofType:[documentController typeForContentsOfURL:fileURL error:nil] error:nil];
            CGSize screenSize = CGSizeZero;
            screenSize.width = [[request param:@"width"] intValue];
            screenSize.height = [[request param:@"height"] intValue];
            NSData *data;
            if (screenSize.width > 0 && screenSize.height > 0) {
                data = [self.selectedDocument dataOfIndex:index withSize:screenSize];
            } else {
                data = [self.selectedDocument dataOfIndex:index];
            }
            if (self.selectedDocument && data) {
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
                [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NOT_FOUND} options:0 error:nil]];
            }
        }];
    }
    return self;
}

- (NSSortDescriptor *)sortDescriptorByRequest:(RouteRequest *)request {
    NSString *sort = [request param:@"sort"];
    if (!sort) {
        sort = @"name";
    } else {
        sort = @{@"name": @"name", @"read_count": @"readCount", @"last_opened": @"lastOpened", @"created": @"created"}[sort];
    }
    if (!sort) {
        DDLogInfo(@"Invalid sort parameter is selected: %@", [request param:@"sort"]);
        return nil;
    }
    NSString *direction = [request param:@"direction"];
    BOOL isAsc;
    if (!direction || [direction isEqualToString:@"asc"]) {
        isAsc = YES;
    } else if ([direction isEqualToString:@"desc"]) {
        isAsc = NO;
    } else {
        DDLogInfo(@"Invalid sort direction is selected: %@", direction);
        return nil;
    }
    return [NSSortDescriptor sortDescriptorWithKey:sort ascending:isAsc];
}

- (NSDictionary *)dictionaryWithMTFile:(MTGFile *)file {
    return @{@"uuid": file.uuid,
             @"name": file.name,
             @"readCount": @(file.readCount),
             @"isLost": @(file.isLost),
             @"memo": file.memo ? file.memo : [NSNull null],
             @"lastOpened": file.lastOpened ? [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:file.lastOpened]] : [NSNull null],
             @"created": [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:file.created]]};
}

- (NSDictionary *)dictionaryWithMTFile:(MTGFile *)file pageCount:(NSUInteger)pageCount {
    return @{@"uuid": file.uuid,
             @"name": file.name,
             @"readCount": @(file.readCount),
             @"pageCount": @(pageCount),
             @"isLost": @(file.isLost),
             @"memo": file.memo ? file.memo : [NSNull null],
             @"lastOpened": file.lastOpened ? [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:file.lastOpened]] : [NSNull null],
             @"created": [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:file.created]]};
}

- (BOOL)start:(UInt16)port error:(NSError *__autoreleasing*)error {
    [self.server setPort:port];
    return [self.server start:error];
}

- (void)stop {
    [self.server stop];
}

- (NSDictionary *)dictionaryWithPostData:(NSData *)data {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *elements = [obj componentsSeparatedByString:@"="];
        dict[[elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)showAlertWithMessage:(NSString *)message {
    NSAlert *alert = [NSAlert alertWithMessageText:nil defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
    [alert runModal];
}

@end
