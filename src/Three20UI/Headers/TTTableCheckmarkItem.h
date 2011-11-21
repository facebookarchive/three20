//
//  TTTableCheckmarkItem.h
//  Three20UI
//
//  Created by Joseph Smith on 4/26/11.
//  Copyright 2011 UWCreations LLC. All rights reserved.
//

#import "Three20UI/TTTableItem.h"

@interface TTTableCheckmarkItem : TTTableItem {
    NSString *text;

    id delegate;
    SEL selector;

    BOOL checked;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, getter=isChecked) BOOL checked;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL selector;

+ (id)itemWithText:(NSString*)text;
+ (id)itemWithText:(NSString*)text delegate:(id)delegate selector:(SEL)selector;

@end
