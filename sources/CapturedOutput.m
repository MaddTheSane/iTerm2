//
//  CapturedOutput.m
//  iTerm2
//
//  Created by George Nachman on 5/23/15.
//
//

#import "CapturedOutput.h"
#import "CaptureTrigger.h"
#import "iTermCapturedOutputMark.h"
#import "NSDictionary+iTerm.h"
#import "NSObject+iTerm.h"
#import "VT100ScreenMark.h"

NSString *const kCapturedOutputLineKey = @"Line";
NSString *const kCapturedOutputValuesKey = @"Values";
NSString *const kCapturedOutputTriggerHashKey = @"Trigger Hash";
NSString *const kCapturedOutputStateKey = @"State";
NSString *const kCapturedOutputMarkGuidKey = @"Mark Guid";

@interface CapturedOutput()
@property(nonatomic, strong) NSData *triggerDigest;
@end

@implementation CapturedOutput

+ (instancetype)capturedOutputWithDictionary:(NSDictionary *)dict {
    CapturedOutput *capturedOutput = [[CapturedOutput alloc] init];
    if (capturedOutput) {
        capturedOutput.line = dict[kCapturedOutputLineKey];
        capturedOutput.values = dict[kCapturedOutputValuesKey];
        capturedOutput.triggerDigest = dict[kCapturedOutputTriggerHashKey];
        capturedOutput.state = [dict[kCapturedOutputStateKey] boolValue];
        capturedOutput.markGuid = [dict[kCapturedOutputMarkGuidKey] copy];
    }
    return capturedOutput;
}

- (void)setKnownTriggers:(NSArray *)knownTriggers {
    if (!_trigger && _triggerDigest) {
        for (CaptureTrigger *trigger in knownTriggers) {
            if ([trigger isKindOfClass:[CaptureTrigger class]] &&
                [trigger.digest isEqual:_triggerDigest]) {
                self.trigger = trigger;
                self.triggerDigest = nil;
                return;
            }
        }
    }
}

- (NSDictionary *)dictionaryValue {
    NSDictionary *dict =
        @{ kCapturedOutputLineKey: _line ?: [NSNull null],
         kCapturedOutputValuesKey: _values ?: @[],
    kCapturedOutputTriggerHashKey: _trigger.digest ?: [NSData data],
          kCapturedOutputStateKey: @(_state),
       kCapturedOutputMarkGuidKey: _mark.guid ?: @"Mark Missing" };

    return [dict dictionaryByRemovingNullValues];
}

@end
