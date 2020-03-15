//
//  EmptyGroupView.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/15/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

protocol EmptyViewDelegate {
    func howAddComicsButtonTapped()
}

class EmptyGroupView: UIView {
    
    var delegate: EmptyViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyLibrary")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Looks like you don’t have any comics here at this moment ..."
        label.font = UIFont(name: HelvetincaNeueFont.light.name, size: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var howToButton: UIButton = {
        let button = UIButton()
        button.setTitle("How can I add comics here?", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appBlueColor
        button.titleLabel?.font = UIFont(name: HelvetincaNeueFont.bold.name, size: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(howToAddComicsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDesign()
    }
    
    func setUpDesign() {
        
        addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        addSubview(label)
        label.leftAnchor.constraint(equalTo: leftAnchor , constant: 15).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor , constant: -15).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        
        addSubview(howToButton)
        howToButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        howToButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        howToButton.widthAnchor.constraint(equalToConstant: 230).isActive = true
        howToButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    @objc func howToAddComicsButtonTapped() {
        delegate?.howAddComicsButtonTapped()
    }
    
    override func layoutSubviews() {
        howToButton.layer.cornerRadius = 20
        imageView.layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}
