//
//  SmartMatch.m
//  iTerm
//
//  Created by George Nachman on 12/26/13.
//
//

#import "SmartMatch.h"

@implementation SmartMatch

- (NSComparisonResult)compare:(SmartMatch *)other
{
    return [[NSNumber numberWithDouble:_score] compare:[NSNumber numberWithDouble:other.score]];
}

@end

