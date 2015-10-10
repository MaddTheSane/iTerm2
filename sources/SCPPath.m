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

@end
