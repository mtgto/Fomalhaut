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
#import "MTWebServer.h"
#import "MTFile.h"
#import "MTDocument.h"

@interface MTWebServer()

@property (strong) RoutingHTTPServer *server;
@property (strong) MTDocument *selectedDocument;

@end

@implementation MTWebServer

- (id)init {
    if (self = [super init]) {
        self.server = [[RoutingHTTPServer alloc] init];
        [self.server setDefaultHeader:@"Server" value:@"Fomalhaut/1.0"];
        [self.server get:@"/" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"text/html"];
            NSArray *files = [MTFile MR_findAll];
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
            MTFile *selectedFile = [MTFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
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
            MTFile *selectedFile = [MTFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
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
    }
    return self;
}

- (BOOL)start:(UInt16)port error:(NSError *__autoreleasing*)error {
    [self.server setPort:port];
    return [self.server start:error];
}

- (void)stop {
    [self.server stop];
}

@end
