//
//  UIControllerPreview.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/13/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import SwiftUI

struct UIKitPreview: UIViewRepresentable {
    
    typealias UIViewType = UIView
    let view: UIViewType
    
    func makeUIView(context: Context) -> UIView {
        view
    }
    
    func updateUIView(_ uiViewController: UIViewType, context: Context) {
        
    }
}
