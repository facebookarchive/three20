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

/*! \mainpage Three20 API Documentation
 *
 * \section intro_sec Introduction
 *
 * All of the API documentation you see here has been generated from the Three20 source.
 *
 * Get the source: http://github.com/facebook/three20
 *
 * Three20 is a rather large iPhone development library. It is composed of a stack of four
 * components:
 *
 * <center>
 *   <a href="#UI" style="display:block;width:200px;font-size:1.5em">UI</a>
 *   <a href="#Style" style="display:block;width:200px;font-size:1.5em">Style</a>
 *   <a href="#Network" style="display:block;width:200px;font-size:1.5em">Network</a>
 *   <a href="#Core" style="display:block;width:200px;font-size:1.5em">Core</a>
 * </center>
 *
 * \section Core
 *
 * Three20's foundation includes debugging utilities and a plethora of useful additions to common
 * objects.
 *
 * \section Network
 *
 * A full network+cache implementation has been built around NSURLRequests with support for
 * disc and memory caching.
 *
 * \section Style
 *
 * A robust style framework that makes it easy to create gradients, shadows, and rounded borders.
 *
 * \section UI
 *
 * Three20 includes a growing set of common controls. Photo browsers, table view cells, and
 * springboard implementations are just a few. The UI component includes the TTNavigator object
 * that makes building persistent applications easy.
 *
 */

// Core
#import "Three20/Three20Core.h"

// Network
#import "Three20/Three20Network.h"

// UI
#import "Three20/TTGlobalUI.h"
#import "Three20/TTGlobalUINavigator.h"

// UI Controllers
#import "Three20/TTNavigator.h"
#import "Three20/TTNavigatorDelegate.h"
#import "Three20/TTViewController.h"
#import "Three20/TTWebController.h"
#import "Three20/TTMessageController.h"
#import "Three20/TTMessageControllerDelegate.h"
#import "Three20/TTMessageField.h"
#import "Three20/TTMessageRecipientField.h"
#import "Three20/TTMessageTextField.h"
#import "Three20/TTMessageSubjectField.h"
#import "Three20/TTAlertViewController.h"
#import "Three20/TTAlertViewControllerDelegate.h"
#import "Three20/TTActionSheetController.h"
#import "Three20/TTActionSheetControllerDelegate.h"
#import "Three20/TTPostController.h"
#import "Three20/TTPostControllerDelegate.h"
#import "Three20/TTTextBarController.h"
#import "Three20/TTTextBarDelegate.h"
#import "Three20/TTURLAction.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTURLObject.h"
#import "Three20/TTURLCache.h"

// UI Views
#import "Three20/TTView.h"
#import "Three20/TTImageView.h"
#import "Three20/TTImageViewDelegate.h"
#import "Three20/TTYouTubeView.h"
#import "Three20/TTScrollView.h"
#import "Three20/TTScrollViewDelegate.h"
#import "Three20/TTScrollViewDataSource.h"

#import "Three20/TTLauncherView.h"
#import "Three20/TTLauncherViewDelegate.h"
#import "Three20/TTLauncherItem.h"

#import "Three20/TTLabel.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTSearchlightLabel.h"

#import "Three20/TTButton.h"
#import "Three20/TTLink.h"
#import "Three20/TTTabBar.h"
#import "Three20/TTTabDelegate.h"
#import "Three20/TTTabStrip.h"
#import "Three20/TTTabGrid.h"
#import "Three20/TTTab.h"
#import "Three20/TTTabItem.h"
#import "Three20/TTButtonBar.h"
#import "Three20/TTPageControl.h"

#import "Three20/TTTextEditor.h"
#import "Three20/TTTextEditorDelegate.h"
#import "Three20/TTSearchTextField.h"
#import "Three20/TTSearchTextFieldDelegate.h"
#import "Three20/TTPickerTextField.h"
#import "Three20/TTSearchBar.h"

#import "Three20/TTTableViewController.h"
#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTTableView.h"
#import "Three20/TTTableViewDelegate.h"
#import "Three20/TTTableViewVarHeightDelegate.h"
#import "Three20/TTTableViewGroupedVarHeightDelegate.h"
#import "Three20/TTTableViewPlainDelegate.h"
#import "Three20/TTTableViewPlainVarHeightDelegate.h"
#import "Three20/TTTableViewDragRefreshDelegate.h"

#import "Three20/TTListDataSource.h"
#import "Three20/TTSectionedDataSource.h"
#import "Three20/TTTableHeaderView.h"
#import "Three20/TTTableViewCell.h"

// Table Items
#import "Three20/TTTableItem.h"
#import "Three20/TTTableLinkedItem.h"
#import "Three20/TTTableTextItem.h"
#import "Three20/TTTableCaptionItem.h"
#import "Three20/TTTableRightCaptionItem.h"
#import "Three20/TTTableSubtextItem.h"
#import "Three20/TTTableSubtitleItem.h"
#import "Three20/TTTableMessageItem.h"
#import "Three20/TTTableLongTextItem.h"
#import "Three20/TTTableGrayTextItem.h"
#import "Three20/TTTableSummaryItem.h"
#import "Three20/TTTableLink.h"
#import "Three20/TTTableButton.h"
#import "Three20/TTTableMoreButton.h"
#import "Three20/TTTableImageItem.h"
#import "Three20/TTTableRightImageItem.h"
#import "Three20/TTTableActivityItem.h"
#import "Three20/TTTableStyledTextItem.h"
#import "Three20/TTTableControlItem.h"
#import "Three20/TTTableViewItem.h"

