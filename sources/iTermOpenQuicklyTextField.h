#import <Cocoa/Cocoa.h>

@protocol iTermOpenQuicklyTextFieldDelegate <NSObject>
- (void)keyDown:(NSEvent *)event;
@end

// A text field that passes arrow keys to its arrowHandler.
@interface iTermOpenQuicklyTextField : NSTextField

@property(nonatomic, unsafe_unretained) IBOutlet id<iTermOpenQuicklyTextFieldDelegate> arrowHandler;

@end
