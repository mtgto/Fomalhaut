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

#import "MTGBookmarkOutlineView.h"
#import "MTGNormalBookmark.h"
#import "MTGSmartBookmark.h"

@implementation MTGBookmarkOutlineView

- (NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSInteger row = [self selectedRow];
    if (row >= 0) {
        if ([[self itemAtRow:row] isKindOfClass:[MTGNormalBookmark class]]) {
            return self.normalBookmarkMenu;
        } else if ([[self itemAtRow:row] isKindOfClass:[MTGSmartBookmark class]]) {
            return self.smartBookmarkMenu;
        }
    }
    return nil;
}

@end
