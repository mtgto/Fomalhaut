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

#import "MTLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MTAuthorizationResponseSerializer.h"
#import "MTAuthorization.h"
#import "MTAuthorizationFailure.h"
#import "MTAuthorizationRepository.h"

extern NSString *const SERVER_ADDRESS_CONFIG_KEY;

typedef NS_ENUM(NSUInteger, LoginState) {
    LoginStateInit,
    LoginStateNeedCode,
};

@interface MTLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *protocolSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (nonatomic) LoginState state;
@end

@implementation MTLoginViewController

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
    self.state = LoginStateInit;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushDone:(id)sender {
    NSString *address = self.addressField.text;
    int port = [self.portField.text intValue];
    BOOL useHTTPS = self.protocolSegmentedControl.selectedSegmentIndex == 1;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    MTAuthorizationResponseSerializer *serializer = [MTAuthorizationResponseSerializer serializer];
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d", useHTTPS ? @"https": @"http", address, port]];
    NSURL *url = [NSURL URLWithString:@"/api/v1/authorizations" relativeToURL:baseURL];
    serializer.baseURL = baseURL;
    manager.responseSerializer = serializer;
    NSDictionary *params;
    switch (self.state) {
        case LoginStateInit:
            params = @{@"note": [[UIDevice currentDevice] name]};
            break;
        case LoginStateNeedCode:
            params = @{@"note": [[UIDevice currentDevice] name], @"secret": self.codeField.text};
            break;
    }
    [manager POST:[url absoluteString]
       parameters:params
          success:^(NSURLSessionDataTask *task, id responseObject) {
              if (responseObject) {
                  if ([responseObject isKindOfClass:[MTAuthorization class]]) {
                      MTAuthorization *auth = (MTAuthorization *)responseObject;
                      MTAuthorizationRepository *repository = [MTAuthorizationRepository sharedInstance];
                      [repository store:auth];
                      [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
                  } else if ([responseObject isKindOfClass:[MTAuthorizationFailure class]]) {
                      // "need a secret"
                      if (self.state == LoginStateInit) {
                          // "Need a secret"
                          self.state = LoginStateNeedCode;
                          [UIView animateWithDuration:0.5
                                           animations:^{
                                               self.codeView.hidden = NO;
                                               self.codeView.alpha = 1.0;
                                           }];
                      } else if (self.state == LoginStateNeedCode) {

                      }
                  }
              }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSString *message = [[NSArray arrayWithObjects:[error localizedFailureReason], [error localizedRecoverySuggestion], nil] componentsJoinedByString:@"\n"];
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [alert show];
          }];
}

- (void)close {
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

- (IBAction)backgroundTap:(id)sender {
    if ([self.addressField isFirstResponder]) {
        [self.addressField resignFirstResponder];
    } else if ([self.portField isFirstResponder]) {
        [self.portField resignFirstResponder];
    } else if ([self.codeField isFirstResponder]) {
        [self.codeField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
