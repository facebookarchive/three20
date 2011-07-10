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

#import "Three20UI/TTModelViewController.h"

// UI
#import "Three20UI/TTNavigator.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// Network
#import "Three20Network/TTModel.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTModelViewController

@synthesize model       = _model;
@synthesize modelError  = _modelError;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _flags.isViewInvalid = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_model.delegates removeObject:self];
  TT_RELEASE_SAFELY(_model);
  TT_RELEASE_SAFELY(_modelError);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetViewStates {
  if (_flags.isShowingLoading) {
    [self showLoading:NO];
    _flags.isShowingLoading = NO;
  }
  if (_flags.isShowingModel) {
    [self showModel:NO];
    _flags.isShowingModel = NO;
  }
  if (_flags.isShowingError) {
    [self showError:NO];
    _flags.isShowingError = NO;
  }
  if (_flags.isShowingEmpty) {
    [self showEmpty:NO];
    _flags.isShowingEmpty = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateViewStates {
  if (_flags.isModelDidRefreshInvalid) {
    [self didRefreshModel];
    _flags.isModelDidRefreshInvalid = NO;
  }
  if (_flags.isModelWillLoadInvalid) {
    [self willLoadModel];
    _flags.isModelWillLoadInvalid = NO;
  }
  if (_flags.isModelDidLoadInvalid) {
    [self didLoadModel:_flags.isModelDidLoadFirstTimeInvalid];
    _flags.isModelDidLoadInvalid = NO;
    _flags.isModelDidLoadFirstTimeInvalid = NO;
    _flags.isShowingModel = NO;
  }

  BOOL showModel = NO, showLoading = NO, showError = NO, showEmpty = NO;

  if (_model.isLoaded || ![self shouldLoad]) {
    if ([self canShowModel]) {
      showModel = !_flags.isShowingModel;
      _flags.isShowingModel = YES;

    } else {
      if (_flags.isShowingModel) {
        [self showModel:NO];
        _flags.isShowingModel = NO;
      }
    }

  } else {
    if (_flags.isShowingModel) {
      [self showModel:NO];
      _flags.isShowingModel = NO;
    }
  }

  if (_model.isLoading) {
    showLoading = !_flags.isShowingLoading;
    _flags.isShowingLoading = YES;

  } else {
    if (_flags.isShowingLoading) {
      [self showLoading:NO];
      _flags.isShowingLoading = NO;
    }
  }

  if (_modelError) {
    showError = !_flags.isShowingError;
    _flags.isShowingError = YES;

  } else {
    if (_flags.isShowingError) {
      [self showError:NO];
      _flags.isShowingError = NO;
    }
  }

  if (!_flags.isShowingLoading && !_flags.isShowingModel && !_flags.isShowingError) {
    showEmpty = !_flags.isShowingEmpty;
    _flags.isShowingEmpty = YES;

  } else {
    if (_flags.isShowingEmpty) {
      [self showEmpty:NO];
      _flags.isShowingEmpty = NO;
    }
  }

  if (showModel) {
    [self showModel:YES];
    [self didShowModel:_flags.isModelDidShowFirstTimeInvalid];
    _flags.isModelDidShowFirstTimeInvalid = NO;
  }
  if (showEmpty) {
    [self showEmpty:YES];
  }
  if (showError) {
    [self showError:YES];
  }
  if (showLoading) {
    [self showLoading:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createInterstitialModel {
  self.model = [[[TTModel alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  [self updateView];

  [super viewWillAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
  if (_hasViewAppeared && !_isViewAppearing) {
    [super didReceiveMemoryWarning];
    [self refresh];

  } else {
    [super didReceiveMemoryWarning];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
  [self invalidateModel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
  if (model == self.model) {
    _flags.isModelWillLoadInvalid = YES;
    _flags.isModelDidLoadFirstTimeInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    TT_RELEASE_SAFELY(_modelError);
    _flags.isModelDidLoadInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    self.modelError = error;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidChange:(id<TTModel>)model {
  if (model == _model) {
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidBeginUpdates:(id<TTModel>)model {
  if (model == _model) {
    [self beginUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidEndUpdates:(id<TTModel>)model {
  if (model == _model) {
    [self endUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  if (!_model) {
    if (![TTNavigator navigator].isDelayed) {
      [self createModel];
    }

    if (!_model) {
      [self createInterstitialModel];
    }
  }
  return _model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModel:(id<TTModel>)model {
  if (_model != model) {
    [_model.delegates removeObject:self];
    [_model release];
    _model = [model retain];
    [_model.delegates addObject:self];
    TT_RELEASE_SAFELY(_modelError);

    if (_model) {
      _flags.isModelWillLoadInvalid = NO;
      _flags.isModelDidLoadInvalid = NO;
      _flags.isModelDidLoadFirstTimeInvalid = NO;
      _flags.isModelDidShowFirstTimeInvalid = YES;
    }

    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModelError:(NSError*)error {
  if (error != _modelError) {
    [_modelError release];
    _modelError = [error retain];

    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateModel {
  BOOL wasModelCreated = self.isModelCreated;
  [self resetViewStates];
  [_model.delegates removeObject:self];
  TT_RELEASE_SAFELY(_model);
  if (wasModelCreated) {
    self.model;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isModelCreated {
  return !!_model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoad {
  return !self.model.isLoaded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldReload {
  return !_modelError && self.model.isOutdated;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoadMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  _flags.isViewInvalid = YES;
  [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadIfNeeded {
  if ([self shouldReload] && !self.model.isLoading) {
    [self reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refresh {
  _flags.isViewInvalid = YES;
  _flags.isModelDidRefreshInvalid = YES;

  BOOL loading = self.model.isLoading;
  BOOL loaded = self.model.isLoaded;
  if (!loading && !loaded && [self shouldLoad]) {
    [self.model load:TTURLRequestCachePolicyDefault more:NO];

  } else if (!loading && loaded && [self shouldReload]) {
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];

  } else if (!loading && [self shouldLoadMore]) {
    [self.model load:TTURLRequestCachePolicyDefault more:YES];

  } else {
    _flags.isModelDidLoadInvalid = YES;
    if (_isViewAppearing) {
      [self updateView];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginUpdates {
  _flags.isViewSuspended = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endUpdates {
  _flags.isViewSuspended = NO;
  [self updateView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateView {
  _flags.isViewInvalid = YES;
  if (_isViewAppearing) {
    [self updateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateView {
  if (_flags.isViewInvalid && !_flags.isViewSuspended && !_flags.isUpdatingView) {
    _flags.isUpdatingView = YES;

    // Ensure the model is created
    self.model;
    // Ensure the view is created
    self.view;

    [self updateViewStates];

    if (_frozenState && _flags.isShowingModel) {
      [self restoreView:_frozenState];
      TT_RELEASE_SAFELY(_frozenState);
    }

    _flags.isViewInvalid = NO;
    _flags.isUpdatingView = NO;

    [self reloadIfNeeded];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willLoadModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didShowModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showModel:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
}


@end
