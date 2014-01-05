//
//  MTOSXMainWindowController.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTOSXMainWindowController.h"
#import "MTFile.h"
#import <RoutingHTTPServer/RoutingHTTPServer.h>
#import <GRMustache/GRMustache.h>
#import "MTDocument.h"

@interface MTOSXMainWindowController ()

@property (strong) RoutingHTTPServer *server;
// currently, you can open only one file per session.
@property (strong) MTFile *selectedFile;
@property (strong) MTDocument *selectedDocument;

@end

@implementation MTOSXMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
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
            }
        }];
        [self.server get:@"/book/:uuid" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *uuid = [request param:@"uuid"];
            if (!self.selectedFile || ![self.selectedFile.uuid isEqualToString:uuid]) {
                self.selectedFile = [MTFile MR_findFirstByAttribute:@"uuid" withValue:uuid];
                NSURL *fileURL = [NSURL URLWithString:self.selectedFile.uri];
                self.selectedDocument = [[NSDocumentController sharedDocumentController] makeDocumentWithContentsOfURL:fileURL ofType:@"zip" error:nil];
            }
            if (self.selectedDocument) {
                NSUInteger count = [self.selectedDocument numberOfPages];
                NSMutableArray *pageIndexes = [NSMutableArray arrayWithCapacity:count];
                for (NSUInteger i=0; i<count; i++) {
                    [pageIndexes addObject:[NSNumber numberWithInteger:i]];
                }
                GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"book.html" bundle:[NSBundle mainBundle] error:nil];
                [response respondWithString:[template renderObject:@{@"uuid": uuid, @"title": self.selectedFile.name, @"pageIndexes": pageIndexes} error:nil]];
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
        [self.server start:nil];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.fileArrayController setManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationAll forLocal:NO];
}

- (void)doubleClicked:(NSArray *)selectedObjects {
    for (MTFile *file in selectedObjects) {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL URLWithString:file.uri] display:YES error:nil];
    }

}

@end
