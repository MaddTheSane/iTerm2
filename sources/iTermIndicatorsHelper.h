//
//  iTermIndicatorsHelper.h
//  iTerm2
//
//  Created by George Nachman on 11/23/14.
//
//

#import <Cocoa/Cocoa.h>

extern NSString *const kiTermIndicatorBell;
extern NSString *const kiTermIndicatorWrapToTop;
extern NSString *const kiTermIndicatorWrapToBottom;

extern NSString *const kiTermIndicatorMaximized;
extern NSString *const kItermIndicatorBroadcastInput;
extern NSString *const kiTermIndicatorCoprocess;
extern NSString *const kiTermIndicatorAlert;
extern NSString *const kiTermIndicatorAllOutputSuppressed;
extern NSString *const kiTermIndicatorZoomedIn;

extern CGFloat kiTermIndicatorStandardHeight;

@protocol iTermIndicatorsHelperDelegate <NSObject>

- (void)setNeedsDisplay:(BOOL)needsDisplay;
- (NSColor *)indicatorFullScreenFlashColor;

@end

@interface iTermIndicatorsHelper : NSObject

@property(nonatomic, unsafe_unretained) id<iTermIndicatorsHelperDelegate> delegate;

- (void)setIndicator:(NSString *)identifier visible:(BOOL)visible;
- (void)beginFlashingIndicator:(NSString *)identifier;
@property (readonly) NSInteger numberOfVisibleIndicators;
- (void)beginFlashingFullScreen;
- (void)drawInFrame:(NSRect)frame;

@end
