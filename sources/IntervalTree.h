#import <Foundation/Foundation.h>
#import "AATree.h"

@class IntervalTreeEntry;

@interface Interval : NSObject<NSCopying>
// Negative locations have special meaning. Don't use them.
@property(nonatomic, assign) long long location;
@property(nonatomic, assign) long long length;

+ (instancetype)intervalWithLocation:(long long)location length:(long long)length;
+ (Interval *)maxInterval;
// One more than the largest value in the interval.
@property (readonly) long long limit;
- (BOOL)intersects:(Interval *)other;
- (BOOL)isEqualToInterval:(Interval *)interval;

// Serialized value.
- (NSDictionary *)dictionaryValue;

@end

@protocol IntervalTreeObject <NSObject>
// Deserialize from dictionaryValue.
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property(nonatomic, assign) IntervalTreeEntry *entry;

// Serialized value.
- (NSDictionary *)dictionaryValue;
@end

// A node in the interval tree will contain one or more entries, each of which has an interval and an object. All intervals should have the same location.
@interface IntervalTreeEntry : NSObject
@property(nonatomic, strong) Interval *interval;
@property(nonatomic, strong) id<IntervalTreeObject> object;

+ (IntervalTreeEntry *)entryWithInterval:(Interval *)interval object:(id<IntervalTreeObject>)object;
@end

@interface IntervalTreeValue : NSObject
@property(nonatomic, assign) long long maxLimitAtSubtree;
@property(nonatomic, strong) NSMutableArray *entries;

// Largest limit of all entries
@property (readonly) long long maxLimit;

// Interval including intervals of all entries at this entry exactly
- (Interval *)spanningInterval;

@end

@interface IntervalTree : NSObject <AATreeDelegate> {
    AATree *_tree;
    int _count;
}

// Deserialize
- (instancetype)initWithDictionary:(NSDictionary *)dict;

// |object| should implement -hash.
- (void)addObject:(id<IntervalTreeObject>)object withInterval:(Interval *)interval;
- (void)removeObject:(id<IntervalTreeObject>)object;
- (NSArray<IntervalTreeObject> *)objectsInInterval:(Interval *)interval;
- (NSArray<IntervalTreeObject> *)allObjects;
@property (readonly) NSInteger count;
- (BOOL)containsObject:(id<IntervalTreeObject>)object;

// Returns the object with the highest limit
- (NSArray<IntervalTreeObject> *)objectsWithLargestLimit;
// Returns the object with the smallest limit
- (NSArray<IntervalTreeObject> *)objectsWithSmallestLimit;

// Returns the object with the largest location
- (NSArray<IntervalTreeObject> *)objectsWithLargestLocation;

// Returns the object with the largest location before (but NOT AT) |location|.
- (NSArray<IntervalTreeObject> *)objectsWithLargestLocationBefore:(long long)location;

- (NSArray<IntervalTreeObject> *)objectsWithLargestLimitBefore:(long long)limit;
- (NSArray<IntervalTreeObject> *)objectsWithSmallestLimitAfter:(long long)limit;

// Enumerates backwards by location (NOT LIMIT)
- (NSEnumerator<IntervalTreeObject> *)reverseEnumeratorAt:(long long)start;

- (NSEnumerator<IntervalTreeObject> *)reverseLimitEnumeratorAt:(long long)start;
- (NSEnumerator<IntervalTreeObject> *)forwardLimitEnumeratorAt:(long long)start;
- (NSEnumerator<IntervalTreeObject> *)reverseLimitEnumerator;
- (NSEnumerator<IntervalTreeObject> *)forwardLimitEnumerator;

- (void)sanityCheck;
@property (readonly, copy) NSString *debugString;

// Serialize, adding offset to interval locations (useful for taking the tail
// of an interval tree).
- (NSDictionary *)dictionaryValueWithOffset:(long long)offset;

@end
