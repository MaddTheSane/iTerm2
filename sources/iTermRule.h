//
//  iTermRule.h
//  iTerm
//
//  Created by George Nachman on 6/24/14.
//
//

#import <Foundation/Foundation.h>

@interface iTermRule : NSObject
@property(nonatomic, readonly, copy) NSString *username;
@property(nonatomic, readonly, copy) NSString *hostname;
@property(nonatomic, readonly, copy) NSString *path;

+ (instancetype)ruleWithString:(NSString *)string;
- (int)scoreForHostname:(NSString *)hostname
               username:(NSString *)username
                   path:(NSString *)path;

@end
