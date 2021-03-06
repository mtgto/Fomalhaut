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

#import "MTGFileViewController.h"
#import "MTGOpenedBook.h"
#import "MTGOpenedBookResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>

@interface MTGFileViewController ()

@property (nonatomic, strong) MTGOpenedBook *book;

@property (nonatomic, strong) CXPhotoBrowser *photoBrowser;

@end

@implementation MTGFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.bookName;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	// Do any additional setup after loading the view.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [MTGOpenedBookResponseSerializer serializer];
    [manager GET:[@"http://localhost:25491/api/v1/books/" stringByAppendingString:[self.bookUUID UUIDString]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.book = responseObject;
             [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSString *message = [[NSArray arrayWithObjects:[error localizedFailureReason], [error localizedRecoverySuggestion], nil] componentsJoinedByString:@"\n"];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)start {
    self.photoBrowser = [[CXPhotoBrowser alloc] initWithDataSource:self delegate:self];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    [self.view addSubview:self.photoBrowser.view];
}

- (void)handleTapGesture:(id)sender {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

#pragma mark - CXPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(CXPhotoBrowser *)photoBrowser
{
    return self.book.pageCount;
}

- (id <CXPhotoProtocol>)photoBrowser:(CXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.book.pageCount) {
        return [CXPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:25491/api/v1/books/%@/image/%lu", [self.bookUUID UUIDString], index]]];
    }
    return nil;
}

#pragma mark - CXPhotoBrowserDelegate

@end
