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
        label.font = AppState.main.font.h2
        label.textAlignment = .center
        label.textColor = .appMainLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        stackView.addArrangedSubview(dismissButton)
        stackView.addArrangedSubview(titleLabel)
        
        
        dismissButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let spacing = UIView()
        spacing.backgroundColor = .yellow
        stackView.addArrangedSubview(spacing)
        spacing.widthAnchor.constraint(lessThanOrEqualToConstant: 65).isActive = true
    }
    
    
    override func layoutSubviews() {
        redesignForNew(orientation: UIDevice.current.orientation)
    }
    
    func redesignForNew(orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            redesignForLandscape()
        }else{
            redesignForPortrait()
        }
        layoutIfNeeded()
    }
    
    private func redesignForLandscape() {
        backgroundColor = .clear
        
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
        
        dismissButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3).translatedBy(x: 8, y: 0)
        dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.8, radius: 2)
        dismissButton.tintColor = .white
        
        titleLabel.textColor = .white
        titleLabel.makeDropShadow(shadowOffset: .zero, opacity: 0.8, radius: 2)
    }
    
    private func redesignForPortrait() {
        gradient.removeFromSuperlayer()
        backgroundColor = .appSystemBackground
        
        dismissButton.transform = CGAffineTransform(scaleX: 1, y: 1).translatedBy(x: 0, y: 0)
        dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.0, radius: 1)
        dismissButton.tintColor = .label
        
        titleLabel.textColor = .appMainLabelColor
        titleLabel.makeDropShadow(shadowOffset: .zero, opacity: 0.0, radius: 1)
    }
    
     @objc private func closeTheVC() {
        delegate?.dismissViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
