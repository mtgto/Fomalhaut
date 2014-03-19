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

#import "MTGBookCollectionViewController.h"
#import "MTGBook.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MTGFileViewController.h"

@interface MTGBookCollectionViewController ()

@end

@implementation MTGBookCollectionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.books count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"BookCollectionCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    MTGBook *book = self.books[indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    label.text = book.name;
    NSURL *thumbnailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:25491/api/v1/books/%@/thumbnail", [book.uuid UUIDString]]];
    DDLogInfo(@"thumbnail = %@", [thumbnailURL absoluteString]);
    [imageView setImageWithURL:thumbnailURL];
    //[cell setImage:[_objects objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MTGFileViewController *viewController = [segue destinationViewController];
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    MTGBook *book = ((MTGBook *)self.books[indexPath.row]);
    viewController.bookUUID = book.uuid;
    viewController.bookName = book.name;
}

@end
