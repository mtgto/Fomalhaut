//
//  MTGSessionRepository.m
//  FomalhautOSX
//
//  Created by User on 3/23/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTGSessionRepository.h"
#import <SSKeychain/SSKeychain.h>

NSString *const SERVICE_NAME = @"FomalhautSession";

// TODO: mutliple session support
NSString *const ACCOUNT_NAME = @"CommonFomalhautAccount";

@implementation MTGSessionRepository

+ (MTGSessionRepository *)sharedInstance {
    static MTGSessionRepository *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (BOOL)store:(MTGSession *)session {
    [self clear];
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:@{@"token": session.token, @"note": session.note ? session.note : [NSNull null]}
                                                   options:0
                                                     error:&error];
    NSString *password = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    if (![SSKeychain setPassword:password forService:SERVICE_NAME account:ACCOUNT_NAME]) {
        DDLogWarn(@"Failed to store a session: token=%@", session.token);
        return NO;
    }
    return YES;
}

- (MTGSession *)loadWithToken:(NSString *)token {
    NSError *error = nil;
    NSArray *accounts = [SSKeychain accountsForService:SERVICE_NAME];
    if ([accounts count]) {
        NSString *account = [accounts firstObject][kSSKeychainAccountKey];
        if ([account isEqualToString:ACCOUNT_NAME]) {
            NSString *password = [SSKeychain passwordForService:SERVICE_NAME account:ACCOUNT_NAME];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[password dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:0
                                                             error:&error];
            if (!json) {
                NSString *token = json[@"token"];
                NSString *note = json[@"note"];
                return [[MTGSession alloc] initWithToken:token note:note];
            } else {
                DDLogWarn(@"Failed to deserialize JSON from keychain: %@", error);
            }
        }
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
