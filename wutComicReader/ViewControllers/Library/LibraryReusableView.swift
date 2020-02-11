//
//  LibraryReusableView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/9/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

protocol CellsEditableWithSectionDelegate {
    func selectCellsOfSection(with indexSet: Int)
    func diSelectCellsOfSection(with indexSet: Int)
}

class LibraryReusableView: UICollectionReusableView {
    
    var isEditing = false {
        didSet{
//            changeUI(forEditingMode: isEditing)
        }
    }
    
    var delegate: CellsEditableWithSectionDelegate?
    
    var selected = false {
        didSet{
            
        }
    }
    var indexSet: Int!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        
        
        
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewGetSelected))
//        addGestureRecognizer(gesture)
//
//        selectionImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 5)
        
    }
    
    private func changeUI(forEditingMode editingMode: Bool) {
        if editingMode {
            selectionImageView.isHidden = false
            headerLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        }else{
            selectionImageView.isHidden = true
            headerLabel.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        UIView.animate(withDuration: 0.2) {
            self.layoutSubviews()
        }
    }
    
    @objc private func viewGetSelected(){
        if selected {
            delegate?.diSelectCellsOfSection(with: indexSet)
            selectionImageView.image = #imageLiteral(resourceName: "selected")
        }else{
            delegate?.selectCellsOfSection(with: indexSet)
            selectionImageView.image = #imageLiteral(resourceName: "Mask Copy")
        }
    }
    
}
