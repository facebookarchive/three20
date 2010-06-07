# YAJL (Objective-C Wrapper)

YAJL.framework is an Objective-C wrapper around the [YAJL](http://lloyd.github.com/yajl/) SAX-style JSON parser.

## Download

### Mac OS X

[YAJL-0.2.16.zip](http://rel.me.s3.amazonaws.com/yajl/YAJL-0.2.16.zip) *YAJL.framework* (2010/03/01)

### iPhone

[libYAJLIPhone-0.2.17.zip](http://rel.me.s3.amazonaws.com/yajl/libYAJLIPhone-0.2.17.zip) *Static Library for iPhone OS 3.0 Simulator & Device* (2010/04/15)

## Install (Mac OS X)

There are two options. You can install it globally in /Library/Frameworks or with a little extra effort embed it with your project.

### Installing in /Library/Frameworks

- Copy `YAJL.framework` to `/Library/Frameworks/`
- In the target Info window, General tab:
	- Add a linked library, under `Mac OS X 10.5 SDK` section, select `YAJL.framework`

### Installing in your project

- Copy `YAJL.framework` to your project directory (maybe in MyProject/Frameworks/.)
- Add the `YAJL.framekwork` files (from MyProject/Frameworks/) to your target. It should be visible as a `Linked Framework` in the target. 
- Under Build Settings, add `@loader_path/../Frameworks` to `Runpath Search Paths` 
- Add `New Build Phase` | `New Copy Files Build Phase`. 
	- Change the Destination to `Frameworks`.
	- Drag `YAJL.framework` into the the build phase
	- Make sure the copy phase appears before any `Run Script` phases 

## Install (iPhone)

- Add files (from static library build) to project.
- Under 'Other Linker Flags' in the Test target, add `-ObjC` and `-all_load` (So NSObject+YAJL category is loaded).

## Usage

To parse JSON from an NSData (or NSString):

	#import "NSObject+YAJL.h"

	NSData *JSONData = [NSData dataWithContentsOfFile:@"example.json"];
	NSArray *arrayFromData = [JSONData yajl_JSON];
	
	NSString *JSONString = @"[\"Test\"]";
	NSArray *arrayFromString = [JSONString yajl_JSON];
	
	// With options and out error
	NSError *error = nil;
	NSArray *arrayFromString = [JSONString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];

To generate JSON from an object:

	#import "NSObject+YAJL.h"
	
	NSDictionary *dict = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
	NSString *JSONString = [dict yajl_JSONString];
	
	// Beautified with custon indent string
	NSArray *array = [NSArray arrayWithObjects:@"value1", @"value2", nil];
	NSString *JSONString = [dict yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"    "];

To use the streaming (or SAX style) parser, use `YAJLParser`. For higher level (document) streaming, see below.

	NSData *data = [NSData dataWithContentsOfFile:@"example.json"];

	YAJLParser *parser = [[YAJLParser alloc] initWithParserOptions:YAJLParserOptionsAllowComments];
	parser.delegate = self;
	[parser parse:data];
	if (parser.parserError) {
		NSLog(@"Error:\n%@", parser.parserError);
	}

	parser.delegate = nil;
	[parser release];
	
	// Include delegate methods from YAJLParserDelegate
	/*
	- (void)parserDidStartDictionary:(YAJLParser *)parser;
	- (void)parserDidEndDictionary:(YAJLParser *)parser;

	- (void)parserDidStartArray:(YAJLParser *)parser;
	- (void)parserDidEndArray:(YAJLParser *)parser;

	- (void)parser:(YAJLParser *)parser didMapKey:(NSString *)key;
	- (void)parser:(YAJLParser *)parser didAdd:(id)value;
	*/
  
### Parser Options

There are options when parsing that can be specified with `YAJLParser#initWithParserOptions:`.

- `YAJLParserOptionsAllowComments`: Allows comments in JSON
- `YAJLParserOptionsCheckUTF8`: Will verify UTF-8
- `YAJLParserOptionsStrictPrecision`: Will force strict precision and return integer overflow error, if number is greater than long long.
	
### Streaming Example (Parser)

	YAJLParser *parser = [[[YAJLParser alloc] init] autorelease];
	parser.delegate = self;
	
	// A chunk of data comes...
	YAJLParserStatus status = [parser parse:chunk1];
	// 'status' should be YAJLParserStatusInsufficientData, if its not finished
	if (parser.parserError) ...;
	
	// Another chunk of data comes...
	YAJLParserStatus status = [parser parse:chunk2];
	// 'status' should be YAJLParserStatusOK if its finished
	if (parser.parserError) ...;

## Usage (Document-style)

To use the document style, use `YAJLDocument`. Usage should be very similar to `NSXMLDocument`.

	NSData *data = [NSData dataWithContentsOfFile:@"example.json"];
	NSError *error = nil;
	YAJLDocument *document = [[YAJLDocument alloc] initWithData:data parserOptions:0 error:&error];
	// Access root element at document.root
	NSLog(@"Root: %@", document.root);
	[document release];
	
### Streaming Example (Document)
	
	YAJLDocument *document = [[YAJLDocument alloc] init];
	document.delegate = self;
	
	NSError *error = nil;
	[document parse:chunk1 error:error];
	[document parse:chunk2 error:error];
	
	// You can access root element at document.root
	NSLog(@"Root: %@", document.root);
	[document release];
	
	// Or via the YAJLDocumentDelegate delegate methods
	
	- (void)document:(YAJLDocument *)document didAddDictionary:(NSDictionary *)dict { }
	- (void)document:(YAJLDocument *)document didAddArray:(NSArray *)array { }
	- (void)document:(YAJLDocument *)document didAddObject:(id)object toArray:(NSArray *)array { }
	- (void)document:(YAJLDocument *)document didSetObject:(id)object forKey:(id)key inDictionary:(NSDictionary *)dict { }

## Customized Encoding

To implement JSON encodable value for custom objects or override for existing objects, implement `- (id)JSON;`

For example:

	@interface CustomObject : NSObject
	@end

	@implementation CustomObject

	- (id)JSON {
	  return [NSArray arrayWithObject:[NSNumber numberWithInteger:1]];
	}

	@end
  
Then:

	CustomObject *customObject = [[CustomObject alloc] init];
	NSString *JSONString = [customObject yajl_JSON];
	// JSONString == "[1]";

