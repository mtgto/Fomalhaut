//
//  MTDocument.m
//  FomalhautOSX
//
//  Created by User on 12/29/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTDocument.h"
#import <zipzap/zipzap.h>
#import "NSArray+Function.h"

@interface MTDocument()

@property (nonatomic, strong) ZZArchive *archive;
@property (nonatomic, strong) NSArray *entries;
@property (strong) IBOutlet NSPageController *pageController;

- (NSArray *)getSortedEntries;

@end

@implementation MTDocument

- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.archive = [ZZArchive archiveWithContentsOfURL:url];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MTDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

    [self.pageController setArrangedObjects:[self getSortedEntries]];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}

- (NSArray *)getSortedEntries {
    if (self.entries) {
        return self.entries;
    }
    self.entries = [[self.archive.entries withFilterBlock:^BOOL(id obj) {
        ZZArchiveEntry *entry = (ZZArchiveEntry *)obj;
        return [entry.fileName hasSuffix:@".jpg"] || [entry.fileName hasSuffix:@".png"];
    } mapBlock:^id(id obj) {
        return obj;
    }] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ZZArchiveEntry *entry1 = (ZZArchiveEntry *)obj1;
        ZZArchiveEntry *entry2 = (ZZArchiveEntry *)obj2;
        return [entry1.fileName compare:entry2.fileName options:NSNumericSearch];
    }];
    return self.entries;
}

#pragma -

- (NSUInteger)numberOfPages {
    return [[self getSortedEntries] count];
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    return [[self getSortedEntries][index] data];
}

#pragma mark - NSPageControllerDelegate

- (NSString *)pageController:(NSPageController *)pageController identifierForObject:(id)object {
    return @"imagePageView";
}

- (NSViewController *)pageController:(NSPageController *)pageController viewControllerForIdentifier:(NSString *)identifier {
    return [[NSViewController alloc] initWithNibName:@"MTImagePageView" bundle:nil];
}

-(void)pageController:(NSPageController *)pageController prepareViewController:(NSViewController *)viewController withObject:(id)object {
    // viewControllers may be reused... make sure to reset important stuff like the current magnification factor.

    // Normally, we want to reset the magnification value to 1 as the user swipes to other images. However if the user cancels the swipe, we want to leave the original magnificaiton and scroll position alone.

//    BOOL isRepreparingOriginalView = (self.initialSelectedObject && self.initialSelectedObject == object) ? YES : NO;
//    if (!isRepreparingOriginalView) {
//        [(NSScrollView*)viewController.view setMagnification:1.0];
//    }

    // Since we implement this delegate method, we are reponsible for setting the representedObject.
    ZZArchiveEntry *entry = (ZZArchiveEntry *)object;
    viewController.representedObject = [[NSImage alloc] initWithData:[entry data]];
}

@end
