//
//  +UIImage.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/17/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

//TODO: Make it a class
extension UIImage {
     func getPixelColor(pos: CGPoint) -> UIColor? {

         guard let pixelData = self.cgImage?.dataProvider?.data else { return nil }
         let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

         let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
         //FIXME: pixelfInfo ois out of the range probably
         
         let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
         let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
         let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
         let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

         return UIColor(red: r, green: g, blue: b, alpha: a)
         
     }
 }

