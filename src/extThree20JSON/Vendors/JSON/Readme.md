SBJson (aka json-framework)
===========================

JSON (JavaScript Object Notation) is a light-weight data interchange format that's easy to read and write for humans and computers alike. This library implements strict JSON parsing and generation in Objective-C.

New Features, Changes, and Notable Enhancements in 3.0
------------------------------------------------------

### JSON Stream Support

We now support parsing of documents split into several NSData chunks, like those returned by *NSURLConnection*. This means you can start parsing a JSON document before it is fully downloaded. Depending how you configure the delegates you can chose to have the entire document delivered to your process when it's finished parsing, or delivered bit-by-bit as records on a particular level finishes downloading. For more details see *SBJsonStreamParser* and *SBJsonStreamParserAdapter* in the [API docs][api].

There is also support for *writing to* JSON streams. This means you can write huge JSON documents to disk, or an HTTP destination, without having to hold the entire structure in memory. You can use this to generate a stream of tick data for a stock trading simulation, for example. For more information see *SBJsonStreamWriter* in the [API docs][api].

### Parse and write UTF8-encoded NSData

The internals of *SBJsonParser* and *SBJsonWriter* have been rewritten to be NSData based. It is no longer necessary to convert data returned by NSURLConnection into an NSString before feeding it to the parser. The old NSString-oriented API methods still exists, but now converts their inputs to NSData objects and delegates to the new methods.

### Project renamed to SBJson

The project was renamed to avoid clashing with Apple's private JSON.framework. (And to make it easier to Google for.)

* If you copy the classes into your project then all you need to update is to change the header inclusion from `#import "JSON.h"` to `#import "SBJson.h"`.
* If you link to the library rather than copy the classes you have to change the library you link to. On the Mac `JSON.framework` became `SBJson.framework`. On iOS `libjson.a` became `libsbjson-ios.a`. In both cases you now have to `#import <SBJson/SBJson.h>` in your code.

### API documentation integrated with Xcode

The *InstallDocumentation.sh* script allows you to generate [API documentation][api] from the source and install it into Xcode, so it's always at your fingertips. (This script requires [Doxygen][] to be installed.) After running the script from the top-level directory, open Xcode's documentation window and search for SBJson. (You might have to close and re-open Xcode for the changes to take effect.)

### TweetStream Example Project

An example project showing how to use the new streaming functionality to interact with Twitter's multi-document streams. This also shows how to link to the iOS static lib rather than having to copy the classes into your project.

### DisplayPretty Example Project

A small Mac example project showing how to link to an external JSON framework rather than copying the sources into your project. This is a fully functional (though simplistic) application that takes JSON input from a text field and presents it nicely formatted into another text field.

Features also present in previous versions
------------------------------------------

* BSD license.
* Super-simple high-level API: Calling `-JSONValue` on any NSString instance parses the JSON text in that string, and calling `-JSONRepresentation` on any NSArray or NSDictionary returns an NSString with the JSON representation of the object.
* The *SBJsonParser* and *SBJsonWriter* classes provides an object-oriented API providing a good balance between simplicity and flexibility.
* Configurable recursion depth limit for added security.
* Supports (but does not require) garbage collection.
* Sorted dictionary keys in JSON output.
* Pretty-printing of JSON output.

Installation
============

The simplest way to start using JSON in your application is to copy all the source files (the contents of the `Classes` folder) into your own Xcode project.

1. In the Finder, navigate to the `$PATH_TO_SBJSON/Classes` folder and select all the files.
1. Drag-and-drop them into your Xcode project.
1. Tick the **Copy items into destination group's folder** option.
1. Use `#import "SBJson.h"` in  your source files.

That should be it. Now create that Twitter client!

Upgrading
---------

If you're upgrading from a previous version, make sure you're deleting the old SBJson classes first, moving all the files to Trash.


Linking rather than copying
---------------------------

Copying the SBJson classes into your project isn't the only way to use this framework. (Though it is the simplest.) With Xcode 4's workspaces it has become much simpler to link to dependant projects. The examples in the distribution link to the iOS library and Mac framework, respectively.

* [Linking to JSON Framework on iOS](http://github.com/stig/JsonSampleIPhone)
* [Linking to JSON Framework on the Mac](http://github.com/stig/JsonSampleMac)


Links
=====

* [GitHub project page](http://github.com/stig/json-framework).
* [Example Projects](http://github.com/stig/json-framework/Examples).
* [Online API docs](http://stig.github.com/json-framework/api).
* [Frequently Asked Questions](http://github.com/stig/json-framework/wiki/FrequentlyAskedQuestions)

[api]: http://stig.github.com/json-framework/api/3.0/
[Doxygen]: http://doxygen.org
