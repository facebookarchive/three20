//
//  NSFetchedResultsDataSource.h
//  Shopify_Mobile
//
//  Created by Matt Newberry on 11/15/10.
//  Copyright 2010 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFetchedResultsDataSource : TTSectionedDataSource <NSFetchedResultsControllerDelegate>{

	NSFetchedResultsController *_fetchedResultsController;
	UITableView *_tableView;
	NSEntityDescription *_entity;
	NSString *_sortBy;
	NSArray *_selectFields;
	NSString *_sectionKey;
	NSPredicate *_predicate;
	NSTimer *_updateTimer;
	NSInteger _fetchLimit;
	NSArray *_relationshipsToFetch;
	NSMutableArray *_delegates;
	
	BOOL _isLoading;
	BOOL _isOutdated;
    BOOL _tableIsUpdating;
    NSUInteger sectionInsertCount;
}

@property (nonatomic, assign) BOOL isOutdated;
@property (nonatomic, retain) NSMutableArray *delegates;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) NSArray *relationshipsToFetch;
@property (nonatomic, assign) NSInteger fetchLimit;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) NSPredicate *predicate;
@property (nonatomic, retain) NSString *sectionKey;
@property (nonatomic, retain) NSString *sortBy;
@property (nonatomic, retain) NSArray *selectFields;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSEntityDescription *entity;

- (id) initWithEntity:(NSEntityDescription *)entity controllerTableView:(UITableView *)controllerTableView;
- (void) loadLocal:(BOOL)more;
- (void) loadRemote;
- (id) cellForObject:(id)object;

- (void) didStartLoad;
- (void) didLoad;
- (void) didFailWithError:(NSError *)error;
- (void) silentDidStartLoad;
- (void) silentDidLoad;

- (NSDate *) loadedTime;
- (NSString*) titleForLoading:(BOOL)reloading;
- (UIImage*) imageForEmpty;
- (NSString*) titleForEmpty;
- (NSString*) subtitleForEmpty;
- (UIImage*) imageForError:(NSError*)error;
- (NSString*) titleForError:(NSError*)error;
- (NSString*) subtitleForError:(NSError*)error;

@end
