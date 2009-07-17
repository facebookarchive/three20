#import "Three20/TTModelViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTDefaultModel : TTModel
@end

@implementation TTDefaultModel

- (BOOL)isLoaded {
  return YES;
}

- (BOOL)isEmpty {
  return NO;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTModelViewController

@synthesize model = _model, modelState = _modelState, modelError = _modelError;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _model = nil;
    _modelState = TTModelStateNone;
    _modelError = nil;
    _isViewInvalid = YES;
    _isLoadingViewInvalid = NO;
    _isLoadedViewInvalid = YES;
    _isValidatingView = NO;
  }
  return self;
}

- (void)dealloc {
  [_model.delegates removeObject:self];
  TT_RELEASE_MEMBER(_model);
  TT_RELEASE_MEMBER(_modelError);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewWillAppear:(BOOL)animated {
  _isViewAppearing = YES;
  _hasViewAppeared = YES;
  [self validateView];

  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  if (_hasViewAppeared && !_isViewAppearing) {
    [super didReceiveMemoryWarning];
    [self invalidateView];
  } else {
    [super didReceiveMemoryWarning];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model {
  if (model == self.model) {
    if (model.isLoadingMore) {
      self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateLoadingMore;
    } else if (_modelState & TTModelStateLoaded) {
      self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateReloading;
    } else {
      self.modelState = TTModelStateLoading;
    }
  }
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    self.modelError = nil;

    if (model.isEmpty) {
      self.modelState = TTModelStateLoadedEmpty;
    } else {
      self.modelState = TTModelStateLoaded;
    }
  }
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    self.modelError = error;
    self.modelState = TTModelStateLoadedError;
  }
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    self.modelState = _modelState & ~TTModelLoadingStates;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id<TTModel>)model {
  if (!_model) {
    [self loadModel];
    if (!_model) {
      self.model = [[[TTDefaultModel alloc] init] autorelease];
    }
  }
  return _model;
}

- (void)setModel:(id<TTModel>)model {
  if (_model != model) {
    BOOL unloaded = !!_model;
    [_model.delegates removeObject:self];
    TT_RELEASE_MEMBER(_model);

    if (unloaded) {
      [self modelDidUnload];
    }

    _model = [model retain];
    [_model.delegates addObject:self];

    if (_model) {
      [self modelDidLoad];
    }

    [self refresh];
  }
}

- (void)setModelState:(TTModelState)state {
  if (!_isLoadingViewInvalid) {
    _isLoadingViewInvalid = (_modelState & TTModelLoadingStates) != (state & TTModelLoadingStates);
  }
  if (!_isLoadedViewInvalid) {
    _isLoadedViewInvalid = state == TTModelStateLoaded || state == TTModelStateNone
                           || (_modelState & TTModelLoadedStates) != (state & TTModelLoadedStates);
  }
  
  _modelState = state;
  
  if (_isViewAppearing) {
    [self validateView];
  }
}

- (void)loadModel {
}

- (void)modelDidLoad {
}

- (void)modelDidUnload {
}

- (BOOL)isModelLoaded {
  return !!_model;
}

- (BOOL)shouldLoad {
  return !self.model.isLoaded;
}

- (BOOL)shouldReload {
  return !_modelError && self.model.isOutdated;
}

- (BOOL)shouldLoadMore {
  return NO;
}

- (void)reload {
  [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (void)reloadIfNeeded {
  if ([self shouldReload]) {
    [self reload];
  }
}

- (void)refresh {
  [self invalidateView];

  if (self.model.isLoading) {
    if (self.model.isLoadingMore) {
      self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateLoadingMore;
    } else if (self.model.isLoaded) {
      self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateReloading;
    } else {
      self.modelState = TTModelStateLoading;
    }
  } else if ([self shouldLoad]) {
    [self.model load:TTURLRequestCachePolicyDefault more:NO];
  } else if ([self shouldReload]) {
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
  } else if ([self shouldLoadMore]) {
    [self.model load:TTURLRequestCachePolicyDefault more:YES];
  } else {
    if (_modelError) {
      self.modelState = TTModelStateLoadedError;
    } else if (self.model.isEmpty) {
      self.modelState = TTModelStateLoadedEmpty;
    } else if (self.model.isLoaded) {
      self.modelState = TTModelStateLoaded;
    }
  }
}

- (void)invalidateView {
  _isViewInvalid = YES;
  _modelState = TTModelStateNone;
  _isLoadingViewInvalid = NO;
  _isLoadedViewInvalid = YES;
}

- (void)validateView {
  if (!_isValidatingView) {
    _isValidatingView = YES;

    // Ensure the model is loaded
    self.model;
    
    if (_isViewInvalid) {
      // Ensure the view is loaded
      self.view;
      
      [self modelWillAppear];

      if (_frozenState && !(self.modelState & TTModelLoadingStates)) {
        [self restoreView:_frozenState];
        TT_RELEASE_MEMBER(_frozenState);
      }

      _isViewInvalid = NO;
    }
    
    if (_isLoadingViewInvalid || _isLoadedViewInvalid) {
      [self modelDidChangeState];
    }
    
    if (_isLoadingViewInvalid) {
      [self modelDidChangeLoadingState];
      _isLoadingViewInvalid = NO;
    }

    if (_isLoadedViewInvalid) {
      [self modelDidChangeLoadedState];
      _isLoadedViewInvalid = NO;
    }

    _isValidatingView = NO;

    [self reloadIfNeeded];
  }
}

- (void)modelWillAppear {
}

- (void)modelDidChangeState {
}

- (void)modelDidChangeLoadingState {
}

- (void)modelDidChangeLoadedState {
}

@end
