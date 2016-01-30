//
//  SCPPath.m
//  iTerm
//
//  Created by George Nachman on 12/21/13.
//
//

#import "SCPPath.h"

@implementation SCPPath

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p hostname=%@ username=%@ path=%@>",
            self.class, self, self.hostname, self.username, self.path];
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"%@@%@:%@", _username, _hostname, _path];
}

- (NSURL *)URL {
    return [NSURL URLWithString:self.stringValue];
}

@end
