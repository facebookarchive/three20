/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

// Deprecated, please see Three20/TTDebug.h for more details.
#ifdef DEBUG
#define TTLOG NSLog
#else
#define TTLOG    
#endif

// Deprecated, please see Three20/TTDebug.h for more details.
#define TTWARN TTLOG


// Helper

#define TTLOGRECT(rect) \
  TTDINFO(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

#define TTLOGPOINT(pt) \
  TTDINFO(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define TTLOGSIZE(size) \
  TTDINFO(@"%s w=%f, h=%f", #size, size.width, size.height)

#define TTLOGEDGES(edges) \
  TTDINFO(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
    edges.top, edges.bottom)

#define TTLOGHSV(_COLOR) \
  TTDINFO(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define TT_ERROR_DOMAIN @"three20.net"

#define TT_EC_INVALID_IMAGE 101


///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define RGBA(r,g,b,a) r/255.0, g/255.0, b/255.0, a

///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define TT_MINUTE 60
#define TT_HOUR (60*TT_MINUTE)
#define TT_DAY (24*TT_HOUR)
#define TT_WEEK (7*TT_DAY)
#define TT_MONTH (30.5*TT_DAY)
#define TT_YEAR (365*TT_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////

#define TT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define TT_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define TT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define TT_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* TTCreateNonRetainingArray();

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 */
NSMutableDictionary* TTCreateNonRetainingDictionary();

/**
 * Tests if an object is an array which is empty.
 */
BOOL TTIsEmptyArray(id object);

/**
 * Tests if an object is a set which is empty.
 */
BOOL TTIsEmptySet(id object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL TTIsEmptyString(id object);

/**
 * Returns a rectangle that is smaller or larger than the source rectangle.
 */
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been moved a distance and shortened by that distance.
 */
CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets);

