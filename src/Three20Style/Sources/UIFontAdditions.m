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

#import "Three20Style/UIFontAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

static BOOL TTFontTableIsInitialized = NO;
static NSDictionary *TTFontTable = nil;
static NSMutableDictionary *TTFontNameToBaseFont = nil;

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIFontAdditions)

@implementation UIFont (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttLineHeight {
  return (self.ascender - self.descender) + 1;
}

- (NSDictionary *)dictionaryWithNormal:(NSString *)normalName
                                  bold:(NSString *)boldName
                                italic:(NSString *)italicName
                         boldAndItalic:(NSString *)boldAndItalicName {
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
  
  if (normalName != nil) {
    [dict setObject:normalName forKey:@"normal"];
  }
  
  if (boldName != nil) {
    [dict setObject:boldName forKey:@"bold"];
  }
  
  if (italicName != nil) {
    [dict setObject:italicName forKey:@"italic"];
  }
  
  if (boldAndItalicName != nil) {
    [dict setObject:boldAndItalicName forKey:@"boldAndItalic"];
  }
  
  return dict;
}

- (void)ttInitFontTable {
  if (TTFontTableIsInitialized) {
    return;
  }
      
  TTFontTable = [[NSDictionary dictionaryWithObjectsAndKeys:
                  [self dictionaryWithNormal:@"AmericanTypewriter"
                                        bold:@"AmericanTypewriter-Bold"
                                      italic:nil
                               boldAndItalic:nil],
                  @"AmericanTypewriter",
                  [self dictionaryWithNormal:@"Georgia"
                                        bold:@"Georgia-Bold"
                                      italic:@"Georgia-Italic"
                               boldAndItalic:@"Georgia-BoldItalic"],
                  @"Georgia",
                  [self dictionaryWithNormal:@"ArialMT"
                                        bold:@"Arial-BoldMT"
                                      italic:@"Arial-ItalicMT"
                               boldAndItalic:@"Arial-BoldItalicMT"],
                  @"ArialMT",
                  [self dictionaryWithNormal:@"Courier"
                                        bold:@"Courier-Bold"
                                      italic:@"Courier-Oblique"
                               boldAndItalic:@"Courier-BoldOblique"],
                  @"Courier",
                  [self dictionaryWithNormal:@"CourierNewPSMT"
                                        bold:@"CourierNewPS-BoldMT"
                                      italic:@"CourierNewPS-ItalicMT"
                               boldAndItalic:@"CourierNewPS-BoldItalicMT"],
                  @"CourierNewPSMT",
                  [self dictionaryWithNormal:@"Helvetica"
                                        bold:@"Helvetica-Bold"
                                      italic:@"Helvetica-Oblique"
                               boldAndItalic:@"Helvetica-BoldOblique"],
                  @"Helvetica",
                  [self dictionaryWithNormal:@"HelveticaNeue"
                                        bold:@"HelveticaNeue-Bold"
                                      italic:nil
                               boldAndItalic:nil],
                  @"HelveticaNeue",
                  [self dictionaryWithNormal:@"TimesNewRomanPSMT"
                                        bold:@"TimesNewRomanPS-BoldMT"
                                      italic:@"TimesNewRomanPS-ItalicMT"
                               boldAndItalic:@"TimesNewRomanPS-BoldItalicMT"],
                  @"TimesNewRomanPSMT",
                  [self dictionaryWithNormal:@"TrebuchetMS"
                                        bold:@"TrebuchetMS-Bold"
                                      italic:@"TrebuchetMS-Italic"
                               boldAndItalic:@"Trebuchet-BoldItalic"],
                  @"TrebuchetMS",
                  [self dictionaryWithNormal:@"Verdana"
                                        bold:@"Verdana-Bold"
                                      italic:@"Verdana-Italic"
                               boldAndItalic:@"Verdana-BoldItalic"],
                  @"Verdana",
                  nil] retain];

  // Build a mapping of every mode specific font name (e.g. Georgia-Bold)
  // to the base name (e.g. Georgia)
  TTFontNameToBaseFont = [[NSMutableDictionary dictionary] retain];
  
  for (NSString *baseFontName in [TTFontTable allKeys]) {
    NSDictionary *fontModes = [TTFontTable objectForKey:baseFontName];
    for (NSString *modeFontName in [fontModes allValues]) {
      [TTFontNameToBaseFont setObject:baseFontName forKey:modeFontName];
    }
  }
   
  TTFontTableIsInitialized = YES;
}

- (UIFont *)ttFontWithVersion:(NSString *)version {
  NSString *baseFontName = [TTFontNameToBaseFont objectForKey:self.fontName];
  
  if (baseFontName != nil) {
    NSString *modeFontName = [[TTFontTable objectForKey:baseFontName] objectForKey:version];
    
    if (modeFontName != nil) {
      return [UIFont fontWithName:modeFontName size:self.pointSize];
    }
  }
  
  return self;
}

- (UIFont *)ttBoldVersion {
  if (!TTFontTableIsInitialized) {
    [self ttInitFontTable];
  }

  return [self ttFontWithVersion:@"bold"];
}

- (UIFont *)ttItalicVersion {
  if (!TTFontTableIsInitialized) {
    [self ttInitFontTable];
  }
  
  return [self ttFontWithVersion:@"italic"];
}

- (UIFont *)ttNormalVersion {
  if (!TTFontTableIsInitialized) {
    [self ttInitFontTable];
  }
  
  return [self ttFontWithVersion:@"normal"];
}

@end
