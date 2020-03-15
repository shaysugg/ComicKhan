//
//  HowToVC.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/15/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

class HowToVC: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.layer.cornerRadius = dismissButton.bounds.width * 0.5
        dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 10)
    }
}
