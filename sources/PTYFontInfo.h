//
//  PTYFontInfo.h
//  iTerm
//
//  Created by George Nachman on 12/17/12.
//
//

#import <Cocoa/Cocoa.h>

// A collection of data about a font.
@interface PTYFontInfo : NSObject {
    NSFont *font_;
    double baselineOffset_;
    PTYFontInfo *boldVersion_;
    PTYFontInfo *italicVersion_;
}

@property (nonatomic, strong) NSFont *font;
@property (nonatomic, assign) double baselineOffset;
@property (nonatomic, strong) PTYFontInfo *boldVersion;
@property (nonatomic, strong) PTYFontInfo *italicVersion;
@property (nonatomic, strong) PTYFontInfo *boldItalicVersion;

+ (PTYFontInfo *)fontInfoWithFont:(NSFont *)font baseline:(double)baseline;

// Returns a new autorelased PTYFontInfo with a bold version of this font (or
// nil if none is available).
- (PTYFontInfo *)computedBoldVersion;

// Returns a new autorelased PTYFontInfo with a bold version of this font (or
// nil if none is available).
- (PTYFontInfo *)computedItalicVersion;


// Returns a new autorelased PTYFontInfo with a bold and italic version of this font (or nil if none
// is available).
- (PTYFontInfo *)computedBoldItalicVersion;

@end
