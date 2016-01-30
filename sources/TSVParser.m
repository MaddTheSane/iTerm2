//
//  TSVParser.m
//  iTerm
//
//  Created by George Nachman on 11/27/11.
//

#import "TSVParser.h"


@implementation TSVDocument {
    NSMutableDictionary *map_;
}

@synthesize columns = columns_;
@synthesize records = records_;

- (instancetype)init {
    self = [super init];
    if (self) {
        records_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)valueInRecord:(NSArray *)record forField:(NSString *)fieldName
{
    if (!map_) {
        map_ = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < self.columns.count; i++) {
            [map_ setObject:[NSNumber numberWithInt:i]
                     forKey:[self.columns objectAtIndex:i]];
        }
    }

    NSNumber *n = [map_ objectForKey:fieldName];
    int i = [n intValue];
    if (n && i < [record count]) {
        return [record objectAtIndex:i];
    }
    return nil;
}

@end

@implementation TSVParser

+ (TSVDocument *)documentFromString:(NSString *)string withFields:(NSArray *)fields
{
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    if ([lines count] == 0) {
        return nil;
    }
    TSVDocument *doc = [[TSVDocument alloc] init];
    doc.columns = [fields copy];
    for (int i = 0; i < lines.count; i++) {
        NSString *row = [lines objectAtIndex:i];
        NSArray *rowArray = [row componentsSeparatedByString:@"\t"];
        if (rowArray.count >= fields.count) {
            [doc.records addObject:rowArray];
        }
    }
    return doc;
}

@end

@implementation NSString (TSV)

- (TSVDocument *)tsvDocumentWithFields:(NSArray *)fields
{
    return [TSVParser documentFromString:self withFields:fields];
}

@end
