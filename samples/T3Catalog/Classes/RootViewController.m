#import "RootViewController.h"
#import "ImageTest1Controller.h"
#import "ImageTest2Controller.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "TextTest1Controller.h"
#import "YouTubeTestController.h"
#import "ScrollViewTestController.h"

@implementation RootViewController

- (void)pushControllerAtRow:(NSIndexPath*)indexPath animated:(BOOL)animated {
  NSArray* section = [controllers objectAtIndex:indexPath.section*2+1];
  Class controllerClass = [section objectAtIndex:indexPath.row*2+1];
  UIViewController* controller = [[[controllerClass alloc] init] autorelease];
  controller.title = [section objectAtIndex:indexPath.row*2];
  [self.navigationController pushViewController:controller animated:animated];  
}

- (void)viewDidLoad {
  controllers = [[NSArray alloc] initWithObjects:
    @"Images",
    [[NSArray alloc] initWithObjects:
      @"Simple Image", [ImageTest1Controller class],
      @"Images in Table", [ImageTest2Controller class],
      @"Photo Browser", [PhotoTest1Controller class],
      @"Photo Thumbnails", [PhotoTest2Controller class],
      nil],
    @"Activity",
    [[NSArray alloc] initWithObjects:      
      @"Shiny Label", [TextTest1Controller class],
      nil],
    @"Media",
    [[NSArray alloc] initWithObjects:
      @"YouTube Player", [YouTubeTestController class],
      @"Scroll View", [ScrollViewTestController class],
      nil],
    nil];

  [self pushControllerAtRow:[NSIndexPath indexPathForRow:3 inSection:0] animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return controllers.count/2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)aSection {
  NSArray* section = [controllers objectAtIndex:aSection*2+1];
	return section.count/2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [controllers objectAtIndex:section*2];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"cell";
  
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
	}
	
  NSArray* section = [controllers objectAtIndex:indexPath.section*2+1];
  cell.text = [section objectAtIndex:indexPath.row*2];
  
	return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self pushControllerAtRow:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
  
  // Empty out the image cache to free up memory
  [[T3URLCache sharedCache] removeAll:NO];
}

@end
