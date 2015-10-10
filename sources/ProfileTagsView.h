//
//  ProfileTagsView.h
//  iTerm
//
//  Created by George Nachman on 1/4/14.
//
//

#import <Cocoa/Cocoa.h>

@class ProfileTagsView;

@protocol ProfileTagsViewDelegate <NSObject>

- (void)profileTagsViewSelectionDidChange:(ProfileTagsView *)profileTagsView;

@end

@interface ProfileTagsView : NSView <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, unsafe_unretained) id<ProfileTagsViewDelegate> delegate;
@property(weak, nonatomic, readonly) NSArray *selectedTags;

- (void)setFont:(NSFont *)font;

@end
