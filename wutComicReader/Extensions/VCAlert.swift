//
//  VCAlert.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(with title: String, description: String, dismissButtonTitle: String? = "OK") {
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let actionButton = UIAlertAction(title: dismissButtonTitle, style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(actionButton)
        present(alert, animated: true)
    }
}
