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

@interface MTOSXMainWindowController ()

@property (strong) RoutingHTTPServer *server;

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
        [self.server get:@"/hello/:name" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"text/plain"];
            [response respondWithString:[NSString stringWithFormat:@"Hello %@!", [request param:@"name"]]];
        }];
        [self.server get:@"/" withBlock:^(RouteRequest *request, RouteResponse *response) {
            [response setHeader:@"Content-Type" value:@"text/html"];
            NSArray *files = [MTFile MR_findAll];
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"list.html" bundle:[NSBundle mainBundle] error:nil];
            [response respondWithString:[template renderObject:@{@"items": files} error:nil]];
        }];
        [self.server get:@"/assets/css/:file" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *cssFileName = [request param:@"file"];
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:cssFileName withExtension:@"css"]];
            if ([cssFileName hasSuffix:@"css"] && data) {
                [response setHeader:@"Content-Type" value:@"text/css"];
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
            }
        }];
        [self.server get:@"/assets/js/:file" withBlock:^(RouteRequest *request, RouteResponse *response) {
            NSString *cssFileName = [request param:@"file"];
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:cssFileName withExtension:@"js"]];
            if ([cssFileName hasSuffix:@"js"] && data) {
                [response setHeader:@"Content-Type" value:@"application/javascript"];
                [response respondWithData:data];
            } else {
                [response setStatusCode:404];
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
