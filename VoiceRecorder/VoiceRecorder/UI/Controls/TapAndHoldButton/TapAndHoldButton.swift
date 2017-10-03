//
//  TapAndHoldButton.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import UIKit

typealias TapAndHoldButtonTouchBlock = ((TapAndHoldButton) -> Void)

// Add a new behavior to the button.

class TapAndHoldButton: UIButton
{
    var didReceiveTouch: TapAndHoldButtonTouchBlock?
    var didReleaseTouch: TapAndHoldButtonTouchBlock?
    
    // MARK: - Grab touches.
    
    // Get notified about changes of 'isHighlighted' property wihtout KVO.
    
    override var isHighlighted: Bool
    {
        get
        {
            return super.isHighlighted
        }
        
        set
        {
            if super.isHighlighted != newValue
            {
                super.isHighlighted = newValue
                self.didChangeHighlightedState()
            }
        }
    }
    
    private func didChangeHighlightedState()
    {
        if (isHighlighted)
        {
            didReceiveTouch?(self)
        }
        else {
            didReleaseTouch?(self)
        }
    }
}
