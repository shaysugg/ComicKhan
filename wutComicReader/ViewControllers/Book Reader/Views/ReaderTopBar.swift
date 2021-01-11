//
//  ReaderTopBar.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/27/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

class TopBar: UIView {
    
    var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    weak var delegate: TopBarDelegate?
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: HelvetincaNeueFont.medium.name, size: 15)
        label.textAlignment = .center
        label.textColor = .appMainLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var titleLabelCenterYConstraints: NSLayoutConstraint!
    
    private lazy var dismissButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        let img = #imageLiteral(resourceName: "ic-actions-close").withRenderingMode(.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(closeTheVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.clear.cgColor]
        return gradient
    }()
    
    private var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDesign()
    }
    
    private func setUpDesign(){
        
        backgroundColor = .appSystemBackground
        
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 65).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        titleLabelCenterYConstraints = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        titleLabelCenterYConstraints.isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(dismissButton)
        dismissButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        dismissButton.clipsToBounds = true

    }
    
    
    override func layoutSubviews() {
        redesignForNew(orientation: UIDevice.current.orientation)
    }
    
    func redesignForNew(orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            backgroundColor = .clear
            
            gradient.frame = bounds
            layer.insertSublayer(gradient, at: 0)
            
            dismissButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3).translatedBy(x: 8, y: 0)
            dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.8, radius: 2)
            dismissButton.tintColor = .white
            
            titleLabel.textColor = .white
            titleLabel.makeDropShadow(shadowOffset: .zero, opacity: 0.8, radius: 2)
        }else{
            gradient.removeFromSuperlayer()
            backgroundColor = .appSystemBackground
            
            dismissButton.transform = CGAffineTransform(scaleX: 1, y: 1).translatedBy(x: 0, y: 0)
            dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.0, radius: 1)
            dismissButton.tintColor = .label
            
            titleLabel.textColor = .appMainLabelColor
            titleLabel.makeDropShadow(shadowOffset: .zero, opacity: 0.0, radius: 1)
            
        }
        layoutIfNeeded()
    }
    
     @objc private func closeTheVC() {
        delegate?.dismissViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
