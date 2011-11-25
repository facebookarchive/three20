//
//  TTTableViewGroupedCheckmarkDelegate.m
//  Three20UI
//
//  Created by Roberto Miranda on 21/11/11.
//  Copyright 2011 UC3M. All rights reserved.
//

#import "TTTableViewGroupedCheckmarkDelegate.h"

#import "Three20UI/TTTableViewController.h"

#import "Three20UI/TTListDataSource.h"
#import "Three20UI/TTSectionedDataSource.h"

#import "Three20UI/TTTableCheckmarkItem.h"
#import "Three20UI/TTTableCheckmarkCell.h"

@implementation TTTableViewGroupedCheckmarkDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath {

    [super tableView:tableView didSelectRowAtIndexPath:anIndexPath];

    id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;

    NSInteger section = anIndexPath.section;

    NSInteger rowsInSection = [dataSource tableView:tableView numberOfRowsInSection:section];
    for (NSInteger row = 0; row < rowsInSection; row++)
    {
        //NSLog(@"analizing row:%d in section:%d", row, section);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];

        id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

        if ([object isKindOfClass:[TTTableCheckmarkItem class]])
        {

            TTTableCheckmarkItem *item = (TTTableCheckmarkItem*)object;
            item.checked = (anIndexPath.row == indexPath.row);
            TTTableCheckmarkCell *cell =
            (TTTableCheckmarkCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell layoutSubviews];

        }
    }
}

@end
