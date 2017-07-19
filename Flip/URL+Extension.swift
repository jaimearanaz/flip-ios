//
//  URL+extension.swift
//  SalesTool
//
//  Created by Jaime Aranaz on 16/02/2017.
//  Copyright © 2017 Corpora360. All rights reserved.
//

import Foundation
import UIKit

extension NSURL {
    
    func isHTTPUrl() -> Bool {
        
        if let absoluteString = self.absoluteString {
            return (absoluteString.hasPrefix("http://") || absoluteString.hasPrefix("https://"))
        } else {
            return false
        }
    }
    
    func isLocalFileUrl() -> Bool {
        
        if let absoluteString = self.absoluteString {
            return (absoluteString.hasPrefix("file://"))
        } else {
            return false
        }
    }
}
