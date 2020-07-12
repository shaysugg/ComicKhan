//
//  Library+DocumentBrowser.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/3/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

extension LibraryVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        do{
            try appfileManager.moveFilesToUserDiractory(urls: urls)
        }catch let err {
            showAlert(with: "Oh! A problem happend while moving your files. Please try again.",
                      description:  " \(err.localizedDescription)")
            removeProgressView()
        }
    }
}
