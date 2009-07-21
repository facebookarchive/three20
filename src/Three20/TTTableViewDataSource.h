#import "Three20/TTModel.h"

@protocol TTTableViewDataSource <UITableViewDataSource, UISearchDisplayDelegate>

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
 * Informs the data source that its model loaded.
 *
 * That would be a good time to prepare the freshly loaded data for use in the table view.
 */
- (void)tableViewDidLoadModel:(UITableView*)tableView;

/**
 *
 */
- (void)search:(NSString*)text;

/**
 *
 */
- (NSString*)titleForLoading:(BOOL)reloading;

/**
 *
 */
- (UIImage*)imageForEmpty;

/**
 *
 */
- (NSString*)titleForEmpty;

/**
 *
 */
- (NSString*)subtitleForEmpty;

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
