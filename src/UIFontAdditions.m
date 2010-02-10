//
// Copyright 2009-2010 Facebook
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

#import "Three20/UIFontAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Additions.
 */
@implementation UIFont (TTCategory)

/**
 * Gets the height of a line of text with this font.
 *
 * Why this isn't part of UIFont is beyond me. This is the height you would expect to get
 * by calling sizeWithFont.
 *
 * App Store-safe method declaration.
 * Hurrah for broken static code analysis.
 *
 * @return the height of one line of text
 */
- (CGFloat)ttLineHeight {
  return (self.ascender - self.descender) + 1;
}

// Removing due to App Store static analysis bugs. See UIFontAdditions.h
#ifdef DEBUG

/**
 * Gets the height of a line of text with this font.
 *
 * This has been deprecated due to App Store rejections. These are completely unfounded,
 * as there is no ttLineHeight method in UIFont. Alas, there's not much we can do than hope
 * they fix their static analyzer.
 *
 * For now, use ttLineHeight. This method will be compiled out of your release builds,
 * so three20 should be App Store safe when you submit.
 *
 * @return the height of one line of text
 * @deprecated
 */
- (CGFloat)lineHeight {
  return [self ttLineHeight];
}

#endif

@end
