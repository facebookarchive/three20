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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTTableViewController, TTSearchDisplayController;

/** 
 * A view controller with some useful additions.
 */
@interface TTViewController : UIViewController {
  NSDictionary* _frozenState;
  UIBarStyle _navigationBarStyle;
  UIColor* _navigationBarTintColor;
  UIStatusBarStyle _statusBarStyle;
  TTSearchDisplayController* _searchController;
  BOOL _isViewAppearing;
  BOOL _hasViewAppeared;
  BOOL _autoresizesForKeyboard;
}

/**
 * The style of the navigation bar when this view controller is pushed onto a navigation controller.
 */
@property(nonatomic) UIBarStyle navigationBarStyle;

/**
 * The color of the navigation bar when this view controller is pushed onto a navigation controller.
 */
@property(nonatomic,retain) UIColor* navigationBarTintColor;

/**
 * The style of the status bar when this view controller is appearing.
 */
@property(nonatomic) UIStatusBarStyle statusBarStyle;

/**
 * A view controller used to display the contents of the search display controller.
 *
 * If you assign a view controller to this property, it will automatically create a search
 * display controller which you can access through this view controller's searchDisplaController
 * property.  You can then take the searchBar from that controller and add it to your views. The
 * search bar will then search the data source of the view controller that you assigned here.
 */
@property(nonatomic,retain) TTTableViewController* searchViewController;

/**
 * The view has appeared at least once.
 */
@property(nonatomic,readonly) BOOL hasViewAppeared;

/**
 * The view is currently visible.
 */
@property(nonatomic,readonly) BOOL isViewAppearing;

/**
 * Determines if the view will be resized automatically to fit the keyboard.
 */
@property(nonatomic) BOOL autoresizesForKeyboard;

/**
 * Sent to the controller before the keyboard slides in.
 */
- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds;

/**
 * Sent to the controller before the keyboard slides out.
 */
- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds;

/**
 * Sent to the controller after the keyboard has slid in.
 */
- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds;

/**
 * Sent to the controller after the keyboard has slid out.
 */
- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds;

@end
