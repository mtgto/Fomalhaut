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

#import "RoutingHTTPServer+Authorization.h"

extern NSString *const API_ERROR_MESSAGE_KEY;

extern NSString *const API_ERROR_MESSAGE_INVALID_TOKEN;

extern NSString *const API_ERROR_MESSAGE_NEED_TOKEN;

extern NSString *const HTTP_HEADER_CONTENT_TYPE_KEY;

extern NSString *const HTTP_HEADER_CONTENT_TYPE_JSON;

@implementation RoutingHTTPServer (Authorization)

- (void)get:(NSString *)path withRepository:(MTGSessionRepository *)repository withBlock:(AuthorizedRequestHandler)block {
    [self get:path withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSError *error = nil;
        NSString *token = [request param:@"access_token"];
        if (!token) {
            [response setHeader:HTTP_HEADER_CONTENT_TYPE_KEY value:HTTP_HEADER_CONTENT_TYPE_JSON];
            [response setStatusCode:401];
            [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_NEED_TOKEN}
                                                                      options:0
                                                                        error:&error]];
            return;
        }
        MTGSession *session = [repository loadWithToken:token];
        if (!session) {
            [response setHeader:HTTP_HEADER_CONTENT_TYPE_KEY value:HTTP_HEADER_CONTENT_TYPE_JSON];
            [response setStatusCode:400];
            [response respondWithData:[NSJSONSerialization dataWithJSONObject:@{API_ERROR_MESSAGE_KEY: API_ERROR_MESSAGE_INVALID_TOKEN}
                                                                      options:0
                                                                        error:&error]];
        } else {
            block(request, session, response);
        }
    }];
}

@end
