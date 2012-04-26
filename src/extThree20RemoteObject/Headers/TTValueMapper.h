//
// Copyright 2012 RIKSOF
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#define VALUEMAPPER_WRITE_ELEMENT    1
#define VALUEMAPPER_WRITE_ATTRIBUTE  2
#define VALUEMAPPER_WRITE_CHILD      3

@interface TTValueMapper : NSObject <NSCopying> {
    NSMutableArray              *documentToObjectMappers;
    NSMutableArray              *keysForDocumentToObjectMappers;
    NSMutableArray              *objectToDocumentMappers;
    NSMutableArray              *keysForObjectToDocumentMappers;
}

- (BOOL)documentToObjectForClass:(Class)valueClass object:(id)object property:(NSString *)property values:(id)values value:(id)value;
- (BOOL)objectToDocumentForClass:(Class)valueClass document:(id)document property:(NSString *)property mode:(int)mode value:(id)value;
- (void)addDocumentToObjectMapperForClass:(Class)valueClass conversionBlock:(void(^)(id, NSString *, __unsafe_unretained Class, id, id))conversionBlock;
- (void)removeDocumentToObjectMapperForClass:(Class)valueClass;
- (void)addObjectToDocumentMapperForClass:(Class)valueClass conversionBlock:(void(^)(id, NSString *, int, id))conversionBlock;
- (void)removeObjectToDocumentMapperForClass:(Class)valueClass;


- (id)initWithCopyOfMapper:(NSArray *)documentToObject keysDocToObj:(NSArray *)keysDocToObj 
          objectToDocument:(NSArray *)objectToDocument keysObjToDoc:(NSArray *)keysObjToDoc;

+ (TTValueMapper *)sharedInstance;

@end
