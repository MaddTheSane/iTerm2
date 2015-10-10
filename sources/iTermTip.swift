//
//  iTermTip.swift
//  iTerm2
//
//  Created by C.W. Betts on 10/10/15.
//
//

import Foundation


/// A tip of the day.
final class iTermTip: NSObject {
    let identifier: String
    let title: String
    let body: String
    let url: String
    
    init(dictionary: Dictionary<String, String>, identifier: String) {
        self.identifier = identifier;
        self.title = dictionary[kTipTitleKey]!;
        self.body = dictionary[kTipBodyKey]!;
        self.url = dictionary[kTipUrlKey]!;
        
        super.init()
    }
}
