#import "VT100StateTransition.h"

@implementation VT100StateTransition

+ (instancetype)transitionToState:(VT100State *)toState withAction:(VT100StateAction)action {
    VT100StateTransition *transition = [[self alloc] init];
    transition.toState = toState;
    transition.action = action;
    return transition;
}

@end

