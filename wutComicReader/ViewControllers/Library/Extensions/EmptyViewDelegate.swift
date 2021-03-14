//
//  HowToDelegate.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/15/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit


extension LibraryVC: EmptyViewDelegate {
    func copyrightButtonDidTapped() {
        showAlert(with: "Zelfportret met hand aan snor (1917)", description: "By Samuel Jessurun de Mesquita (Dutch, 1868 – 1944)\nThe Artist died in 1944 so this work is in the public domain in its country of origin and other countries where the copyright term is the Artist's life plus 70 years or fewer.\n Source: artvee.com")
        

    }
    
    func importComicsButtonTapped() {
        presentDocumentPicker()
    }
    
}
