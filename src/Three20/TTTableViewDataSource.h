#import "Three20/TTModel.h"

@protocol TTTableViewDataSource <UITableViewDataSource>

/**
 * Optional method to return a model object to delegate the TTModel protocol to.
 */
@property(nonatomic,retain) id<TTModel> model;

/**
 *
 */
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;

/**
 *
 */
- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object;

/**
 *
 */
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object;

/**
 *
 */
- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath;

/**
 * Informs the data source that it is about to be used by a table view.
 *
 * If your data source has a model, this is called automatically after your model
 * has loaded.  That would be a good time to prepare the data for use in the data source.
 */
- (void)willAppearInTableView:(UITableView*)tableView;

/**
 *
 */
- (void)search:(NSString*)text;

/**
 *
 */
- (NSString*)titleForLoading:(BOOL)refreshing;

/**
 *
 */
- (UIImage*)imageForNoData;

/**
 *
 */
- (NSString*)titleForNoData;

/**
 *
 */
- (NSString*)subtitleForNoData;

/**
 *
 */
- (UIImage*)imageForError:(NSError*)error;

/**
 *
 */
- (NSString*)titleForError:(NSError*)error;

/**
 *
 */
- (NSString*)subtitleForError:(NSError*)error;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewDataSource : NSObject <TTTableViewDataSource> {
  id<TTModel> _model;
}

@end
