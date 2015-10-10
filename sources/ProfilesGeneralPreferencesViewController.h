//
//  ProfilesGeneralPreferencesViewController.h
//  iTerm
//
//  Created by George Nachman on 4/11/14.
//
//

#import "iTermProfilePreferencesBaseViewController.h"

@protocol ProfilesGeneralPreferencesViewControllerDelegate <NSObject>

- (void)profilesGeneralPreferencesNameWillChange;

// This should be called only for "edit info" dialogs when the name field resigns first responder.
- (void)profilesGeneralPreferencesNameDidEndEditing;

@end

@interface ProfilesGeneralPreferencesViewController : iTermProfilePreferencesBaseViewController

@property(nonatomic, unsafe_unretained) IBOutlet id<ProfilesGeneralPreferencesViewControllerDelegate> profileDelegate;
@property(weak, nonatomic, readonly) NSTextField *profileNameField;
@property(weak, nonatomic, readonly) NSTextField *profileNameFieldForEditCurrentSession;
@property(weak, nonatomic, readonly) NSString *selectedGuid;

- (void)layoutSubviewsForEditCurrentSessionMode;
- (void)updateShortcutTitles;
- (void)windowWillClose;

@end
