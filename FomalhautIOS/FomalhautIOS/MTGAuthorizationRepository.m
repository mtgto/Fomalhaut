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

#import "MTGAuthorizationRepository.h"
#import <SSKeychain/SSKeychain.h>

NSString *const SERVICE_NAME = @"FomalhautServer";

@implementation MTGAuthorizationRepository

+ (MTGAuthorizationRepository *)sharedInstance {
    static MTGAuthorizationRepository *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (BOOL)store:(MTGAuthorization *)auth {
    [self clear];
    if (![SSKeychain setPassword:auth.token forService:SERVICE_NAME account:[auth.baseURL absoluteString]]) {
        DDLogWarn(@"Failed to store an authorization: token=%@, url=%@", auth.token, auth.baseURL);
        return NO;
    }
    return YES;
}

- (MTGAuthorization *)load {
    NSArray *accounts = [SSKeychain accountsForService:SERVICE_NAME];
    if ([accounts count]) {
        NSString *account = [accounts firstObject][kSSKeychainAccountKey];
        NSString *password = [SSKeychain passwordForService:SERVICE_NAME account:account];
        return [MTGAuthorization authorizationWithToken:password baseURL:[NSURL URLWithString:account]];
    }
    return nil;
}

- (void)clear {
    for (NSDictionary *keychainAccount in [SSKeychain accountsForService:SERVICE_NAME]) {
        NSError *error = nil;
        if (![SSKeychain deletePasswordForService:SERVICE_NAME account:keychainAccount[kSSKeychainAccountKey] error:&error]) {
            DDLogWarn(@"failed to delete account. %@", error);
        }
    }
}

@end
