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

#import "MTFileColumnFormatter.h"
#import "MTFile+Addition.h"

@implementation MTFileColumnFormatter

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
    uint16_t state = (uint16_t)[anObject intValue];
    if (state & MTFileNotExists) {
        [attributes setValue:[NSColor redColor] forKey:NSForegroundColorAttributeName];
        return [[NSAttributedString alloc] initWithString:@"⚠" attributes:attributes];
    } else if (state & MTFileUnread) {
        [attributes setValue:[NSColor greenColor] forKey:NSForegroundColorAttributeName];
        return [[NSAttributedString alloc] initWithString:@"●" attributes:attributes];
    } else {
        return [[NSAttributedString alloc] initWithString:@""];
    }
}

@end
