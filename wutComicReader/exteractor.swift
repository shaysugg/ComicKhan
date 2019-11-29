//
//  exteractor.swift
//  
//
//  Created by Shayan on 7/9/19.
//

import Foundation
import ZIPFoundation
import UnrarKit

extension LibraryVC {
    
    func unzipingCBZ(fileName : String){
        
//        let zipFilePath = Bundle.main.path(forResource: fileName, ofType: ".cbz")
//        let zipFileURL = URL(fileURLWithPath: zipFilePath!)
        
        
        
        let zipFileURL = appDirectory!.appendingPathComponent(fileName)
        print(zipFileURL)
        
        
        
//        let dataPath = appDirectory!.appendingPathComponent("Extracted-" + fileName)
//        let restoreZipFilesURL = URL(fileURLWithPath: dataPath.path)
//
//        do {
//            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
//            try FileManager.default.unzipItem(at: zipFileURL, to: restoreZipFilesURL)
//        } catch let error as NSError {
//            print("Error creating directory: \(error.localizedDescription)")
//        }
    }
    
    
    
    
    func unzipingCBR(fileName : String , complition : (_ error : Error?) -> ()){
        let zipFilePath = userDiractory!.appendingPathComponent(fileName + ".cbr")
        
        let extractedComicsURL = appDirectory!.appendingPathComponent("Extracted-" + fileName)
        
        //first make sure that file doesnt exist already!
        
        var archive : URKArchive?
        
        do{
            try FileManager.default.createDirectory(at: extractedComicsURL, withIntermediateDirectories: true, attributes: nil)
            
            archive = try URKArchive(path: zipFilePath.path)
            try archive?.extractFiles(to: extractedComicsURL.path, overwrite: true, progress: nil)
            complition(nil)
            
        }catch let err {
            print("error while initialing URKArchive" + err.localizedDescription)
            deleteFile(at: extractedComicsURL.path)
            complition(err)
            return
        }
    }
    
}
