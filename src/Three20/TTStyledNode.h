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

#import "Three20/TTGlobal.h"

@interface TTStyledNode : NSObject {
  TTStyledNode* _nextSibling;
  TTStyledNode* _parentNode;
}

@property(nonatomic, retain) TTStyledNode* nextSibling;
@property(nonatomic, assign) TTStyledNode* parentNode;
@property(nonatomic, readonly) NSString* outerText;
@property(nonatomic, readonly) NSString* outerHTML;

- (id)initWithNextSibling:(TTStyledNode*)nextSibling;

- (id)ancestorOrSelfWithClass:(Class)cls;

- (void) performDefaultAction;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextNode : TTStyledNode {
  NSString* _text;
}

@property(nonatomic, retain) NSString* text;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledElement : TTStyledNode {
  TTStyledNode* _firstChild;
  TTStyledNode* _lastChild;
  NSString* _className;
}

@property(nonatomic, readonly) TTStyledNode* firstChild;
@property(nonatomic, readonly) TTStyledNode* lastChild;
@property(nonatomic, retain) NSString* className;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling;

- (void)addChild:(TTStyledNode*)child;
- (void)addText:(NSString*)text;
- (void)replaceChild:(TTStyledNode*)oldChild withChild:(TTStyledNode*)newChild;

- (TTStyledNode*)getElementByClassName:(NSString*)className;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBlock : TTStyledElement
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledInline : TTStyledElement
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledInlineBlock : TTStyledElement
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBoldNode : TTStyledInline
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledItalicNode : TTStyledInline
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledLinkNode : TTStyledInline {
  NSString* _URL;
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;
@property(nonatomic,retain) NSString* URL;

- (id)initWithURL:(NSString*)URL;
- (id)initWithURL:(NSString*)URL next:(TTStyledNode*)nextSibling;
- (id)initWithText:(NSString*)text URL:(NSString*)URL next:(TTStyledNode*)nextSibling;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledButtonNode : TTStyledInlineBlock {
  NSString* _URL;
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;
@property(nonatomic,retain) NSString* URL;

- (id)initWithURL:(NSString*)URL;
- (id)initWithURL:(NSString*)URL next:(TTStyledNode*)nextSibling;
- (id)initWithText:(NSString*)text URL:(NSString*)URL next:(TTStyledNode*)nextSibling;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledImageNode : TTStyledElement {
  NSString* _URL;
  UIImage* _image;
  UIImage* _defaultImage;
  CGFloat _width;
  CGFloat _height;
}

@property(nonatomic,retain) NSString* URL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (id)initWithURL:(NSString*)URL;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledLineBreakNode : TTStyledBlock
@end
