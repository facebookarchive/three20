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

#import "Three20UI/private/TTTextEditorInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// UI
#import "Three20UI/TTTextEditorDelegate.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
TT_FIX_CATEGORY_BUG(TTTextEditorInternal)

@implementation TTTextEditorInternal

@synthesize ignoreBeginAndEnd = _ignoreBeginAndEnd;
@synthesize delegate          = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTextEditor:(TTTextEditor*)textEditor {
  if (self = [super init]) {
    _textEditor = textEditor;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldBeginEditing:)]) {
    return [_delegate textEditorShouldBeginEditing:_textEditor];

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldEndEditing:)]) {
    return [_delegate textEditorShouldEndEditing:_textEditor];

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didBeginEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidBeginEditing:)]) {
      [_delegate textEditorDidBeginEditing:_textEditor];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didEndEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidEndEditing:)]) {
      [_delegate textEditorDidEndEditing:_textEditor];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    if ([_delegate respondsToSelector:@selector(textEditorShouldReturn:)]) {
      if (![_delegate performSelector:@selector(textEditorShouldReturn:) withObject:_textEditor]) {
        return NO;
      }
    }
  }

  if ([_delegate respondsToSelector:
       @selector(textEditor:shouldChangeTextInRange:replacementText:)]) {
    return [_delegate textEditor:_textEditor shouldChangeTextInRange:range replacementText:text];

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView *)textView {
  [_textEditor performSelector:@selector(didChangeText:) withObject:NO];

  if ([_delegate respondsToSelector:@selector(textEditorDidChange:)]) {
    [_delegate textEditorDidChange:_textEditor];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldBeginEditing:)]) {
    return [_delegate textEditorShouldBeginEditing:_textEditor];

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldEndEditing:)]) {
    return [_delegate textEditorShouldEndEditing:_textEditor];

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didBeginEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidBeginEditing:)]) {
      [_delegate textEditorDidBeginEditing:_textEditor];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didEndEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidEndEditing:)]) {
      [_delegate textEditorDidEndEditing:_textEditor];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)                textField: (UITextField*)textField
    shouldChangeCharactersInRange: (NSRange)range
                replacementString: (NSString*)string {
  BOOL shouldChange = YES;
  if ([_delegate respondsToSelector:
       @selector(textEditor:shouldChangeTextInRange:replacementText:)]) {
    shouldChange = [_delegate textEditor:_textEditor shouldChangeTextInRange:range
                         replacementText:string];
  }

  if (shouldChange) {
    [self performSelector:@selector(textViewDidChange:) withObject:nil afterDelay:0];
  }
  return shouldChange;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textEditorShouldReturn:)]) {
    if (![_delegate performSelector:@selector(textEditorShouldReturn:) withObject:_textEditor]) {
      return NO;
    }
  }

  [_textEditor performSelector:@selector(didChangeText:) withObject:(id)YES];

  if ([_delegate respondsToSelector:@selector(textEditorDidChange:)]) {
    [_delegate textEditorDidChange:_textEditor];
  }
  return YES;
}


@end
