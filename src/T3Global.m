#import "Three20/T3Global.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static int gNetworkTaskCount = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////

const void* RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* T3CreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = RetainNoOp;
  callbacks.release = ReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

BOOL T3EmptyArray(NSObject* object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL T3EmptyString(NSObject* object) {
  return [object isKindOfClass:[NSString class]] && ![(NSString*)object length];
}

UIInterfaceOrientation T3DeviceOrientation() {
  UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
  if (!orient) {
    return UIInterfaceOrientationPortrait;
  } else {
    return orient;
  }
}

CGRect T3ScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIDeviceOrientationIsLandscape(T3DeviceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}

void T3NetworkRequestStarted() {
  if (gNetworkTaskCount++ == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }
}

void T3NetworkRequestStopped() {
  if (--gNetworkTaskCount == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
}

UIImage* T3TransformImage(UIImage* image, CGFloat width, CGFloat height, BOOL rotate) {
  CGFloat destW = width;
  CGFloat destH = height;
  CGFloat sourceW = width;
  CGFloat sourceH = height;
  if (rotate) {
    if (image.imageOrientation == UIImageOrientationRight || image.imageOrientation == UIImageOrientationLeft) {
      sourceW = height;
      sourceH = width;
    }
  }
  
  CGImageRef imageRef = image.CGImage;
  CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
    CGImageGetBitsPerComponent(imageRef), 4*destW, CGImageGetColorSpace(imageRef),
    CGImageGetBitmapInfo(imageRef));

  if (rotate) {
    if (image.imageOrientation == UIImageOrientationDown) {
      CGContextTranslateCTM(bitmap, sourceW, sourceH);
      CGContextRotateCTM(bitmap, 180 * (M_PI/180));
    } else if (image.imageOrientation == UIImageOrientationLeft) {
      CGContextTranslateCTM(bitmap, sourceH, 0);
      CGContextRotateCTM(bitmap, 90 * (M_PI/180));
    } else if (image.imageOrientation == UIImageOrientationRight) {
      CGContextTranslateCTM(bitmap, 0, sourceW);
      CGContextRotateCTM(bitmap, -90 * (M_PI/180));
    }
  }

  CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);

  CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  UIImage* result = [UIImage imageWithCGImage:ref];
  CGContextRelease(bitmap);
  CGImageRelease(ref);

  return result;
}

@implementation UIViewController (T3Category)

- (UIViewController*)previousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound) {
      return [viewControllers objectAtIndex:index-1];
    }
  }
  
  return nil;
}

- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:index+1];
    }
  }
  return nil;
}

- (void)alert:(NSString*)message title:(NSString*)title delegate:(id)delegate {
  if (message) {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:title message:message
      delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [alert show];
  }
}

- (void)alert:(NSString*)message {
  [self alert:message title:@"Alert" delegate:nil];
}

- (void)alertError:(NSString*)message {
  [self alert:message title:@"Error" delegate:nil];
}

@end
