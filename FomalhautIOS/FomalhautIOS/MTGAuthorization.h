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

#import <Foundation/Foundation.h>

@interface MTGAuthorization : NSObject

/**
 * Server base URL.
 *
 * Example: http://192.168.0.1:25491
 */
@property (nonatomic, readonly) NSURL *baseURL;

@property (nonatomic, readonly, copy) NSString *token;

+ (MTGAuthorization *)authorizationWithToken:(NSString *)token baseURL:(NSURL *)url;

@end
