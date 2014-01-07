//
//  MTWebServer.m
//  FomalhautOSX
//
//  Created by User on 1/6/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <RoutingHTTPServer/RoutingHTTPServer.h>
#import <GRMustache/GRMustache.h>
#import "MTWebServer.h"
#import "MTFile.h"
#import "MTDocument.h"

@interface MTWebServer()

@property (strong) RoutingHTTPServer *server;
@property (strong) MTFile *selectedFile;
@property (strong) MTDocument *selectedDocument;

@end

@implementation MTWebServer

- (id)init {
    if (self = [super init]) {
        self.server = [[RoutingHTTPServer alloc] init];
        [self.server setPort:25491];
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
            if (!self.selectedFile || ![self.selectedFile.uuid isEqualToString:uuid]) {
                self.selectedFile = [MTFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
                if (self.selectedFile) {
                    DDLogInfo(@"selectedFile uri = %@", self.selectedFile.uri);
                    NSURL *fileURL = [NSURL URLWithString:self.selectedFile.uri];
                    self.selectedDocument = [[NSDocumentController sharedDocumentController] makeDocumentWithContentsOfURL:fileURL ofType:@"zip" error:nil];
                }
            }
            if (self.selectedDocument) {
                NSUInteger count = [self.selectedDocument numberOfPages];
                NSMutableArray *pageIndexes = [NSMutableArray arrayWithCapacity:count];
                for (NSUInteger i=0; i<count; i++) {
                    [pageIndexes addObject:[NSNumber numberWithInteger:i]];
                }
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"book.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"uuid": uuid, @"title": self.selectedFile.name, @"pageIndexes": pageIndexes} error:nil]];
            } else {
                [response setStatusCode:404];
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"404.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"path": [[request url] path]} error:nil]];
            }

        }];
        [self.server get:@"/book/:uuid/:index" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            NSInteger index = [[request param:@"index"] integerValue];
            if (!self.selectedFile || ![self.selectedFile.uuid isEqualToString:uuid]) {
                self.selectedFile = [MTFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
                NSURL *fileURL = [NSURL URLWithString:self.selectedFile.uri];
                self.selectedDocument = [[NSDocumentController sharedDocumentController] makeDocumentWithContentsOfURL:fileURL ofType:@"zip" error:nil];
            }
            if (self.selectedDocument) {
                [response respondWithData:[self.selectedDocument dataOfIndex:index]];
            }

        }];
    }
    return self;
}

- (void)start {
    [self.server start:nil];
}

- (void)stop {
    [self.server stop];
}

@end
