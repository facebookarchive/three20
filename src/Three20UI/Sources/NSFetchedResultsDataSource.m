//
//  NSFetchedResultsDataSource.m
//  Shopify_Mobile
//
//  Created by Matt Newberry on 11/15/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import "NSFetchedResultsDataSource.h"

#define FETCHED_DEBUG NO
#define MAX_FETCH 50


@implementation NSFetchedResultsDataSource

@synthesize isOutdated = _isOutdated;
@synthesize delegates = _delegates;
@synthesize isLoading = _isLoading;
@synthesize relationshipsToFetch = _relationshipsToFetch;
@synthesize fetchLimit = _fetchLimit;
@synthesize updateTimer = _updateTimer;
@synthesize predicate = _predicate;
@synthesize sectionKey = _sectionKey;
@synthesize sortBy = _sortBy;
@synthesize selectFields = _selectFields;
@synthesize tableView = _tableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize entity = _entity;

- (id) initWithEntity:(NSEntityDescription *)entity controllerTableView:(UITableView *)controllerTableView{
	
	if(self = [super init]){
		
		self.entity = entity;
		self.tableView = controllerTableView;
		self.sortBy = [NSClassFromString([entity managedObjectClassName]) defaultSort];
		self.sectionKey = @"section_key";
		_selectFields = [[NSArray alloc] init];
		self.fetchLimit = MAX_FETCH;
		_isLoading = NO;
		_isOutdated = NO;
        _tableIsUpdating = NO;
		_delegates = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) loadLocal:(BOOL)more{
	
	TT_RELEASE_SAFELY(_fetchedResultsController);

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:_entity];
	[request setSortDescriptors:$SORT(_sortBy)];
	[request setPropertiesToFetch:_selectFields];
	[request setPredicate:_predicate];
	[request setFetchLimit:_fetchLimit];
	[request setFetchBatchSize:25];
	
	if(_relationshipsToFetch)
		[request setRelationshipKeyPathsForPrefetching:_relationshipsToFetch];
	    
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[ActiveManager shared].managedObjectContext sectionNameKeyPath:_sectionKey cacheName:nil];
	_fetchedResultsController.delegate = self;
	
	NSError *error;
	[_fetchedResultsController performFetch:&error];
	[request release];
}

- (void) loadRemote{
	
	// Left empty to be overriden
}

