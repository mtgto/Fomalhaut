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

#import "MTBookmarkListResponseSerializer.h"
#import "MTBookmark.h"
#import "NSArray+Function.h"

extern NSString *const APP_ERROR_DOMAIN;

@implementation MTBookmarkListResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    if (error && *error) {
        DDLogInfo(@"error occurred while decoding JSON: %@", *error);
        return nil;
    } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        DDLogError(@"error occurred: %@", *error);
        return nil;
    }
    if (((NSHTTPURLResponse *)response).statusCode == 200 && [responseObject isKindOfClass:[NSArray class]]) {
        return [responseObject mapWithBlocks:^id(id obj) {
            NSDictionary *dict = (NSDictionary *)obj;
            return [MTBookmark bookmarkWithUUID:[[NSUUID alloc] initWithUUIDString:dict[@"uuid"]] name:dict[@"name"]];
        }];
    }
    NSString *errorMessage = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        errorMessage = ((NSDictionary *)responseObject)[@"message"];
    }
    if (!errorMessage) {
        errorMessage = NSLocalizedString(@"ALERT_ERROR_UNKNOWN_TITLE", nil);
    }
    NSString *localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"ALERT_ERROR_FAILED_TO_LOAD_BOOKMARK_LIST_MESSAGE_FORMAT", nil), errorMessage];
    // TODO: more detailed information
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: localizedDescription,
                               NSURLErrorFailingURLErrorKey: [response URL],
                               AFNetworkingOperationFailingURLResponseErrorKey: response};
    if (error) {
        *error = [[NSError alloc] initWithDomain:APP_ERROR_DOMAIN code:NSURLErrorBadServerResponse userInfo:userInfo];
    }

    return nil;
}

@end
