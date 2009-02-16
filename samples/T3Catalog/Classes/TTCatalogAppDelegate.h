#import <Three20/Three20.h>

@interface TTCatalogAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
}

@property(nonatomic,retain) UIWindow *window;
@property(nonatomic,retain) UINavigationController *navigationController;

@end

