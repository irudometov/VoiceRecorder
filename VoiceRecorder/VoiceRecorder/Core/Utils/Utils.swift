//
//  Utils.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import UIKit

// A helper for common tasks.

class Utils
{
    class func trimSlashPrefix(from string: String) -> String
    {
        if string.hasPrefix("/")
        {
            return String(string.dropFirst())
        }
        
        return string
    }
}
