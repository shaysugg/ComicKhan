//
//  HowToDelegate.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/15/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit


extension LibraryVC: EmptyViewDelegate {
    func howAddComicsButtonTapped() {
        let howToVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HowToVC") as! HowToVC
        present(howToVC, animated: true)
    }
    
    
}