- (id<TTModel>) model {
	return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
	
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


- (id) tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	id object = nil;
	
	@try {
		object = [self cellForObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
	}
	@catch (NSException * e) {
		
		// Do nothing, return object as nil
	}	
	
	return object;
}

- (NSIndexPath *) tableView:(UITableView *)tableView indexPathForObject:(id)object{
    
    return [_fetchedResultsController indexPathForObject:object];
}

- (id) cellForObject:(id) object{
	
	return object;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
	return _fetchedResultsController.fetchedObjects != nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
	return _isLoading;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
	return _isOutdated;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    sectionInsertCount = 0;
    
    if(_tableIsUpdating)
        return;
    
    _tableIsUpdating = YES;

    if(FETCHED_DEBUG)
        NSLog(@"STARTING CHANGES");
        
    if(_delegates != nil)
        [_delegates perform:@selector(modelDidBeginUpdates:) withObject:self];
    else
        [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
            
			[_delegates perform:@selector(model:didInsertObject:atIndexPath:) 
					 withObject:self
					 withObject:nil
					 withObject:[NSIndexPath indexPathWithIndex:sectionIndex]
			 ];
			
			if(FETCHED_DEBUG)
				NSLog(@"Section Insert - %i", sectionIndex);
            
			break;
			
		case NSFetchedResultsChangeDelete:
            
			[_delegates perform:@selector(model:didDeleteObject:atIndexPath:) 
					 withObject:self
					 withObject:nil
					 withObject:[NSIndexPath indexPathWithIndex:sectionIndex]
			 ];
			
			if(FETCHED_DEBUG)
				NSLog(@"Section Delete - %i", sectionIndex);
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
            
			[_delegates perform:@selector(model:didInsertObject:atIndexPath:) 
					 withObject:self
					 withObject:anObject
					 withObject:newIndexPath
			 ];
			
			if(FETCHED_DEBUG)
				NSLog(@"Row Insert - %@ - %@", newIndexPath, anObject);
			
			break;
			
		case NSFetchedResultsChangeDelete:
            
			[_delegates perform:@selector(model:didDeleteObject:atIndexPath:) 
					 withObject:self
					 withObject:anObject
					 withObject:newIndexPath
			 ];
			
			if(FETCHED_DEBUG)
				NSLog(@"Row Deleted - %@", newIndexPath);
            
			break;
			
		case NSFetchedResultsChangeUpdate:
            
			[_delegates perform:@selector(model:didUpdateObject:atIndexPath:) 
					 withObject:self
					 withObject:anObject
					 withObject:newIndexPath
			 ];
			
			if(FETCHED_DEBUG)
				NSLog(@"Row Updated - %@ - %@", newIndexPath, anObject);
            
			break;
			
		case NSFetchedResultsChangeMove:			
			break;
	}
}

- (NSIndexPath *) tableView:(UITableView *)tableView willInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath {

	return indexPath;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willRemoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath {

	return indexPath;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
	
	return indexPath;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    _tableIsUpdating = NO;
	
    if(FETCHED_DEBUG)
        NSLog(@"FINISHED CHANGES");
        
    if(_delegates != nil)
        [_delegates perform:@selector(modelDidEndUpdates:) withObject:self];
    else
        [self.tableView endUpdates];
}

- (void) silentDidStartLoad{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self delegates] perform:@selector(modelDidStartLoad:) withObject:self];
	});
}

- (void) silentDidLoad{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self delegates] perform:@selector(modelDidFinishLoad:) withObject:self];
	});
}

- (void) didStartLoad{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_isLoading = YES;
		[[self delegates] perform:@selector(modelDidStartLoad:) withObject:self];
	});
}

- (void) didLoad{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_isLoading = NO;
		_isOutdated = NO;
		[[self delegates] perform:@selector(modelDidFinishLoad:) withObject:self];
	});
}

- (void) didFailWithError:(NSError *)error{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
        _isLoading = NO;
		_isOutdated = NO;
		[[self delegates] perform:@selector(model:didFailLoadWithError:) withObject:self withObject:error];
	});
}

- (NSDate *) loadedTime{
	
	return nil;
}

- (void) load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more{
	
	if(cachePolicy == TTURLRequestCachePolicyNetwork)
		[self loadRemote];
	else
		[self loadLocal:more];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
	if (reloading) {
		return TTLocalizedString(@"Updating...", @"");
	} else {
		return TTLocalizedString(@"Loading...", @"");
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForEmpty {
	return [self imageForError:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
	return @"No Results Found";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForEmpty {
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForError:(NSError*)error {
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError:(NSError*)error {
	return TTDescriptionForError(error);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
	return TTLocalizedString(@"Sorry, there was an error.", @"");
}


- (void)dealloc{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_fetchedResultsController.delegate = nil;
	
	TT_RELEASE_SAFELY(_fetchedResultsController);
	TT_RELEASE_SAFELY(_entity);
	TT_RELEASE_SAFELY(_tableView);
	TT_RELEASE_SAFELY(_sortBy);
	TT_RELEASE_SAFELY(_selectFields);
	TT_RELEASE_SAFELY(_sectionKey);
	TT_RELEASE_SAFELY(_predicate);
	TT_RELEASE_SAFELY(_updateTimer);
	TT_RELEASE_SAFELY(_relationshipsToFetch);
	TT_RELEASE_SAFELY(_delegates);

	[super dealloc];
}

@end
