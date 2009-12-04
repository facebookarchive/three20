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

#import "Three20/TTStyle.h"

@class TTStyledElement, TTStyledTextNode, TTStyledImageNode, TTStyledBoxFrame;

@interface TTStyledFrame : NSObject {
  TTStyledElement* _element;
  TTStyledFrame* _nextFrame;
  CGRect _bounds;
}

/** 
 * The element that contains the frame.
 */
@property(nonatomic,readonly) TTStyledElement* element;

/**
 * The next in the linked list of frames.
 */
@property(nonatomic,retain) TTStyledFrame* nextFrame;

/**
 * The bounds of the content that is displayed by this frame.
 */
@property(nonatomic) CGRect bounds;

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (UIFont*)font;

- (id)initWithElement:(TTStyledElement*)element;

/**
 * Draws the frame.
 */
- (void)drawInRect:(CGRect)rect;

- (TTStyledBoxFrame*)hitTest:(CGPoint)point;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBoxFrame : TTStyledFrame <TTStyleDelegate> {
  TTStyledBoxFrame* _parentFrame;
  TTStyledFrame* _firstChildFrame;
  TTStyle* _style;
}

@property(nonatomic,assign) TTStyledBoxFrame* parentFrame;
@property(nonatomic,retain) TTStyledFrame* firstChildFrame;

/**
 * The style used to render the frame;
 */
@property(nonatomic,retain) TTStyle* style;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledInlineFrame : TTStyledBoxFrame {
  TTStyledInlineFrame* _inlinePreviousFrame;
  TTStyledInlineFrame* _inlineNextFrame;
}

@property(nonatomic,readonly) TTStyledInlineFrame* inlineParentFrame;
@property(nonatomic,assign) TTStyledInlineFrame* inlinePreviousFrame;
@property(nonatomic,assign) TTStyledInlineFrame* inlineNextFrame;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextFrame : TTStyledFrame {
  TTStyledTextNode* _node;
  NSString* _text;
  UIFont* _font;
}

/** 
 * The node represented by the frame.
 */
@property(nonatomic,readonly) TTStyledTextNode* node;

/**
 * The text that is displayed by this frame.
 */
@property(nonatomic,readonly) NSString* text;

/**
 * The font that is used to measure and display the text of this frame.
 */
@property(nonatomic,retain) UIFont* font;

- (id)initWithText:(NSString*)text element:(TTStyledElement*)element node:(TTStyledTextNode*)node;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledImageFrame : TTStyledFrame <TTStyleDelegate> {
  TTStyledImageNode* _imageNode;
  TTStyle* _style;
}

/** 
 * The node represented by the frame.
 */
@property(nonatomic,readonly) TTStyledImageNode* imageNode;

/**
 * The style used to render the frame;
 */
@property(nonatomic,retain) TTStyle* style;

- (id)initWithElement:(TTStyledElement*)element node:(TTStyledImageNode*)node;

@end
