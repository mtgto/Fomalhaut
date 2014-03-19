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

#import "MTGBookmarkTabBarController.h"
#import <AFNetworking/AFNetworking.h>
#import "MTGBookListResponseSerializer.h"
#import "MTGBookListViewController.h"
#import "MTGBookCollectionViewController.h"
#import "MTGAuthorizationRepository.h"

@interface MTGBookmarkTabBarController ()

@property (nonatomic, strong) NSArray *books;

@end

@implementation MTGBookmarkTabBarController

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
	// Do any additional setup after loading the view.
    self.title = self.bookmark.name;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [MTGBookListResponseSerializer serializer];
    [manager GET:[[NSURL URLWithString:[@"/api/v1/bookmarks/" stringByAppendingString:[self.bookmark.uuid UUIDString]] relativeToURL:self.auth.baseURL] absoluteString]
      parameters:@{@"access_token": self.auth.token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.books = responseObject;
             MTGBookListViewController *bookListViewController = self.viewControllers[0];
             MTGBookCollectionViewController *bookCollectionViewController = self.viewControllers[1];
             bookListViewController.books = responseObject;
             bookCollectionViewController.books = responseObject;
             [bookListViewController.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             [bookCollectionViewController.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

- (IBAction)styleChanged:(id)sender {
    self.selectedIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
}

@end
