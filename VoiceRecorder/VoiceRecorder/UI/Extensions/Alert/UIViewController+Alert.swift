//
//  UIViewController+Alert.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import UIKit

typealias AlertAction = (_ action: UIAlertAction) -> Void

extension UIViewController
{
    @discardableResult func showAlertWithTitle(title: String, message: String) -> UIAlertController
    {
        return self.showAlertWithTitle(title: title, message: message, cancelAction: nil, okAction: { a in }, okActionName: nil)
    }
    
    @discardableResult func showAlertWithTitle(title: String, message: String, cancelAction: @escaping AlertAction) -> UIAlertController
    {
        return self.showAlertWithTitle(title: title, message: message, cancelAction: cancelAction, okAction: nil, okActionName: nil)
    }
    
    @discardableResult func showAlertWithTitle(title: String, message: String, cancelAction: AlertAction?, okAction: AlertAction?, okActionName: String?) -> UIAlertController
    {
        return self.showAlertWithTitle(title: title, message: message, cancelAction: cancelAction, cancelActionName: nil, okAction: okAction!, okActionName: okActionName)
    }
    
    @discardableResult func showAlertWithTitle(title: String, message: String, cancelAction: AlertAction?, cancelActionName: String?, okAction: AlertAction?, okActionName: String?) -> UIAlertController
    {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelAction != nil
        {
            let title: String = (cancelActionName != nil ? cancelActionName! : "Cancel".localized(tableName: "Base"))
            alert.addAction(UIAlertAction(title: title, style: .cancel, handler: cancelAction))
        }
        
        if okAction != nil
        {
            let title: String = (okActionName != nil ? okActionName! : "OK".localized(tableName: "Base"))
            alert.addAction(UIAlertAction(title: title, style: .default, handler: okAction))
        }
        
        self.present(alert, animated: true, completion: { _ in })
        
        return alert
    }
}
