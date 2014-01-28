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

#import "MTHelper.h"

@interface MTHelper()

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSImage *image;

@property (nonatomic, strong) NSString *applicationIdentifier;

@end

@implementation MTHelper

- (id)initWithApplicationIdentifier:(NSString *)applicationIdentifier {
    if (self = [super init]) {
        NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:applicationIdentifier];
        self.name = [[NSFileManager defaultManager] displayNameAtPath:[url path]];
        self.image = [[NSWorkspace sharedWorkspace] iconForFile:[url path]];
        self.applicationIdentifier = applicationIdentifier;
    }
    return self;
}

- (BOOL)isEqual:(id)anObject {
    return [anObject isKindOfClass:[MTHelper class]] && [self.applicationIdentifier isEqualToString:((MTHelper *)anObject).applicationIdentifier];
}

- (NSUInteger)hash {
    return [self.applicationIdentifier hash];
}

@end
