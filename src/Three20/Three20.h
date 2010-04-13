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
 *   <a href="#Style" style="display:block;width:200px;font-size:1.5em">Style</a>
 *   <a href="#UI" style="display:block;width:200px;font-size:1.5em">UI</a>
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
 * \section UI
 *
 * Three20 includes a growing set of common controls. Photo browsers, table view cells, and
 * springboard implementations are just a few. The UI component includes the TTNavigator object
 * that makes building persistent applications easy.
 *
 * \section Style
 *
 * A robust style framework that makes it easy to create gradients, shadows, and rounded borders.
 *
 */

// Core
#import "Three20/Three20Core.h"

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

// UI Views
#import "Three20/TTView.h"
#import "Three20/TTImageView.h"
#import "Three20/TTImageViewDelegate.h"
#import "Three20/TTYouTubeView.h"
#import "Three20/TTScrollView.h"
#import "Three20/TTScrollViewDelegate.h"
#import "Three20/TTScrollViewDataSource.h"

#import "Three20/TTLauncherView.h"
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
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTErrorView.h"

#import "Three20/TTPhotoSource.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTPhotoView.h"
#import "Three20/TTThumbsViewController.h"
#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTThumbView.h"

#import "Three20/TTRecursiveProgress.h"

// Network
#import "Three20/Three20Network.h"

// Style
#import "Three20/TTGlobalStyle.h"

#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTLayout.h"
#import "Three20/TTShape.h"
#import "Three20/TTStyle.h"

#import "Three20/TTStyledText.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledTextParser.h"
