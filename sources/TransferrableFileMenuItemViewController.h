//
//  TransferrableFileMenuItemViewController.h
//  iTerm
//
//  Created by George Nachman on 12/23/13.
//
//

#import <Cocoa/Cocoa.h>
#import "TransferrableFile.h"

@interface TransferrableFileMenuItemViewController : NSViewController

@property(nonatomic, strong) TransferrableFile *transferrableFile;
@property(nonatomic, strong) NSMenuItem *stopSubItem;
@property(nonatomic, strong) NSMenuItem *showInFinderSubItem;
@property(nonatomic, strong) NSMenuItem *removeFromListSubItem;
@property(nonatomic, strong) NSMenuItem *openSubItem;

- (id)initWithTransferrableFile:(TransferrableFile *)transferrableFile;
- (void)update;
- (void)itemSelected:(id)sender;
- (NSTimeInterval)timeSinceLastStatusChange;

- (void)stop:(id)sender;
- (void)showInFinder:(id)sender;
- (void)removeFromList:(id)sender;
- (void)open:(id)sender;
- (void)getInfo:(id)sender;

@end
