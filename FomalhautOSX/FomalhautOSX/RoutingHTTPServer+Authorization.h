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

#import "RoutingConnection.h"
#import "MTGSessionRepository.h"
#import "MTGSession.h"
#import <RoutingHTTPServer/RoutingHTTPServer.h>

typedef void (^AuthorizedRequestHandler)(RouteRequest *request, MTGSession *session, RouteResponse *response);

@interface RoutingHTTPServer (Authorization)

- (void)get:(NSString *)path withRepository:(MTGSessionRepository *)repository withBlock:(AuthorizedRequestHandler)block;

@end
