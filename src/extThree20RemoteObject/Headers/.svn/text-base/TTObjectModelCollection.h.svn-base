//
// Copyright 2012 RIKSOF
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

#import "TTObjectModel.h"
#import "TTRemoteObject.h"

/**
 * Parent class for all model collections that need to get data from server.
 */
@interface TTObjectModelCollection : TTRemoteObject {
        
    /**
     * Array of objects received from the server.
     */
    NSMutableArray *objects;
    
    /**
     * Class of the objects being retrieved.
     */
    Class           objectClass;
    
    /**
     * Parameter that serves as the primary key for this object.
     */
    NSString        *primaryKey;
    
    /**
     * Indicates if we should not reset objects array on new
     * response.
     */
    BOOL            doNotRefresh;
}

@property (nonatomic, strong) NSMutableArray *objects;

// This class' exposed method
-(void)loadWithArray:(NSArray *)data;
-(void)removeObject:(TTObjectModel *)model;
    

@end