// Table Item Cells
#import "Three20/TTTableLinkedItemCell.h"
#import "Three20/TTTableTextItemCell.h"
#import "Three20/TTTableCaptionItemCell.h"
#import "Three20/TTTableSubtextItemCell.h"
#import "Three20/TTTableRightCaptionItemCell.h"
#import "Three20/TTTableSubtitleItemCell.h"
#import "Three20/TTTableMessageItemCell.h"
#import "Three20/TTTableMoreButtonCell.h"
#import "Three20/TTTableImageItemCell.h"
#import "Three20/TTStyledTextTableItemCell.h"
#import "Three20/TTStyledTextTableCell.h"
#import "Three20/TTTableActivityItemCell.h"
#import "Three20/TTTableControlCell.h"
#import "Three20/TTTableFlushViewCell.h"

#import "Three20/TTErrorView.h"

#import "Three20/TTPhotoVersion.h"
#import "Three20/TTPhotoSource.h"
#import "Three20/TTPhoto.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTPhotoView.h"
#import "Three20/TTThumbsViewController.h"
#import "Three20/TTThumbsViewControllerDelegate.h"
#import "Three20/TTThumbsDataSource.h"
#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTThumbsTableViewCellDelegate.h"
#import "Three20/TTThumbView.h"

#import "Three20/TTRecursiveProgress.h"

// Additions
// TODO (jverkoey): Remove these additions after May 20, 2010.
#import "Three20/UIViewAdditions.h"
#import "Three20/UIViewControllerAdditions.h"
#import "Three20/UINavigationControllerAdditions.h"
#import "Three20/UINavigationControllerAdditions.h"
#import "Three20/UITabBarControllerAdditions.h"
#import "Three20/UITableViewAdditions.h"
#import "Three20/UIWebViewAdditions.h"
#import "Three20/UIToolbarAdditions.h"
#import "Three20/UIWindowAdditions.h"
#import "Three20/UINSStringAdditions.h"
#import "Three20/UINSObjectAdditions.h"

// Style
#import "Three20/TTGlobalStyle.h"
#import "Three20/TTPosition.h"

#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTLayout.h"
#import "Three20/TTFlowLayout.h"
#import "Three20/TTGridLayout.h"

// Shapes
#import "Three20/TTShape.h"
#import "Three20/TTRectangleShape.h"
#import "Three20/TTRoundedRectangleShape.h"
#import "Three20/TTRoundedRightArrowShape.h"
#import "Three20/TTRoundedLeftArrowShape.h"
#import "Three20/TTSpeechBubbleShape.h"

// Styles
#import "Three20/TTStyle.h"
#import "Three20/TTStyleDelegate.h"
#import "Three20/TTStyleContext.h"
#import "Three20/TTContentStyle.h"
#import "Three20/TTPartStyle.h"
#import "Three20/TTShapeStyle.h"
#import "Three20/TTInsetStyle.h"
#import "Three20/TTBoxStyle.h"
#import "Three20/TTTextStyle.h"
#import "Three20/TTImageStyle.h"
#import "Three20/TTMaskStyle.h"
#import "Three20/TTBlendStyle.h"
#import "Three20/TTSolidFillStyle.h"
#import "Three20/TTLinearGradientFillStyle.h"
#import "Three20/TTReflectiveFillStyle.h"
#import "Three20/TTShadowStyle.h"
#import "Three20/TTInnerShadowStyle.h"
#import "Three20/TTSolidBorderStyle.h"
#import "Three20/TTHighlightBorderStyle.h"
#import "Three20/TTFourBorderStyle.h"
#import "Three20/TTBevelBorderStyle.h"
#import "Three20/TTLinearGradientBorderStyle.h"

#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextDelegate.h"

// Styled nodes
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledTextNode.h"
#import "Three20/TTStyledElement.h"
#import "Three20/TTStyledBlock.h"
#import "Three20/TTStyledInline.h"
#import "Three20/TTStyledInlineBlock.h"
#import "Three20/TTStyledBoldNode.h"
#import "Three20/TTStyledItalicNode.h"
#import "Three20/TTStyledLinkNode.h"
#import "Three20/TTStyledButtonNode.h"
#import "Three20/TTStyledImageNode.h"
#import "Three20/TTStyledLineBreakNode.h"

// Styled frames
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledBoxFrame.h"
#import "Three20/TTStyledInlineFrame.h"
#import "Three20/TTStyledTextFrame.h"
#import "Three20/TTStyledImageFrame.h"

#import "Three20/TTStyledTextParser.h"

// Additions
// TODO (jverkoey): Remove these additions after May 20, 2010.
#import "Three20/UIColorAdditions.h"
#import "Three20/UIFontAdditions.h"
#import "Three20/UIImageAdditions.h"
