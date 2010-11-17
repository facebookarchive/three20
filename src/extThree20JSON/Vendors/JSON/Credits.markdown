# Credits

Without these people JSON Framework wouldn't be what it is today. Please let me know if I've mistakenly omitted anyone.

## Blake Seely
Inspiration for early versions of this framwork came from Blake's BSJSONAdditions.

## Marc Lehmann
Marc is the author of the excellent JSON::XS Perl module. The number validation routine in my framework is re-licensed from his module, with his permission.

## Jens Alfke, jens@mooseyard.com, http://mooseyard.com/Jens/
Patches that gave a speedup of 11 times for generation and 5 times for parsing of the long (about 12k) JSON string I was using for testing.

## Greg Bolsinga
* Patch for dropping the dependency on AppKit, making this a Foundation framework.
* Patch for building a static library, and instructions for creating a custom SDK suitable for the iPhone.

## Ben Rimmington
Patch speeding writing up by about 100% and parsing by 10% for certain inputs.

##renerattur
Patch to remove memory leak.

## dmaclach
* Patch to be warning-free with -Wparanthesis.
* Prompted me to fix some Clang static analysis errors.

## boredzo
Patch to stop memory leak in -JSONValue and friends.

## Adium, http://adiumx.com
Provided patch to fix crash when parsing facebook chat responses.

## Joerg Schwieder
Patch to install instructions for use of static library.

## Mike Monaco
Pointed out embarrasing mistake in logic to report errors in the category methods of 2.2.1.

## dewvinci & Tobias Höhmann
Performance patch for integer numbers and strings without special characters.

## George MacKerron
Reported bug in SBJsonWriter's handling of NaN, Infinity and -Infinity.

## jinksys
Reported bug with header inclusion of framework.
