/*
 * Copyright (c) 2011 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
 * JUMP GIT Repository: https://github.com/seqoy/jump
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Foundation/Foundation.h>

/**
 * \nosubgrouping
 * This class contains an collection of methods to convert different Objective C objects.
 * This is a little versio of this class with a small subset of useful methods to
 * use with 'TTCSS' Classes. See JUMP Framework to retrieve the full version.
 */
@interface TTDataConverter : NSObject {}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Convert Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
/** @name Convert Methods
 */
///@{

/**
 * Take an <b>NSString</b> Object and try to convert to <b>NSNumber</b>.
 * @param anObject An <b>NSString</b> to try to convert.
 * @return Converted object or if an conversion isn't possible will return <b>nil</b>.
 */
+(NSNumber*)convertToNSNumberThisObject:(id)anObject;

///@}
@end

