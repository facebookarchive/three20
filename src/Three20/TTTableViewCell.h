#import "Three20/TTGlobal.h"

/**
 * The base class for table cells which are single-object based.
 *
 * TTTableViewDataSource initializes each cell that it creates by assigning it the object
 * that the data source returned for the row. The responsibility for initializing the table cell
 * is then shifted from the table data source to the setObject method on the cell itself, which
 * this developer feels is a more appropriate delegation.  The same goes for the cell height
 * measurement, whose responsibility is transferred from the data source to the cell.
 *
 * Subclasses should implement the object getter and setter.  The base implementations do
 * nothing, allowing you to store the object yourself using the appropriate type.
 */
@interface TTTableViewCell : UITableViewCell

@property(nonatomic,retain) id object;

/**
 * Measure the height of the row with the object that will be assigned to the cell.
 */
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item;

@end
