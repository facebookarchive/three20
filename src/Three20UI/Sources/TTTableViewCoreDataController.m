//
//  TTTableViewCoreDataController.m
//  Three20UI
//
//  Created by Matthew Newberry on 3/28/11.
//  Copyright 2011 MNDCreative, LLC. All rights reserved.
//

#import "TTTableViewCoreDataController.h"

@implementation TTTableViewCoreDataController

- (void) modelDidStartLoad:(id <TTModel>)model{
    
    [super modelDidStartLoad:model];
    
    _isLoading = YES;
}

- (void) modelDidFinishLoad:(id<TTModel>)model{
    
    [super modelDidFinishLoad:model];
    
    _isLoading = NO;
}

- (void) modelDidBeginUpdates:(id<TTModel>)model{
    
    [super modelDidBeginUpdates:model];
    
    _isLoading = YES;
}

- (void) modelDidEndUpdates:(id<TTModel>)model{
    
    [super modelDidEndUpdates:model];
    
    _isLoading = NO;
}

- (void) updateView{
    
    if(_isLoading)
        return;
    
    [super updateView];
}

@end
