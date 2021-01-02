//
//  ReaderGuideView.swift
//  wutComicReader
//
//  Created by Sha Yan on 7/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit


protocol GuideViewDelegate: class {
    func viewElementsDidDissappeared()
}

class ReaderGuideView: UIView  {
    
    weak var delegate: GuideViewDelegate?
    
     private lazy var blurView: UIVisualEffectView = {
         let view = UIVisualEffectView()
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
     }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var HStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var V1StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var V2StackView: UIStackView = {
           let stackView = UIStackView()
           stackView.axis = .vertical
           stackView.alignment = .center
           stackView.distribution = .fill
           stackView.spacing = 10
           stackView.translatesAutoresizingMaskIntoConstraints = false
           return stackView
       }()
    
    private lazy var H1SImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var H2SImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appBlueColor
        button.setTitle("Got it!", for: .normal)
        button.titleLabel?.font = UIFont(name: HelvetincaNeueFont.bold.name, size: 18)
        button.addTarget(self, action: #selector(disappearViewElements), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tapImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "tap-gesture")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .appSecondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pinchImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "pinch-gesture")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .appSecondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var doubleTapImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "doubletap-gesture")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .appSecondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appBlueColor
        label.textAlignment = .center
        label.font = UIFont(name: HelvetincaNeueFont.medium.name, size: 17)
        label.text = "Tap on the screen for appearing/disappearing menus."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doubleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appBlueColor
        label.textAlignment = .center
        label.font = UIFont(name: HelvetincaNeueFont.medium.name, size: 17)
        label.text = "Double tap or pinch for zooming."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var CHCVConstraints = [NSLayoutConstraint]()
    var RHCVConstraints = [NSLayoutConstraint]()
    var RHRVConstraints = [NSLayoutConstraint]()
    var CHRVConstraints = [NSLayoutConstraint]()
    var sharedConstraints = [NSLayoutConstraint]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDesign()
    }
    
    private func setupDesign() {
        translatesAutoresizingMaskIntoConstraints = false
        
        blurView.effect = UIBlurEffect(style: .prominent)
        
        addSubview(blurView)
        blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        
        stackView.addArrangedSubview(HStackView)
        stackView.addArrangedSubview(button)
        HStackView.addArrangedSubview(V1StackView)
        HStackView.addArrangedSubview(V2StackView)
        
        V1StackView.addArrangedSubview(H1SImageStackView)
        V1StackView.addArrangedSubview(tapLabel)
        H1SImageStackView.addArrangedSubview(tapImageView)
        
        V2StackView.addArrangedSubview(H2SImageStackView)
        V2StackView.addArrangedSubview(doubleLabel)
        H2SImageStackView.addArrangedSubview(doubleTapImageView)
        H2SImageStackView.addArrangedSubview(pinchImageView)
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 10
        
        tapImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        tapImageView.heightAnchor.constraint(equalTo: tapImageView.widthAnchor).isActive = true
        
        doubleTapImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        doubleTapImageView.heightAnchor.constraint(equalTo: doubleTapImageView.widthAnchor).isActive = true
        
        pinchImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pinchImageView.heightAnchor.constraint(equalTo: pinchImageView.widthAnchor).isActive = true
        
        
        CHRVConstraints.append(stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9))
        RHRVConstraints.append(stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5))
        RHCVConstraints.append(stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5))
        CHCVConstraints.append(stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5))
        
        
        layoutTrait()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pinchImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.4, radius: 3)
        tapImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.4, radius: 3)
        doubleTapImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.4, radius: 3)
    }
    
    func layoutTrait() {
        //maybe make this as a protocol?
        NSLayoutConstraint.deactivate(RHRVConstraints)
        NSLayoutConstraint.deactivate(CHRVConstraints)
        NSLayoutConstraint.deactivate(RHCVConstraints)
        NSLayoutConstraint.deactivate(CHCVConstraints)
        
        let trait = UIScreen.main.traitCollection
        
        if trait.horizontalSizeClass == .compact && trait.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(CHRVConstraints)
        }else {
            NSLayoutConstraint.activate(RHRVConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layoutTrait()
    }
    
    @objc private func disappearViewElements(){
        
        stackView.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
            self.layoutIfNeeded()
        }) { (_) in
            self.delegate?.viewElementsDidDissappeared()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}
