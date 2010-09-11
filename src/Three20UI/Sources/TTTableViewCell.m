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

#import "Three20UI/TTTableViewCell.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

const CGFloat   kTableCellSmallMargin = 6;
const CGFloat   kTableCellSpacing     = 8;
const CGFloat   kTableCellMargin      = 10;
const CGFloat   kTableCellHPadding    = 10;
const CGFloat   kTableCellVPadding    = 10;

const NSInteger kTableMessageTextLineCount = 2;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return TT_ROW_HEIGHT;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  self.object = nil;
  [super prepareForReuse];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//   Copy & Paste support 
///////////////////////////////////////////////////////////////////////////////////////////////////

// Allow the cell to become a first responder so UIMenuController will ask it to perform the copy operation
- (BOOL)canBecomeFirstResponder {
	return YES;
}

// Get the text for the pasteboard copy, or nil
- (NSString*)textForCopyingToPasteboard {
	id obj = [self object];
	if(obj != nil && [obj respondsToSelector:@selector(textForCopyingToPasteboard)])
	{
		return [obj textForCopyingToPasteboard];
	}
	return nil;
}

// This cell will allow copy operations if there's some text available
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	return (action == @selector(copy:) && [self textForCopyingToPasteboard] != nil) || [super canPerformAction:action withSender:sender];
}

// Perform copy operations
- (void)copy:(id)sender {
	NSString *text = [self textForCopyingToPasteboard];
	if(text != nil)
	{
		[[UIPasteboard generalPasteboard] setString:text];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
