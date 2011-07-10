//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
