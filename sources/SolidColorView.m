//
//  SolidColorView.m
//  iTerm
//
//  Created by George Nachman on 12/6/11.
//

#import "SolidColorView.h"

@implementation SolidColorView {
    BOOL _isFlipped;
}

- (instancetype)initWithFrame:(NSRect)frame color:(NSColor*)color {
    self = [super initWithFrame:frame];
    if (self) {
        _color = color;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p frame=%@ isHidden=%@ alphaValue=%@>",
            [self class], self, NSStringFromRect(self.frame), @(self.isHidden), @(self.alphaValue)];
}

- (void)drawRect:(NSRect)dirtyRect {
    [_color setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void)setColor:(NSColor*)color {
    _color = color;
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
    return _isFlipped;
}

- (void)setFlipped:(BOOL)value {
    _isFlipped = value;
}

@end
