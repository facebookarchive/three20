//
//  TableCheckmarkController.m
//  TTCatalog
//
//  Created by Roberto Miranda on 21/11/11.
//  Copyright 2011 UC3M. All rights reserved.
//

#import "TableCheckmarkController.h"


@implementation TableCheckmarkController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.variableHeightRows = YES;
        self.tableViewStyle = UITableViewStyleGrouped;
        
        self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                           @"Checkmarks",
                           [TTTableCheckmarkItem itemWithText:@"Item 1"
                                                     delegate:nil
                                                     selector:nil],
                           [TTTableCheckmarkItem itemWithText:@"Item 2"],
                           [TTTableCheckmarkItem itemWithText:@"Item 3"],
                           nil];
                           
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTTableViewDelegate>) createDelegate {
    
    TTTableViewGroupedCheckmarkDelegate *delegate = [[TTTableViewGroupedCheckmarkDelegate alloc] initWithController:self];
    
    return [delegate autorelease];
}

@end
