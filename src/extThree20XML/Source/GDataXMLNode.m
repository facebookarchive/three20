/* Copyright (c) 2008 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define GDATAXMLNODE_DEFINE_GLOBALS 1
#import "GDataXMLNode.h"

@class NSArray, NSDictionary, NSError, NSString, NSURL;
@class GDataXMLElement, GDataXMLDocument;


static const int kGDataXMLParseOptions = (XML_PARSE_NOCDATA | XML_PARSE_NOBLANKS);

// dictionary key callbacks for string cache
static const void *StringCacheKeyRetainCallBack(CFAllocatorRef allocator, const void *str);
static void StringCacheKeyReleaseCallBack(CFAllocatorRef allocator, const void *str);
static CFStringRef StringCacheKeyCopyDescriptionCallBack(const void *str);
static Boolean StringCacheKeyEqualCallBack(const void *str1, const void *str2);
static CFHashCode StringCacheKeyHashCallBack(const void *str);

// isEqual: has the fatal flaw that it doesn't deal well with the received
// being nil. We'll use this utility instead.

// Static copy of AreEqualOrBothNil from GDataObject.m, so that using
// GDataXMLNode does not require pulling in all of GData.
static BOOL AreEqualOrBothNilPrivate(id obj1, id obj2) {
    if (obj1 == obj2) {
        return YES;
    }
    if (obj1 && obj2) {
        return [obj1 isEqual:obj2];
    }
    return NO;
}


// convert NSString* to xmlChar*
//
// the "Get" part implies that ownership remains with str

static xmlChar* GDataGetXMLString(NSString *str) {
    xmlChar* result = (xmlChar *)[str UTF8String];
    return result;
}

// Make a fake qualified name we use as local name internally in libxml
// data structures when there's no actual namespace node available to point to
// from an element or attribute node
//
// Returns an autoreleased NSString*

static NSString *GDataFakeQNameForURIAndName(NSString *theURI, NSString *name) {
    
    NSString *localName = [GDataXMLNode localNameForName:name];
    NSString *fakeQName = [NSString stringWithFormat:@"{%@}:%@",
                           theURI, localName];
    return fakeQName;
}


// libxml2 offers xmlSplitQName2, but that searches forwards. Since we may
// be searching for a whole URI shoved in as a prefix, like
//   {http://foo}:name
// we'll search for the prefix in backwards from the end of the qualified name
//
// returns a copy of qname as the local name if there's no prefix
static xmlChar *SplitQNameReverse(const xmlChar *qname, xmlChar **prefix) {
    
    // search backwards for a colon
    int qnameLen = xmlStrlen(qname);
    for (int idx = qnameLen - 1; idx >= 0; idx--) {
        
        if (qname[idx] == ':') {
            
            // found the prefix; copy the prefix, if requested
            if (prefix != NULL) {
                if (idx > 0) {
                    *prefix = xmlStrsub(qname, 0, idx);
                } else {
                    *prefix = NULL;
                }
            }
            
            if (idx < qnameLen - 1) {
                // return a copy of the local name
                xmlChar *localName = xmlStrsub(qname, idx + 1, qnameLen - idx - 1);
                return localName;
            } else {
                return NULL;
            }
        }
    }
    
    // no colon found, so the qualified name is the local name
    xmlChar *qnameCopy = xmlStrdup(qname);
    return qnameCopy;
}

@interface GDataXMLNode (PrivateMethods)

// consuming a node implies it will later be freed when the instance is
// dealloc'd; borrowing it implies that ownership and disposal remain the
// job of the supplier of the node

+ (id)nodeConsumingXMLNode:(xmlNodePtr)theXMLNode;
- (id)initConsumingXMLNode:(xmlNodePtr)theXMLNode;

+ (id)nodeBorrowingXMLNode:(xmlNodePtr)theXMLNode;
- (id)initBorrowingXMLNode:(xmlNodePtr)theXMLNode;

// getters of the underlying node
- (xmlNodePtr)XMLNode;
- (xmlNodePtr)XMLNodeCopy;

// search for an underlying attribute
- (GDataXMLNode *)attributeForXMLNode:(xmlAttrPtr)theXMLNode;

// return an NSString for an xmlChar*, using our strings cache in the
// document
- (NSString *)stringFromXMLString:(const xmlChar *)chars;

// setter/getter of the dealloc flag for the underlying node
- (BOOL)shouldFreeXMLNode;
- (void)setShouldFreeXMLNode:(BOOL)flag;

@end

@interface GDataXMLElement (PrivateMethods)

+ (void)fixUpNamespacesForNode:(xmlNodePtr)nodeToFix
            graftingToTreeNode:(xmlNodePtr)graftPointNode;
@end

@implementation GDataXMLNode

+ (void)load {
    xmlInitParser();
}

// Note on convenience methods for making stand-alone element and
// attribute nodes:
//
// Since we're making a node from scratch, we don't
// have any namespace info.  So the namespace prefix, if
// any, will just be slammed into the node name.
// We'll rely on the -addChild method below to remove
// the namespace prefix and replace it with a proper ns
// pointer.

+ (GDataXMLElement *)elementWithName:(NSString *)name {
    
    xmlNodePtr theNewNode = xmlNewNode(NULL, // namespace
                                       GDataGetXMLString(name));
    if (theNewNode) {
        // succeeded
        return [self nodeConsumingXMLNode:theNewNode];
    }
    return nil;
}

+ (GDataXMLElement *)elementWithName:(NSString *)name stringValue:(NSString *)value {
    
    xmlNodePtr theNewNode = xmlNewNode(NULL, // namespace
                                       GDataGetXMLString(name));
    if (theNewNode) {
        
        xmlNodePtr textNode = xmlNewText(GDataGetXMLString(value));
        if (textNode) {
            
            xmlNodePtr temp = xmlAddChild(theNewNode, textNode);
            if (temp) {
                // succeeded
                return [self nodeConsumingXMLNode:theNewNode];
            }
        }
        
        // failed; free the node and any children
        xmlFreeNode(theNewNode);
    }
    return nil;
}

+ (GDataXMLElement *)elementWithName:(NSString *)name URI:(NSString *)theURI {
    
    // since we don't know a prefix yet, shove in the whole URI; we'll look for
    // a proper namespace ptr later when addChild calls fixUpNamespacesForNode
    
    NSString *fakeQName = GDataFakeQNameForURIAndName(theURI, name);
    
    xmlNodePtr theNewNode = xmlNewNode(NULL, // namespace
                                       GDataGetXMLString(fakeQName));
    if (theNewNode) {
        return [self nodeConsumingXMLNode:theNewNode];
    }
    return nil;
}

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)value {
    
    xmlChar *xmlName = GDataGetXMLString(name);
    xmlChar *xmlValue = GDataGetXMLString(value);
    
    xmlAttrPtr theNewAttr = xmlNewProp(NULL, // parent node for the attr
                                       xmlName, xmlValue);
    if (theNewAttr) {
        return [self nodeConsumingXMLNode:(xmlNodePtr) theNewAttr];
    }
    
    return nil;
}

+ (id)attributeWithName:(NSString *)name URI:(NSString *)attributeURI stringValue:(NSString *)value {
    
    // since we don't know a prefix yet, shove in the whole URI; we'll look for
    // a proper namespace ptr later when addChild calls fixUpNamespacesForNode
    
    NSString *fakeQName = GDataFakeQNameForURIAndName(attributeURI, name);
    
    xmlChar *xmlName = GDataGetXMLString(fakeQName);
    xmlChar *xmlValue = GDataGetXMLString(value);
    
    xmlAttrPtr theNewAttr = xmlNewProp(NULL, // parent node for the attr
                                       xmlName, xmlValue);
    if (theNewAttr) {
        return [self nodeConsumingXMLNode:(xmlNodePtr) theNewAttr];
    }
    
    return nil;
}

+ (id)textWithStringValue:(NSString *)value {
    
    xmlNodePtr theNewText = xmlNewText(GDataGetXMLString(value));
    if (theNewText) {
        return [self nodeConsumingXMLNode:theNewText];
    }
    return nil;
}

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)value {
    
    xmlChar *href = GDataGetXMLString(value);
    xmlChar *prefix;
    
    if ([name length] > 0) {
        prefix = GDataGetXMLString(name);
    } else {
        // default namespace is represented by a nil prefix
        prefix = nil;
    }
    
    xmlNsPtr theNewNs = xmlNewNs(NULL, // parent node
                                 href, prefix);
    if (theNewNs) {
        return [self nodeConsumingXMLNode:(xmlNodePtr) theNewNs];
    }
    return nil;
}

+ (id)nodeConsumingXMLNode:(xmlNodePtr)theXMLNode {
    Class theClass;
    
    if (theXMLNode->type == XML_ELEMENT_NODE) {
        theClass = [GDataXMLElement class];
    } else {
        theClass = [GDataXMLNode class];
    }
    return [[[theClass alloc] initConsumingXMLNode:theXMLNode] autorelease];
}

- (id)initConsumingXMLNode:(xmlNodePtr)theXMLNode {
    self = [super init];
    if (self) {
        xmlNode_ = theXMLNode;
        shouldFreeXMLNode_ = YES;
    }
    return self;
}

+ (id)nodeBorrowingXMLNode:(xmlNodePtr)theXMLNode {
    Class theClass;
    if (theXMLNode->type == XML_ELEMENT_NODE) {
        theClass = [GDataXMLElement class];
    } else {
        theClass = [GDataXMLNode class];
    }
    
    return [[[theClass alloc] initBorrowingXMLNode:theXMLNode] autorelease];
}

- (id)initBorrowingXMLNode:(xmlNodePtr)theXMLNode {
    self = [super init];
    if (self) {
        xmlNode_ = theXMLNode;
        shouldFreeXMLNode_ = NO;
    }
    return self;
}

- (void)releaseCachedValues {
    
    [cachedName_ release];
    cachedName_ = nil;
    
    [cachedChildren_ release];
    cachedChildren_ = nil;
    
    [cachedAttributes_ release];
    cachedAttributes_ = nil;
}


// convert xmlChar* to NSString*
//
// returns an autoreleased NSString*, from the current node's document strings
// cache if possible
- (NSString *)stringFromXMLString:(const xmlChar *)chars {
    
#if DEBUG
    NSCAssert(chars != NULL, @"GDataXMLNode sees an unexpected empty string");
#endif
    if (chars == NULL) return nil;
    
    CFMutableDictionaryRef cacheDict = NULL;
    
    NSString *result = nil;
    
    if (xmlNode_ != NULL
        && (xmlNode_->type == XML_ELEMENT_NODE
            || xmlNode_->type == XML_ATTRIBUTE_NODE
            || xmlNode_->type == XML_TEXT_NODE)) {
            // there is no xmlDocPtr in XML_NAMESPACE_DECL nodes,
            // so we can't cache the text of those
            
            // look for a strings cache in the document
            //
            // the cache is in the document's user-defined _private field
            
            if (xmlNode_->doc != NULL) {
                
                cacheDict = xmlNode_->doc->_private;
                
                if (cacheDict) {
                    
                    // this document has a strings cache
                    result = (NSString *) CFDictionaryGetValue(cacheDict, chars);
                    if (result) {
                        // we found the xmlChar string in the cache; return the previously
                        // allocated NSString, rather than allocate a new one
                        return result;
                    }
                }
            }
        }
    
    // allocate a new NSString for this xmlChar*
    result = [NSString stringWithUTF8String:(const char *) chars];
    if (cacheDict) {
        // save the string in the document's string cache
        CFDictionarySetValue(cacheDict, chars, result);
    }
    
    return result;
}

- (void)dealloc {
    
    if (xmlNode_ && shouldFreeXMLNode_) {
        xmlFreeNode(xmlNode_);
        xmlNode_ = NULL;
    }
    
    [self releaseCachedValues];
    [super dealloc];
}

#pragma mark -

- (void)setStringValue:(NSString *)str {
    if (xmlNode_ != NULL && str != nil) {
        
        if (xmlNode_->type == XML_NAMESPACE_DECL) {
            
            // for a namespace node, the value is the namespace URI
            xmlNsPtr nsNode = (xmlNsPtr)xmlNode_;
            
            if (nsNode->href != NULL) xmlFree((char *)nsNode->href);
            
            nsNode->href = xmlStrdup(GDataGetXMLString(str));
            
        } else {
            
            // attribute or element node
            
            // do we need to call xmlEncodeSpecialChars?
            xmlNodeSetContent(xmlNode_, GDataGetXMLString(str));
        }
    }
}

- (NSString *)stringValue {
    
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        
        if (xmlNode_->type == XML_NAMESPACE_DECL) {
            
            // for a namespace node, the value is the namespace URI
            xmlNsPtr nsNode = (xmlNsPtr)xmlNode_;
            
            str = [self stringFromXMLString:(nsNode->href)];
            
        } else {
            
            // attribute or element node
            xmlChar* chars = xmlNodeGetContent(xmlNode_);
            if (chars) {
                
                str = [self stringFromXMLString:chars];
                
                xmlFree(chars);
            }
        }
    }
    return str;
}

- (NSString *)XMLString {
    
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        
        xmlBufferPtr buff = xmlBufferCreate();
        if (buff) {
            
            xmlDocPtr doc = NULL;
            int level = 0;
            int format = 0;
            
            int result = xmlNodeDump(buff, doc, xmlNode_, level, format);
            
            if (result > -1) {
                str = [[[NSString alloc] initWithBytes:(xmlBufferContent(buff))
                                                length:(xmlBufferLength(buff))
                                              encoding:NSUTF8StringEncoding] autorelease];
            }
            xmlBufferFree(buff);
        }
    }
    
    // remove leading and trailing whitespace
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [str stringByTrimmingCharactersInSet:ws];
    return trimmed;
}

- (NSString *)localName {
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        
        str = [self stringFromXMLString:(xmlNode_->name)];
        
        // if this is part of a detached subtree, str may have a prefix in it
        str = [[self class] localNameForName:str];
    }
    return str;
}

- (NSString *)prefix {
    
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        
        // the default namespace's prefix is an empty string, though libxml
        // represents it as NULL for ns->prefix
        str = @"";
        
        if (xmlNode_->ns != NULL && xmlNode_->ns->prefix != NULL) {
            str = [self stringFromXMLString:(xmlNode_->ns->prefix)];
        }
    }
    return str;
}

- (NSString *)URI {
    
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        
        if (xmlNode_->ns != NULL && xmlNode_->ns->href != NULL) {
            str = [self stringFromXMLString:(xmlNode_->ns->href)];
        }
    }
    return str;
}

- (NSString *)qualifiedName {
    // internal utility
    
    NSString *str = nil;
    
    if (xmlNode_ != NULL) {
        if (xmlNode_->type == XML_NAMESPACE_DECL) {
            
            // name of a namespace node
            xmlNsPtr nsNode = (xmlNsPtr)xmlNode_;
            
            // null is the default namespace; one is the loneliest number
            if (nsNode->prefix == NULL) {
                str = @"";
            }
            else {
                str = [self stringFromXMLString:(nsNode->prefix)];
            }
            
        } else if (xmlNode_->ns != NULL && xmlNode_->ns->prefix != NULL) {
            
            // name of a non-namespace node
            
            // has a prefix
            char *qname;
            if (asprintf(&qname, "%s:%s", (const char *)xmlNode_->ns->prefix,
                         xmlNode_->name) != -1) {
                str = [self stringFromXMLString:(const xmlChar *)qname];
                free(qname);
            }
        } else {
            // lacks a prefix
            str = [self stringFromXMLString:(xmlNode_->name)];
        }
    }
    
    return str;
}

- (NSString *)name {
    
    if (cachedName_ != nil) {
        return cachedName_;
    }
    
    NSString *str = [self qualifiedName];
    
    cachedName_ = [str retain];
    
    return str;
}

+ (NSString *)localNameForName:(NSString *)name {
    if (name != nil) {
        
        NSRange range = [name rangeOfString:@":"];
        if (range.location != NSNotFound) {
            
            // found a colon
            if (range.location + 1 < [name length]) {
                NSString *localName = [name substringFromIndex:(range.location + 1)];
                return localName;
            }
        }
    }
    return name;
}

+ (NSString *)prefixForName:(NSString *)name {
    if (name != nil) {
        
        NSRange range = [name rangeOfString:@":"];
        if (range.location != NSNotFound) {
            
            NSString *prefix = [name substringToIndex:(range.location)];
            return prefix;
        }
    }
    return nil;
}

- (NSUInteger)childCount {
    
    if (cachedChildren_ != nil) {
        return [cachedChildren_ count];
    }
    
    if (xmlNode_ != NULL) {
        
        unsigned int count = 0;
        
        xmlNodePtr currChild = xmlNode_->children;
        
        while (currChild != NULL) {
            ++count;
            currChild = currChild->next;
        }
        return count;
    }
    return 0;
}

- (NSArray *)children {
    
    if (cachedChildren_ != nil) {
        return cachedChildren_;
    }
    
    NSMutableArray *array = nil;
    
    if (xmlNode_ != NULL) {
        
        xmlNodePtr currChild = xmlNode_->children;
        
        while (currChild != NULL) {
            GDataXMLNode *node = [GDataXMLNode nodeBorrowingXMLNode:currChild];
            
            if (array == nil) {
                array = [NSMutableArray arrayWithObject:node];
            } else {
                [array addObject:node];
            }
            
            currChild = currChild->next;
        }
        
        cachedChildren_ = [array retain];
    }
    return array;
}

- (GDataXMLNode *)childAtIndex:(unsigned)index {
    
    NSArray *children = [self children];
    
    if ([children count] > index) {
        
        return [children objectAtIndex:index];
    }
    return nil;
}

- (GDataXMLNodeKind)kind {
    if (xmlNode_ != NULL) {
        xmlElementType nodeType = xmlNode_->type;
        switch (nodeType) {
            case XML_ELEMENT_NODE:         return GDataXMLElementKind;
            case XML_ATTRIBUTE_NODE:       return GDataXMLAttributeKind;
            case XML_TEXT_NODE:            return GDataXMLTextKind;
            case XML_CDATA_SECTION_NODE:   return GDataXMLTextKind;
            case XML_ENTITY_REF_NODE:      return GDataXMLEntityDeclarationKind;
            case XML_ENTITY_NODE:          return GDataXMLEntityDeclarationKind;
            case XML_PI_NODE:              return GDataXMLProcessingInstructionKind;
            case XML_COMMENT_NODE:         return GDataXMLCommentKind;
            case XML_DOCUMENT_NODE:        return GDataXMLDocumentKind;
            case XML_DOCUMENT_TYPE_NODE:   return GDataXMLDocumentKind;
            case XML_DOCUMENT_FRAG_NODE:   return GDataXMLDocumentKind;
            case XML_NOTATION_NODE:        return GDataXMLNotationDeclarationKind;
            case XML_HTML_DOCUMENT_NODE:   return GDataXMLDocumentKind;
            case XML_DTD_NODE:             return GDataXMLDTDKind;
            case XML_ELEMENT_DECL:         return GDataXMLElementDeclarationKind;
            case XML_ATTRIBUTE_DECL:       return GDataXMLAttributeDeclarationKind;
            case XML_ENTITY_DECL:          return GDataXMLEntityDeclarationKind;
            case XML_NAMESPACE_DECL:       return GDataXMLNamespaceKind;
            case XML_XINCLUDE_START:       return GDataXMLProcessingInstructionKind;
            case XML_XINCLUDE_END:         return GDataXMLProcessingInstructionKind;
            case XML_DOCB_DOCUMENT_NODE:   return GDataXMLDocumentKind;
        }
    }
    return GDataXMLInvalidKind;
}

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error {
    // call through with no explicit namespace dictionary; that will register the
    // root node's namespaces
    return [self nodesForXPath:xpath namespaces:nil error:error];
}

- (NSArray *)nodesForXPath:(NSString *)xpath
                namespaces:(NSDictionary *)namespaces
                     error:(NSError **)error {
    
    NSMutableArray *array = nil;
    NSInteger errorCode = -1;
    NSDictionary *errorInfo = nil;
    
    // xmlXPathNewContext requires a doc for its context, but if our elements
    // are created from GDataXMLElement's initWithXMLString there may not be
    // a document. (We may later decide that we want to stuff the doc used
    // there into a GDataXMLDocument and retain it, but we don't do that now.)
    //
    // We'll temporarily make a document to use for the xpath context.
    
    xmlDocPtr tempDoc = NULL;
    xmlNodePtr topParent = NULL;
    
    if (xmlNode_->doc == NULL) {
        tempDoc = xmlNewDoc(NULL);
        if (tempDoc) {
            // find the topmost node of the current tree to make the root of
            // our temporary document
            topParent = xmlNode_;
            while (topParent->parent != NULL) {
                topParent = topParent->parent;
            }
            xmlDocSetRootElement(tempDoc, topParent);
        }
    }
    
    if (xmlNode_ != NULL && xmlNode_->doc != NULL) {
        
        xmlXPathContextPtr xpathCtx = xmlXPathNewContext(xmlNode_->doc);
        if (xpathCtx) {
            // anchor at our current node
            xpathCtx->node = xmlNode_;
            
            // if a namespace dictionary was provided, register its contents
            if (namespaces) {
                // the dictionary keys are prefixes; the values are URIs
                for (NSString *prefix in namespaces) {
                    NSString *uri = [namespaces objectForKey:prefix];
                    
                    xmlChar *prefixChars = (xmlChar *) [prefix UTF8String];
                    xmlChar *uriChars = (xmlChar *) [uri UTF8String];
                    int result = xmlXPathRegisterNs(xpathCtx, prefixChars, uriChars);
                    if (result != 0) {
#if DEBUG
                        NSCAssert1(result == 0, @"GDataXMLNode XPath namespace %@ issue",
                                   prefix);
#endif
                    }
                }
            } else {
                // no namespace dictionary was provided
                //
                // register the namespaces of this node, if it's an element, or of
                // this node's root element, if it's a document
                xmlNodePtr nsNodePtr = xmlNode_;
                if (xmlNode_->type == XML_DOCUMENT_NODE) {
                    nsNodePtr = xmlDocGetRootElement((xmlDocPtr) xmlNode_);
                }
                
                // step through the namespaces, if any, and register each with the
                // xpath context
                if (nsNodePtr != NULL) {
                    for (xmlNsPtr nsPtr = nsNodePtr->ns; nsPtr != NULL; nsPtr = nsPtr->next) {
                        
                        // default namespace is nil in the tree, but there's no way to
                        // register a default namespace, so we'll register a fake one,
                        // _def_ns
                        const xmlChar* prefix = nsPtr->prefix;
                        if (prefix == NULL) {
                            prefix = (xmlChar*) kGDataXMLXPathDefaultNamespacePrefix;
                        }
                        
                        int result = xmlXPathRegisterNs(xpathCtx, prefix, nsPtr->href);
                        if (result != 0) {
#if DEBUG
                            NSCAssert1(result == 0, @"GDataXMLNode XPath namespace %@ issue",
                                       prefix);
#endif
                        }
                    }
                }
            }
            
            // now evaluate the path
            xmlXPathObjectPtr xpathObj;
            xpathObj = xmlXPathEval(GDataGetXMLString(xpath), xpathCtx);
            if (xpathObj) {
                
                // we have some result from the search
                array = [NSMutableArray array];
                
                xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
                if (nodeSet) {
                    
                    // add each node in the result set to our array
                    for (int index = 0; index < nodeSet->nodeNr; index++) {
                        
                        xmlNodePtr currNode = nodeSet->nodeTab[index];
                        
                        GDataXMLNode *node = [GDataXMLNode nodeBorrowingXMLNode:currNode];
                        if (node) {
                            [array addObject:node];
                        }
                    }
                }
                xmlXPathFreeObject(xpathObj);
            } else {
                // provide an error for failed evaluation
                const char *msg = xpathCtx->lastError.str1;
                errorCode = xpathCtx->lastError.code;
                if (msg) {
                    NSString *errStr = [NSString stringWithUTF8String:msg];
                    errorInfo = [NSDictionary dictionaryWithObject:errStr
                                                            forKey:@"error"];
                }
            }
            
            xmlXPathFreeContext(xpathCtx);
        }
    } else {
        // not a valid node for using XPath
        errorInfo = [NSDictionary dictionaryWithObject:@"invalid node"
                                                forKey:@"error"];
    }
    
    if (array == nil && error != nil) {
        *error = [NSError errorWithDomain:@"com.google.GDataXML"
                                     code:errorCode
                                 userInfo:errorInfo];
    }
    
    if (tempDoc != NULL) {
        xmlUnlinkNode(topParent);
        xmlSetTreeDoc(topParent, NULL);
        xmlFreeDoc(tempDoc);
    }
    return array;
}

- (NSString *)description {
    int nodeType = (xmlNode_ ? (int)xmlNode_->type : -1);
    
    return [NSString stringWithFormat:@"%@ %p: {type:%d name:%@ xml:\"%@\"}",
            [self class], self, nodeType, [self name], [self XMLString]];
}

- (id)copyWithZone:(NSZone *)zone {
    
    xmlNodePtr nodeCopy = [self XMLNodeCopy];
    
    if (nodeCopy != NULL) {
        return [[[self class] alloc] initConsumingXMLNode:nodeCopy];
    }
    return nil;
}

- (BOOL)isEqual:(GDataXMLNode *)other {
    if (self == other) return YES;
    if (![other isKindOfClass:[GDataXMLNode class]]) return NO;
    
    return [self XMLNode] == [other XMLNode]
    || ([self kind] == [other kind]
        && AreEqualOrBothNilPrivate([self name], [other name])
        && [[self children] count] == [[other children] count]);
    
}

- (NSUInteger)hash {
    return (NSUInteger) (void *) [GDataXMLNode class];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [super methodSignatureForSelector:selector];
}

#pragma mark -

- (xmlNodePtr)XMLNodeCopy {
    if (xmlNode_ != NULL) {
        
        // Note: libxml will create a new copy of namespace nodes (xmlNs records)
        // and attach them to this copy in order to keep namespaces within this
        // node subtree copy value.
        
        xmlNodePtr nodeCopy = xmlCopyNode(xmlNode_, 1); // 1 = recursive
        return nodeCopy;
    }
    return NULL;
}

- (xmlNodePtr)XMLNode {
    return xmlNode_;
}

- (BOOL)shouldFreeXMLNode {
    return shouldFreeXMLNode_;
}

- (void)setShouldFreeXMLNode:(BOOL)flag {
    shouldFreeXMLNode_ = flag;
}

@end



@implementation GDataXMLElement

- (id)initWithXMLString:(NSString *)str error:(NSError **)error {
    self = [super init];
    if (self) {
        
        const char *utf8Str = [str UTF8String];
        // NOTE: We are assuming a string length that fits into an int
        xmlDocPtr doc = xmlReadMemory(utf8Str, (int)strlen(utf8Str), NULL, // URL
                                      NULL, // encoding
                                      kGDataXMLParseOptions);
        if (doc == NULL) {
            if (error) {
                // TODO(grobbins) use xmlSetGenericErrorFunc to capture error
            }
        } else {
            // copy the root node from the doc
            xmlNodePtr root = xmlDocGetRootElement(doc);
            if (root) {
                xmlNode_ = xmlCopyNode(root, 1); // 1: recursive
                shouldFreeXMLNode_ = YES;
            }
            xmlFreeDoc(doc);
        }
        
        
        if (xmlNode_ == NULL) {
            // failure
            if (error) {
                *error = [NSError errorWithDomain:@"com.google.GDataXML"
                                             code:-1
                                         userInfo:nil];
            }
            [self release];
            return nil;
        }
    }
    return self;
}

- (NSArray *)namespaces {
    
    NSMutableArray *array = nil;
    
    if (xmlNode_ != NULL && xmlNode_->nsDef != NULL) {
        
        xmlNsPtr currNS = xmlNode_->nsDef;
        while (currNS != NULL) {
            
            // add this prefix/URI to the list, unless it's the implicit xml prefix
            if (!xmlStrEqual(currNS->prefix, (const xmlChar *) "xml")) {
                GDataXMLNode *node = [GDataXMLNode nodeBorrowingXMLNode:(xmlNodePtr) currNS];
                
                if (array == nil) {
                    array = [NSMutableArray arrayWithObject:node];
                } else {
                    [array addObject:node];
                }
            }
            
            currNS = currNS->next;
        }
    }
    return array;
}

- (void)setNamespaces:(NSArray *)namespaces {
    
    if (xmlNode_ != NULL) {
        
        [self releaseCachedValues];
        
        // remove previous namespaces
        if (xmlNode_->nsDef) {
            xmlFreeNsList(xmlNode_->nsDef);
            xmlNode_->nsDef = NULL;
        }
        
        // add a namespace for each object in the array
        NSEnumerator *enumerator = [namespaces objectEnumerator];
        GDataXMLNode *namespaceNode;
        while ((namespaceNode = [enumerator nextObject]) != nil) {
            
            xmlNsPtr ns = (xmlNsPtr) [namespaceNode XMLNode];
            if (ns) {
                (void)xmlNewNs(xmlNode_, ns->href, ns->prefix);
            }
        }
        
        // we may need to fix this node's own name; the graft point is where
        // the namespace search starts, so that points to this node too
        [[self class] fixUpNamespacesForNode:xmlNode_
                          graftingToTreeNode:xmlNode_];
    }
}

- (void)addNamespace:(GDataXMLNode *)aNamespace {
    
    if (xmlNode_ != NULL) {
        
        [self releaseCachedValues];
        
        xmlNsPtr ns = (xmlNsPtr) [aNamespace XMLNode];
        if (ns) {
            (void)xmlNewNs(xmlNode_, ns->href, ns->prefix);
            
            // we may need to fix this node's own name; the graft point is where
            // the namespace search starts, so that points to this node too
            [[self class] fixUpNamespacesForNode:xmlNode_
                              graftingToTreeNode:xmlNode_];
        }
    }
}

- (void)addChild:(GDataXMLNode *)child {
    if ([child kind] == GDataXMLAttributeKind) {
        [self addAttribute:child];
        return;
    }
    
    if (xmlNode_ != NULL) {
        
        [self releaseCachedValues];
        
        xmlNodePtr childNodeCopy = [child XMLNodeCopy];
        if (childNodeCopy) {
            
            xmlNodePtr resultNode = xmlAddChild(xmlNode_, childNodeCopy);
            if (resultNode == NULL) {
                
                // failed to add
                xmlFreeNode(childNodeCopy);
                
            } else {
                // added this child subtree successfully; see if it has
                // previously-unresolved namespace prefixes that can now be fixed up
                [[self class] fixUpNamespacesForNode:childNodeCopy
                                  graftingToTreeNode:xmlNode_];
            }
        }
    }
}

- (void)removeChild:(GDataXMLNode *)child {
    // this is safe for attributes too
    if (xmlNode_ != NULL) {
        
        [self releaseCachedValues];
        
        xmlNodePtr node = [child XMLNode];
        
        xmlUnlinkNode(node);
        
        // if the child node was borrowing its xmlNodePtr, then we need to
        // explicitly free it, since there is probably no owning object that will
        // free it on dealloc
        if (![child shouldFreeXMLNode]) {
            xmlFreeNode(node);
        }
    }
}

- (NSArray *)elementsForName:(NSString *)name {
    
    NSString *desiredName = name;
    
    if (xmlNode_ != NULL) {
        
        NSString *prefix = [[self class] prefixForName:desiredName];
        if (prefix) {
            
            xmlChar* desiredPrefix = GDataGetXMLString(prefix);
            
            xmlNsPtr foundNS = xmlSearchNs(xmlNode_->doc, xmlNode_, desiredPrefix);
            if (foundNS) {
                
                // we found a namespace; fall back on elementsForLocalName:URI:
                // to get the elements
                NSString *desiredURI = [self stringFromXMLString:(foundNS->href)];
                NSString *localName = [[self class] localNameForName:desiredName];
                
                NSArray *nsArray = [self elementsForLocalName:localName URI:desiredURI];
                return nsArray;
            }
        }
        
        // no namespace found for the node's prefix; try an exact match
        // for the name argument, including any prefix
        NSMutableArray *array = nil;
        
        // walk our list of cached child nodes
        NSArray *children = [self children];
        
        for (GDataXMLNode *child in children) {
            
            xmlNodePtr currNode = [child XMLNode];
            
            // find all children which are elements with the desired name
            if (currNode->type == XML_ELEMENT_NODE) {
                
                NSString *qName = [child name];
                if ([qName isEqual:name]) {
                    
                    if (array == nil) {
                        array = [NSMutableArray arrayWithObject:child];
                    } else {
                        [array addObject:child];
                    }
                }
            }
        }
        return array;
    }
    return nil;
}

- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI {
    
    NSMutableArray *array = nil;
    
    if (xmlNode_ != NULL && xmlNode_->children != NULL) {
        
        xmlChar* desiredNSHref = GDataGetXMLString(URI);
        xmlChar* requestedLocalName = GDataGetXMLString(localName);
        xmlChar* expectedLocalName = requestedLocalName;
        
        // resolve the URI at the parent level, since usually children won't
        // have their own namespace definitions, and we don't want to try to
        // resolve it once for every child
        xmlNsPtr foundParentNS = xmlSearchNsByHref(xmlNode_->doc, xmlNode_, desiredNSHref);
        if (foundParentNS == NULL) {
            NSString *fakeQName = GDataFakeQNameForURIAndName(URI, localName);
            expectedLocalName = GDataGetXMLString(fakeQName);
        }
        
        NSArray *children = [self children];
        
        for (GDataXMLNode *child in children) {
            
            xmlNodePtr currChildPtr = [child XMLNode];
            
            // find all children which are elements with the desired name and
            // namespace, or with the prefixed name and a null namespace
            if (currChildPtr->type == XML_ELEMENT_NODE) {
                
                // normally, we can assume the resolution done for the parent will apply
                // to the child, as most children do not define their own namespaces
                xmlNsPtr childLocalNS = foundParentNS;
                xmlChar* childDesiredLocalName = expectedLocalName;
                
                if (currChildPtr->nsDef != NULL) {
                    // this child has its own namespace definitons; do a fresh resolve
                    // of the namespace starting from the child, and see if it differs
                    // from the resolve done starting from the parent.  If the resolve
                    // finds a different namespace, then override the desired local
                    // name just for this child.
                    childLocalNS = xmlSearchNsByHref(xmlNode_->doc, currChildPtr, desiredNSHref);
                    if (childLocalNS != foundParentNS) {
                        
                        // this child does indeed have a different namespace resolution
                        // result than was found for its parent
                        if (childLocalNS == NULL) {
                            // no namespace found
                            NSString *fakeQName = GDataFakeQNameForURIAndName(URI, localName);
                            childDesiredLocalName = GDataGetXMLString(fakeQName);
                        } else {
                            // a namespace was found; use the original local name requested,
                            // not a faked one expected from resolving the parent
                            childDesiredLocalName = requestedLocalName;
                        }
                    }
                }
                
                // check if this child's namespace and local name are what we're
                // seeking
                if (currChildPtr->ns == childLocalNS
                    && currChildPtr->name != NULL
                    && xmlStrEqual(currChildPtr->name, childDesiredLocalName)) {
                    
                    if (array == nil) {
                        array = [NSMutableArray arrayWithObject:child];
                    } else {
                        [array addObject:child];
                    }
                }
            }
        }
        // we return nil, not an empty array, according to docs
    }
    return array;
}

- (NSArray *)attributes {
    
    if (cachedAttributes_ != nil) {
        return cachedAttributes_;
    }
    
    NSMutableArray *array = nil;
    
    if (xmlNode_ != NULL && xmlNode_->properties != NULL) {
        
        xmlAttrPtr prop = xmlNode_->properties;
        while (prop != NULL) {
            
            GDataXMLNode *node = [GDataXMLNode nodeBorrowingXMLNode:(xmlNodePtr) prop];
            if (array == nil) {
                array = [NSMutableArray arrayWithObject:node];
            } else {
                [array addObject:node];
            }
            
            prop = prop->next;
        }
        
        cachedAttributes_ = [array retain];
    }
    return array;
}

- (void)addAttribute:(GDataXMLNode *)attribute {
    
    if (xmlNode_ != NULL) {
        
        [self releaseCachedValues];
        
        xmlAttrPtr attrPtr = (xmlAttrPtr) [attribute XMLNode];
        if (attrPtr) {
            
            // ignore this if an attribute with the name is already present,
            // similar to NSXMLNode's addAttribute
            xmlAttrPtr oldAttr;
            
            if (attrPtr->ns == NULL) {
                oldAttr = xmlHasProp(xmlNode_, attrPtr->name);
            } else {
                oldAttr = xmlHasNsProp(xmlNode_, attrPtr->name, attrPtr->ns->href);
            }
            
            if (oldAttr == NULL) {
                
                xmlNsPtr newPropNS = NULL;
                
                // if this attribute has a namespace, search for a matching namespace
                // on the node we're adding to
                if (attrPtr->ns != NULL) {
                    
                    newPropNS = xmlSearchNsByHref(xmlNode_->doc, xmlNode_, attrPtr->ns->href);
                    if (newPropNS == NULL) {
                        // make a new namespace on the parent node, and use that for the
                        // new attribute
                        newPropNS = xmlNewNs(xmlNode_, attrPtr->ns->href, attrPtr->ns->prefix);
                    }
                }
                
                // copy the attribute onto this node
                xmlChar *value = xmlNodeGetContent((xmlNodePtr) attrPtr);
                xmlAttrPtr newProp = xmlNewNsProp(xmlNode_, newPropNS, attrPtr->name, value);
                if (newProp != NULL) {
                    // we made the property, so clean up the property's namespace
                    
                    [[self class] fixUpNamespacesForNode:(xmlNodePtr)newProp
                                      graftingToTreeNode:xmlNode_];
                }
                
                if (value != NULL) {
                    xmlFree(value);
                }
            }
        }
    }
}

- (GDataXMLNode *)attributeForXMLNode:(xmlAttrPtr)theXMLNode {
    // search the cached attributes list for the GDataXMLNode with
    // the underlying xmlAttrPtr
    NSArray *attributes = [self attributes];
    
    for (GDataXMLNode *attr in attributes) {
        
        if (theXMLNode == (xmlAttrPtr) [attr XMLNode]) {
            return attr;
        }
    }
    
    return nil;
}

- (GDataXMLNode *)attributeForName:(NSString *)name {
    
    if (xmlNode_ != NULL) {
        
        xmlAttrPtr attrPtr = xmlHasProp(xmlNode_, GDataGetXMLString(name));
        if (attrPtr == NULL) {
            
            // can we guarantee that xmlAttrPtrs always have the ns ptr and never
            // a namespace as part of the actual attribute name?
            
            // split the name and its prefix, if any
            xmlNsPtr ns = NULL;
            NSString *prefix = [[self class] prefixForName:name];
            if (prefix) {
                
                // find the namespace for this prefix, and search on its URI to find
                // the xmlNsPtr
                name = [[self class] localNameForName:name];
                ns = xmlSearchNs(xmlNode_->doc, xmlNode_, GDataGetXMLString(prefix));
            }
            
            const xmlChar* nsURI = ((ns != NULL) ? ns->href : NULL);
            attrPtr = xmlHasNsProp(xmlNode_, GDataGetXMLString(name), nsURI);
        }
        
        if (attrPtr) {
            GDataXMLNode *attr = [self attributeForXMLNode:attrPtr];
            return attr;
        }
    }
    return nil;
}

- (GDataXMLNode *)attributeForLocalName:(NSString *)localName
                                    URI:(NSString *)attributeURI {
    
    if (xmlNode_ != NULL) {
        
        const xmlChar* name = GDataGetXMLString(localName);
        const xmlChar* nsURI = GDataGetXMLString(attributeURI);
        
        xmlAttrPtr attrPtr = xmlHasNsProp(xmlNode_, name, nsURI);
        
        if (attrPtr == NULL) {
            // if the attribute is in a tree lacking the proper namespace,
            // the local name may include the full URI as a prefix
            NSString *fakeQName = GDataFakeQNameForURIAndName(attributeURI, localName);
            const xmlChar* xmlFakeQName = GDataGetXMLString(fakeQName);
            
            attrPtr = xmlHasProp(xmlNode_, xmlFakeQName);
        }
        
        if (attrPtr) {
            GDataXMLNode *attr = [self attributeForXMLNode:attrPtr];
            return attr;
        }
    }
    return nil;
}

- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI {
    
    if (xmlNode_ != NULL) {
        
        xmlChar* desiredNSHref = GDataGetXMLString(namespaceURI);
        
        xmlNsPtr foundNS = xmlSearchNsByHref(xmlNode_->doc, xmlNode_, desiredNSHref);
        if (foundNS) {
            
            // we found the namespace
            if (foundNS->prefix != NULL) {
                NSString *prefix = [self stringFromXMLString:(foundNS->prefix)];
                return prefix;
            } else {
                // empty prefix is default namespace
                return @"";
            }
        }
    }
    return nil;
}

#pragma mark Namespace fixup routines

+ (void)deleteNamespacePtr:(xmlNsPtr)namespaceToDelete
               fromXMLNode:(xmlNodePtr)node {
    
    // utilty routine to remove a namespace pointer from an element's
    // namespace definition list.  This is just removing the nsPtr
    // from the singly-linked list, the node's namespace definitions.
    xmlNsPtr currNS = node->nsDef;
    xmlNsPtr prevNS = NULL;
    
    while (currNS != NULL) {
        xmlNsPtr nextNS = currNS->next;
        
        if (namespaceToDelete == currNS) {
            
            // found it; delete it from the head of the node's ns definition list
            // or from the next field of the previous namespace
            
            if (prevNS != NULL) prevNS->next = nextNS;
            else node->nsDef = nextNS;
            
            xmlFreeNs(currNS);
            return;
        }
        prevNS = currNS;
        currNS = nextNS;
    }
}

+ (void)fixQualifiedNamesForNode:(xmlNodePtr)nodeToFix
              graftingToTreeNode:(xmlNodePtr)graftPointNode {
    
    // Replace prefix-in-name with proper namespace pointers
    //
    // This is an inner routine for fixUpNamespacesForNode:
    //
    // see if this node's name lacks a namespace and is qualified, and if so,
    // see if we can resolve the prefix against the parent
    //
    // The prefix may either be normal, "gd:foo", or a URI
    // "{http://blah.com/}:foo"
    
    if (nodeToFix->ns == NULL) {
        xmlNsPtr foundNS = NULL;
        
        xmlChar* prefix = NULL;
        xmlChar* localName = SplitQNameReverse(nodeToFix->name, &prefix);
        if (localName != NULL) {
            if (prefix != NULL) {
                
                // if the prefix is wrapped by { and } then it's a URI
                int prefixLen = xmlStrlen(prefix);
                if (prefixLen > 2
                    && prefix[0] == '{'
                    && prefix[prefixLen - 1] == '}') {
                    
                    // search for the namespace by URI
                    xmlChar* uri = xmlStrsub(prefix, 1, prefixLen - 2);
                    
                    if (uri != NULL) {
                        foundNS = xmlSearchNsByHref(graftPointNode->doc, graftPointNode, uri);
                        
                        xmlFree(uri);
                    }
                }
            }
            
            if (foundNS == NULL) {
                // search for the namespace by prefix, even if the prefix is nil
                // (nil prefix means to search for the default namespace)
                foundNS = xmlSearchNs(graftPointNode->doc, graftPointNode, prefix);
            }
            
            if (foundNS != NULL) {
                // we found a namespace, so fix the ns pointer and the local name
                xmlSetNs(nodeToFix, foundNS);
                xmlNodeSetName(nodeToFix, localName);
            }
            
            if (prefix != NULL) {
                xmlFree(prefix);
                prefix = NULL;
            }
            
            xmlFree(localName);
        }
    }
}

+ (void)fixDuplicateNamespacesForNode:(xmlNodePtr)nodeToFix
                   graftingToTreeNode:(xmlNodePtr)graftPointNode
             namespaceSubstitutionMap:(NSMutableDictionary *)nsMap {
    
    // Duplicate namespace removal
    //
    // This is an inner routine for fixUpNamespacesForNode:
    //
    // If any of this node's namespaces are already defined at the graft point
    // level, add that namespace to the map of namespace substitutions
    // so it will be replaced in the children below the nodeToFix, and
    // delete the namespace record
    
    if (nodeToFix->type == XML_ELEMENT_NODE) {
        
        // step through the namespaces defined on this node
        xmlNsPtr definedNS = nodeToFix->nsDef;
        while (definedNS != NULL) {
            
            // see if this namespace is already defined higher in the tree,
            // with both the same URI and the same prefix; if so, add a mapping for
            // it
            xmlNsPtr foundNS = xmlSearchNsByHref(graftPointNode->doc, graftPointNode,
                                                 definedNS->href);
            if (foundNS != NULL
                && foundNS != definedNS
                && xmlStrEqual(definedNS->prefix, foundNS->prefix)) {
                
                // store a mapping from this defined nsPtr to the one found higher
                // in the tree
                [nsMap setObject:[NSValue valueWithPointer:foundNS]
                          forKey:[NSValue valueWithPointer:definedNS]];
                
                // remove this namespace from the ns definition list of this node;
                // all child elements and attributes referencing this namespace
                // now have a dangling pointer and must be updated (that is done later
                // in this method)
                //
                // before we delete this namespace, move our pointer to the
                // next one
                xmlNsPtr nsToDelete = definedNS;
                definedNS = definedNS->next;
                
                [self deleteNamespacePtr:nsToDelete fromXMLNode:nodeToFix];
                
            } else {
                // this namespace wasn't a duplicate; move to the next
                definedNS = definedNS->next;
            }
        }
    }
    
    // if this node's namespace is one we deleted, update it to point
    // to someplace better
    if (nodeToFix->ns != NULL) {
        
        NSValue *currNS = [NSValue valueWithPointer:nodeToFix->ns];
        NSValue *replacementNS = [nsMap objectForKey:currNS];
        
        if (replacementNS != nil) {
            xmlNsPtr replaceNSPtr = (xmlNsPtr)[replacementNS pointerValue];
            
            xmlSetNs(nodeToFix, replaceNSPtr);
        }
    }
}



+ (void)fixUpNamespacesForNode:(xmlNodePtr)nodeToFix
            graftingToTreeNode:(xmlNodePtr)graftPointNode
      namespaceSubstitutionMap:(NSMutableDictionary *)nsMap {
    
    // This is the inner routine for fixUpNamespacesForNode:graftingToTreeNode:
    //
    // This routine fixes two issues:
    //
    // Because we can create nodes with qualified names before adding
    // them to the tree that declares the namespace for the prefix,
    // we need to set the node namespaces after adding them to the tree.
    //
    // Because libxml adds namespaces to nodes when it copies them,
    // we want to remove redundant namespaces after adding them to
    // a tree.
    //
    // If only the Mac's libxml had xmlDOMWrapReconcileNamespaces, it could do
    // namespace cleanup for us
    
    // We only care about fixing names of elements and attributes
    if (nodeToFix->type != XML_ELEMENT_NODE
        && nodeToFix->type != XML_ATTRIBUTE_NODE) return;
    
    // Do the fixes
    [self fixQualifiedNamesForNode:nodeToFix
                graftingToTreeNode:graftPointNode];
    
    [self fixDuplicateNamespacesForNode:nodeToFix
                     graftingToTreeNode:graftPointNode
               namespaceSubstitutionMap:nsMap];
    
    if (nodeToFix->type == XML_ELEMENT_NODE) {
        
        // when fixing element nodes, recurse for each child element and
        // for each attribute
        xmlNodePtr currChild = nodeToFix->children;
        while (currChild != NULL) {
            [self fixUpNamespacesForNode:currChild
                      graftingToTreeNode:graftPointNode
                namespaceSubstitutionMap:nsMap];
            currChild = currChild->next;
        }
        
        xmlAttrPtr currProp = nodeToFix->properties;
        while (currProp != NULL) {
            [self fixUpNamespacesForNode:(xmlNodePtr)currProp
                      graftingToTreeNode:graftPointNode
                namespaceSubstitutionMap:nsMap];
            currProp = currProp->next;
        }
    }
}

+ (void)fixUpNamespacesForNode:(xmlNodePtr)nodeToFix
            graftingToTreeNode:(xmlNodePtr)graftPointNode {
    
    // allocate the namespace map that will be passed
    // down on recursive calls
    NSMutableDictionary *nsMap = [NSMutableDictionary dictionary];
    
    [self fixUpNamespacesForNode:nodeToFix
              graftingToTreeNode:graftPointNode
        namespaceSubstitutionMap:nsMap];
}

@end


@interface GDataXMLDocument (PrivateMethods)
- (void)addStringsCacheToDoc;
@end

@implementation GDataXMLDocument

- (id)initWithXMLString:(NSString *)str options:(unsigned int)mask error:(NSError **)error {
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *doc = [self initWithData:data options:mask error:error];
    return doc;
}

- (id)initWithData:(NSData *)data options:(unsigned int)mask error:(NSError **)error {
    
    self = [super init];
    if (self) {
        
        const char *baseURL = NULL;
        const char *encoding = NULL;
        
        // NOTE: We are assuming [data length] fits into an int.
        xmlDoc_ = xmlReadMemory((const char*)[data bytes], (int)[data length], baseURL, encoding,
                                kGDataXMLParseOptions); // TODO(grobbins) map option values
        if (xmlDoc_ == NULL) {
            if (error) {
                *error = [NSError errorWithDomain:@"com.google.GDataXML"
                                             code:-1
                                         userInfo:nil];
                // TODO(grobbins) use xmlSetGenericErrorFunc to capture error
            }
            [self release];
            return nil;
        } else {
            if (error) *error = NULL;
            
            [self addStringsCacheToDoc];
        }
    }
    
    return self;
}

- (id)initWithRootElement:(GDataXMLElement *)element {
    
    self = [super init];
    if (self) {
        
        xmlDoc_ = xmlNewDoc(NULL);
        
        (void) xmlDocSetRootElement(xmlDoc_, [element XMLNodeCopy]);
        
        [self addStringsCacheToDoc];
    }
    
    return self;
}

- (void)addStringsCacheToDoc {
    // utility routine for init methods
    
#if DEBUG
    NSCAssert(xmlDoc_ != NULL && xmlDoc_->_private == NULL,
              @"GDataXMLDocument cache creation problem");
#endif
    
    // add a strings cache as private data for the document
    //
    // we'll use plain C pointers (xmlChar*) as the keys, and NSStrings
    // as the values
    CFIndex capacity = 0; // no limit
    
    CFDictionaryKeyCallBacks keyCallBacks = {
        0, // version
        StringCacheKeyRetainCallBack,
        StringCacheKeyReleaseCallBack,
        StringCacheKeyCopyDescriptionCallBack,
        StringCacheKeyEqualCallBack,
        StringCacheKeyHashCallBack
    };
    
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(
                                                            kCFAllocatorDefault, capacity,
                                                            &keyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // we'll use the user-defined _private field for our cache
    xmlDoc_->_private = dict;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p", [self class], self];
}

- (void)dealloc {
    if (xmlDoc_ != NULL) {
        // release the strings cache
        //
        // since it's a CF object, were anyone to use this in a GC environment,
        // this would need to be released in a finalize method, too
        if (xmlDoc_->_private != NULL) {
            CFRelease(xmlDoc_->_private);
        }
        
        xmlFreeDoc(xmlDoc_);
    }
    [super dealloc];
}

#pragma mark -

- (GDataXMLElement *)rootElement {
    GDataXMLElement *element = nil;
    
    if (xmlDoc_ != NULL) {
        xmlNodePtr rootNode = xmlDocGetRootElement(xmlDoc_);
        if (rootNode) {
            element = [GDataXMLElement nodeBorrowingXMLNode:rootNode];
        }
    }
    return element;
}

- (NSData *)XMLData {
    
    if (xmlDoc_ != NULL) {
        xmlChar *buffer = NULL;
        int bufferSize = 0;
        
        xmlDocDumpMemory(xmlDoc_, &buffer, &bufferSize);
        
        if (buffer) {
            NSData *data = [NSData dataWithBytes:buffer
                                          length:bufferSize];
            xmlFree(buffer);
            return data;
        }
    }
    return nil;
}

- (void)setVersion:(NSString *)version {
    
    if (xmlDoc_ != NULL) {
        if (xmlDoc_->version != NULL) {
            // version is a const char* so we must cast
            xmlFree((char *) xmlDoc_->version);
            xmlDoc_->version = NULL;
        }
        
        if (version != nil) {
            xmlDoc_->version = xmlStrdup(GDataGetXMLString(version));
        }
    }
}

- (void)setCharacterEncoding:(NSString *)encoding {
    
    if (xmlDoc_ != NULL) {
        if (xmlDoc_->encoding != NULL) {
            // version is a const char* so we must cast
            xmlFree((char *) xmlDoc_->encoding);
            xmlDoc_->encoding = NULL;
        }
        
        if (encoding != nil) {
            xmlDoc_->encoding = xmlStrdup(GDataGetXMLString(encoding));
        }
    }
}

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error {
    return [self nodesForXPath:xpath namespaces:nil error:error];
}

- (NSArray *)nodesForXPath:(NSString *)xpath
                namespaces:(NSDictionary *)namespaces
                     error:(NSError **)error {
    if (xmlDoc_ != NULL) {
        GDataXMLNode *docNode = [GDataXMLElement nodeBorrowingXMLNode:(xmlNodePtr)xmlDoc_];
        NSArray *array = [docNode nodesForXPath:xpath
                                     namespaces:namespaces
                                          error:error];
        return array;
    }
    return nil;
}

@end

//
// Dictionary key callbacks for our C-string to NSString cache dictionary
//
static const void *StringCacheKeyRetainCallBack(CFAllocatorRef allocator, const void *str) {
    // copy the key
    xmlChar* key = xmlStrdup(str);
    return key;
}

static void StringCacheKeyReleaseCallBack(CFAllocatorRef allocator, const void *str) {
    // free the key
    char *chars = (char *)str;
    xmlFree((char *) chars);
}

static CFStringRef StringCacheKeyCopyDescriptionCallBack(const void *str) {
    // make a CFString from the key
    CFStringRef cfStr = CFStringCreateWithCString(kCFAllocatorDefault,
                                                  (const char *)str,
                                                  kCFStringEncodingUTF8);
    return cfStr;
}

static Boolean StringCacheKeyEqualCallBack(const void *str1, const void *str2) {
    // compare the key strings
    if (str1 == str2) return true;
    
    int result = xmlStrcmp(str1, str2);
    return (result == 0);
}

static CFHashCode StringCacheKeyHashCallBack(const void *str) {
    
    // dhb hash, per http://www.cse.yorku.ca/~oz/hash.html
    CFHashCode hash = 5381;
    int c;
    const char *chars = (const char *)str;
    
    while ((c = *chars++) != 0) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}