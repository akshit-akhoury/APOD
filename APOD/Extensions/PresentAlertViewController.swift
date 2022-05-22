//
//  PresentAlertViewController.swift
//  APOD
//
//  Created by Akshit Akhoury on 23/05/22.
//

import UIKit

extension UIViewController {
    func presentAlert(title:String?,message:String?)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
