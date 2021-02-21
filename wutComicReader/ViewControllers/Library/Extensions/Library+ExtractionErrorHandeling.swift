//
//  Library+ExtractionErrorHandeling.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/15/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import Foundation
import UIKit

extension LibraryVC: ExtractorErrorDelegate, AppFileManagerErrorDelegate {
    func errorsAccured(errors: [ComicExteractor.ExtractorError]) {
        
        var messages = [String]()
        
        for error in errors {
            switch error.type {
            case .unsupportFileFormat:
                messages.append("Unvalid File Format: cant extract \(error.fileName), only .cbz, .cbr, .pdf is supported.")
                
            case .comicAlreadyExtracted:
                messages.append("File Already Exists: Comic with name of \(error.fileName) already exist.")
                
            case .createExtractionDirectories:
                messages.append("Can't create a directory for \(error.fileName)")
                
            case .comicExtracting(let extractingError):
                switch extractingError {
                case .unzipCBZ:
                    messages.append("Can't unzip \(error.fileName)")
                case .unrarCBR:
                    messages.append("Can't unarchive \(error.fileName)")
                case .convertPDFtoImages:
                    messages.append("Can't convert \(error.fileName) pages to images")
                
                }
                
            }
        }
        
        newComicsErrorsDescription = configureDescription(of: messages)
    }
    
    func errorsAccuredWhenWritingOnDataBase(errors: [FileManagerError]) {
        
        var messages = [String]()
        
        for error in errors {
            //comic file has an extraction problem and it probably gonna has a filemanagerError
            //we already add its extraction error, better not to add its filemanager error.
            if let comicName = error.comicName,
               newComicsErrorsDescription.contains(comicName) { continue }
            
            
            switch error.type {
            case .cantWriteOnCoreData:
                messages.append("Can't write \(error.comicName!) on database.")
                
            case .cantReadComicDirectory:
                messages.append("Can't read extracted comics directory info.")
                
            case .emptyFile:
                messages.append("\(error.comicName!) has no supported images.")
            }
        }
        
        newComicsErrorsDescription += configureDescription(of: messages)
    }
    
    func configureDescription(of array: [String]) -> String {
        var description = ""
        for message in array {
            description += "- " + message + "\n"
        }
        return description
    }
    
    func showExtractionErrorsIfExist() {
        if !newComicsErrorsDescription.isEmpty {
            showAlert(with: "Can't extract some of your comics files.",
                      description: newComicsErrorsDescription)
            
            newComicsErrorsDescription = ""
        }
    }
}
