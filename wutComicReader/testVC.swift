//
//  testVC.swift
//  wutComicReader
//
//  Created by Sha Yan on 12/22/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class testVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let string = "/Users/shayan/Library/Developer/CoreSimulator/Devices/96F62763-7709-4027-9D97-8E3A00869D10/data/Containers/Data/Application/DF2D6432-8DF2-4397-8880-BA6186FB0F06/Library/wutComic/Extracted-The Mask - I Pledge Allegiance to the Mask 001 (2019) (digital) (Son of Ultron-Empire)/The Mask - I Pledge Allegiance to the Mask 001-000.jpg"
        
        let comicImage = UIImage(contentsOfFile: string)
        imageView.image = comicImage
    }
    

    

}
