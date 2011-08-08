/*
 * Copyright (c) 2011 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
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

#import "extThree20CSSStyle/TTCSSRuleSet.h"

/**
 * TTCSSApplyProtocol defines an common interface to classes that style itself
 * using CSS readed properties. This classes should implement this protocol
 * and his appropriate methods.
 */
@protocol TTCSSApplyProtocol
@required

/**
 * Receive an Set of Rules from some CSS selector to apply. This method
 * receive an TTCSSRuleSet with all properties ready to be set.
 */
-(void)applyCssRules:(TTCSSRuleSet*)anRuleSet;

/**
 * Set a CSS stylesheet selector.
 */
- (void)applyCssSelector:(NSString *)selector;

@end
