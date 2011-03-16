# JSON Framework Changes

## Version 2.3.1 (September 25th, 2010)

### Changes

* Renamed .md files to .markdown.
* Removed bench target--use [Sam Soffes's benchmarks][json-benchmark] instead.

[json-benchmark]: http://github.com/samsoffes/json-benchmark

### Bug fixes

* [Issue 2][issue#2]: Linkage not supported by default distribution.
* [Issue 4][issue#4]: Writer reported to occasionally fail infinity check.
* [Issue 8][issue#8]: Installation.markdown refers to missing JSON folder.

[issue#2]: http://github.com/stig/json-framework/issues/closed/#issue/2
[issue#4]: http://github.com/stig/json-framework/issues/closed/#issue/4
[issue#8]: http://github.com/stig/json-framework/issues/closed/#issue/8

## Version 2.3 (August 7, 2010)

* Renamed README.md to Readme.md
* Updated version number

## Version 2.3beta1 (July 31, 2010)

### Changes

* **Parsing performance improvements.**  
[Issue 56][issue-56]: Dewvinci & Tobias Hoehmann came up with a patch to improve parsing of short JSON texts with lots of numbers by over 60%.
* **Refactored tests to be more data-driven.**  
This should make the source leaner and easier to maintain.
* **Removed problematic SDK**  
[Issue 33][issue-33], [58][issue-58], [63][issue-63], and [64][issue-64]: The vast majority of the issues people are having with this framework were related to the somewhat mystical Custom SDK. This has been removed in this version. 
* **Removed the deprecated SBJSON facade**  
[Issue 71][issue-71]: You should use the SBJsonParser or SBJsonWriter classes, or the category methods, instead. This also let us remove the SBJsonParser and SBJsonWriter categories; these were only there to support the facade, but made the code less transparent.
* **Removed the deprecated fragment support**  
[Issue 70][issue-70]: Fragments were a bad idea from the start, but deceptively useful while writing the framework's test suite. This has now been rectified. 

[issue-56]: http://code.google.com/p/json-framework/issues/detail?id=56
[issue-33]: http://code.google.com/p/json-framework/issues/detail?id=33
[issue-58]: http://code.google.com/p/json-framework/issues/detail?id=58
[issue-63]: http://code.google.com/p/json-framework/issues/detail?id=63
[issue-64]: http://code.google.com/p/json-framework/issues/detail?id=64
[issue-70]: http://code.google.com/p/json-framework/issues/detail?id=70
[issue-71]: http://code.google.com/p/json-framework/issues/detail?id=71


### Bug Fixes

* [Issue 38][issue-38]: Fixed header-inclusion issue.
* [Issue 74][issue-74]: Fix bug in handling of Infinity, -Infinity & NaN.
* [Issue 68][issue-68]: Fixed documentation bug

[issue-38]: http://code.google.com/p/json-framework/issues/detail?id=39
[issue-74]: http://code.google.com/p/json-framework/issues/detail?id=74
[issue-68]: http://code.google.com/p/json-framework/issues/detail?id=68


## Version 2.2.3 (March 7, 2010)

* **Added -all_load to libjsontests linker flags.**  
This allows the tests to run with more recent versions of GCC.
* **Unable to do a JSONRepresentation for a first-level proxy object.**  
[Issue 54][issue-54] & [60][issue-60]: Allow the -proxyForJson method to be called for first-level proxy objects, in addition to objects that are embedded in other objects. 

[issue-54]: http://code.google.com/p/json-framework/issues/detail?id=54
[issue-60]: http://code.google.com/p/json-framework/issues/detail?id=60

## Version 2.2.2 (September 12, 2009)

* **Fixed error-reporting logic in category methods.**  
Reported by Mike Monaco.
* **iPhone SDK built against iPhoneOS 3.0.**  
This has been updated from 2.2.1.

## Version 2.2.1 (August 1st, 2009)

* **Added svn:ignore property to build directory.**  
Requested by Rony Kubat.
* **Fixed potential corruption in category methods.**  
If category methods were used in multiple threads they could potentially cause a crash. Reported by dprotaso / Relium.

## Version 2.2 (June 6th, 2009)

No changes since 2.2beta1.

## Version 2.2beta1 (May 30th, 2009)

* **Renamed method for custom object support**  
Renamed the -jsonRepresentationProxy method to -proxyForJson.

## Version 2.2alpha5 (May 25th, 2009)

* **Added support for custom objects (generation only)**  
Added an optional -jsonRepresentationProxy method that you can implement (either directly or as category) to enable JSON.framework to create a JSON representation of any object type. See the Tests/ProxyTest.m file for more information on how this works.
* **Moved maxDepth to SBJsonBase**  
Throw errors when the input is nested too deep for writing json as well as parsing. This allows us to exit cleanly rather than break the stack if someone accidentally creates a recursive structure.

## Version 2.2alpha4 (May 21st, 2009)

* **Renamed protocols and moved method declarations**  
Renamed SBJsonWriterOptions and SBJsonParserOptions protocols to be the same as their primary implementations and moved their one public method there.
* **Implemented proxy methods in SBJSON**  
This facade now implements the same methods as the SBJsonWriter and SBJsonParser objects, and simply forwards to them.
* **Extracted private methods to private protocol**  
Don't use these please.
* **Improved documentation generation**  
Classes now inherit documentation from their superclasses and protocols they implement.

## Version 2.2alpha3 (May 16th, 2009)

* **Reintroduced the iPhone Custom SDK**  
For the benefit of users who prefer not to copy the JSON source files into their project. Also updated it to be based on iPhoneOS v2.2.1.
* **Deprecated methods for dealing with fragments**  
Tweaked the new interface classes to support the old fragment-methods one more version.

## Version 2.2alpha2 (May 11th, 2009)

* **Added a Changes file.**  
So people can see what the changes are for each version without having to go to the project home page.
* **Updated Credits.**  
Some people that have provided patches (or other valuable contributions) had been left out. I've done my best to add those in. (If you feel that you or someone else are still missing, please let me know.)
* **Removed .svn folders from distribution.**  
The JSON source folder had a .svn folder in it, which could have caused problems when dragging it into your project.

## Version 2.2alpha1 (May 10th, 2009)

* **Improved installation instructions, particularly for the iPhone.**  
Getting the SDK to work properly in all configurations has proved to be a headache. Therefore the SDK has been removed in favour of instructions for simply copying the source files into your project.
* **Split the SBJSON class into a writer and parser class.**  
SBJSON remains as a facade for backwards compatibility. This refactoring also quashed warnings reported by the Clang static analyser.
* **Improved interface for dealing with errors.**  
Rather than having to pass in a pointer to an NSError object, you can now simply call a method to get the error stack back if there was an error. (The NSError-based API remains in the SBJSON facade, but is not present in the new classes.)
* **Documentation updates.**  
Minor updates to the documentation.

Release notes for earlier releases can be found here:
http://code.google.com/p/json-framework/wiki/ReleaseNotes

