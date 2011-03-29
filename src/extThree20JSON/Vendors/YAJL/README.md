# YAJL Framework

The YAJL framework is an Objective-C framework for the [YAJL](http://lloyd.github.com/yajl/) SAX-style JSON parser.

## Features

- Stream parsing, comments in JSON, better error messages.
- Parse directly from NSString or NSData.
- Generate JSON from default or custom types.
- Properly handles large numeric types.
- Document style parser.
- Error by exception or out error.

## Links

- The online [API documentation](http://gabriel.github.com/yajl-objc/).

## Install (Mac OS X)

### Installing in your project (Recommended)

- Copy `YAJL.framework` to your project directory (maybe in MyProject/Frameworks/.)
- Add the `YAJL.framekwork` files (from MyProject/Frameworks/) to your target. It should be visible as a `Linked Framework` in the target. 
- Under Build Settings, add `@loader_path/../Frameworks` to `Runpath Search Paths` 
- Add `New Build Phase` | `New Copy Files Build Phase`. 
	- Change the Destination to `Frameworks`.
	- Drag `YAJL.framework` into the the build phase
	- Make sure the copy phase appears before any `Run Script` phases 

### Installing in /Library/Frameworks

- Copy `YAJL.framework` to `/Library/Frameworks/`
- In the target Info window, General tab:
	- Add a linked library, under `Mac OS X 10.5 SDK` section, select `YAJL.framework`

## Install (iOS)

- Add `YAJLiOS.framework` to your project.
- Add the frameworks to `Linked Libraries`:
  - `YAJLiOS.framework`
  - `CoreGraphics.framework`
  - `Foundation.framework`
  - `UIKit.framework`
- Under `Framework Search Paths` make sure the (parent) directory to `YAJLiOS.framework` is listed.
- Under `Other Linker Flags` in your target, add `-ObjC` and `-all_load`

## Apps

YAJL framework is used by:

- [Yelp for iPhone/iPad](http://itunes.apple.com/us/app/yelp/id284910350?mt=8)
- Add your app here!

## Docset

Download and copy the YAJL.docset to `~/Library/Developer/Shared/Documentation/DocSets/YAJL.docset`

(You may need to restart XCode after copying the file.)

The documentation will appear within XCode:

![YAJL-Docset](http://rel.me.s3.amazonaws.com/yajl/images/docset.png)



