//
//  iTermInstantReplayWindowController.h
//  iTerm
//
//  Created by George Nachman on 3/15/14.
//
//

#import <Cocoa/Cocoa.h>

@protocol iTermInstantReplayDelegate <NSObject>
- (void)replaceSyntheticActiveSessionWithLiveSessionIfNeeded;
- (void)instantReplaySeekTo:(float)position;
- (void)instantReplayStep:(int)direction;

// Returns timestamp in microseconds or -1 if live.
- (long long)instantReplayCurrentTimestamp;

- (long long)instantReplayFirstTimestamp;
- (long long)instantReplayLastTimestamp;

@end

@interface iTermInstantReplayPanel : NSPanel
@end

@interface iTermInstantReplayView :NSView
@end

@interface iTermInstantReplayWindowController : NSWindowController <NSWindowDelegate>

@property(nonatomic, unsafe_unretained) id<iTermInstantReplayDelegate> delegate;

- (void)updateInstantReplayView;

@end
