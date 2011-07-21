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

@protocol TTDataPopulatorDelegate
@optional

/**
 * When the Data Populator can't automatically convert some specific type. He will call this method
 * and let you extend the class converting you specific type.
 * @param firstObject is original object that we need to convert.
 * @param firstObjectClass is the class of the original object.
 * @param convertToClass is the class that we need to receive whe converted.
 * @return Should return converted object or <tt>nil</tt> if can't convert.
 */
-(id)tryToConvert:(id)object ofClass:(Class)objectClass toClass:(Class)convertToClass;

@end
