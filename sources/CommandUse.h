//
//  CommandUse.h
//  iTerm
//
//  Created by George Nachman on 1/19/14.
//
//

#import <Foundation/Foundation.h>

@class VT100ScreenMark;

@interface CommandUse : NSObject <NSCopying>

@property(nonatomic, assign) NSTimeInterval time;

// Optional.
@property(nonatomic, strong) NSString *command;

// Setting this actually sets the markGuid.
@property(nonatomic, strong) VT100ScreenMark *mark;
@property(nonatomic, strong) NSString *directory;

// This is used to figure out which mark matches this command use when deserializing marks.
@property(nonatomic, readonly, copy) NSString *markGuid;

// Optional status code. Unset implies code 0.
@property(nonatomic, strong) NSNumber *code;

+ (instancetype)commandUseFromSerializedValue:(NSArray *)serializedValue;
- (NSArray *)serializedValue;

@end
