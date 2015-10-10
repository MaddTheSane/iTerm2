#import <Cocoa/Cocoa.h>

// Generates a small iTerm2 logo with custom text, cursor, background, and tab
// colors. All color properties must be set before a logo can be generated.
@interface iTermLogoGenerator : NSObject

@property(nonatomic, strong) NSColor *textColor;
@property(nonatomic, strong) NSColor *cursorColor;
@property(nonatomic, strong) NSColor *backgroundColor;
@property(nonatomic, strong) NSColor *tabColor;

- (NSImage *)generatedImage;

@end
