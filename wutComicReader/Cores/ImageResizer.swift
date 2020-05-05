//
//  ImageResizer.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/10/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ImageResizer {
    private var imagePaths: [String]?
    private var diractoryForResizedImages: URL?
    
    convenience init(for imagePaths: [String], saveTo path: URL) {
        self.init()
        self.imagePaths = imagePaths
        self.diractoryForResizedImages = path
        
    }
    
    func startResizing(progress: (Double)->()) {
        guard
            let paths = imagePaths,
            let _ = diractoryForResizedImages
            else { return }
        
        var count: Double = 0
        for path in paths {
           
            if let image = UIImage(contentsOfFile: path) {
                
                let isImageisDoubleSplash = image.size.width > image.size.height
                if count == 0 {
                resize(image,
                       withName: imageName(fromPath: path),
                       withSize: CGSize(width: (isImageisDoubleSplash ? 600 : 300), height: 450))
                }else{
                    resize(image,
                    withName: imageName(fromPath: path),
                    withSize: CGSize(width: (isImageisDoubleSplash ? 200 : 100), height: 150))
                }
                count += 1
                progress(count / Double(paths.count))
            }
        }
    }
    
    private func resize(_ image: UIImage, withName name: String ,withSize resizeSize: CGSize) {
        
        let render = UIGraphicsImageRenderer(size: resizeSize)
        let data = render.jpegData(withCompressionQuality: 0.5) { (context) in
            image.draw(in: CGRect(origin: .zero, size: resizeSize))
        }
        do{
            try data.write(to: diractoryForResizedImages!.appendingPathComponent(name))
        }catch let error{
            print("error happend in resizing an image" + error.localizedDescription)
        }
            
    }
    
    private func imageName(fromPath path: String) -> String {
       
        let lastSlashIndex = path.lastIndex(of: "/")!
        return path.substring(from: lastSlashIndex)
    }
    
    
    func resize(_ image: UIImage?, to size: CGSize) -> UIImage? {
        guard let img = image else { return nil }
        
        let render = UIGraphicsImageRenderer(size: size)
        let resizedImage = render.image(actions: { _ in
            img.draw(in: CGRect(origin: .zero, size: size))
        })
        return resizedImage
    }
}
