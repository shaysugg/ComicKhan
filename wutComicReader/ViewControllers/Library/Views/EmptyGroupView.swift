//
//  EmptyGroupView.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/15/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import SwiftUI

protocol EmptyViewDelegate: AnyObject {
    func importComicsButtonTapped()
    func copyrightButtonDidTapped()
}

class EmptyGroupView: UIView {
    
    weak var delegate: EmptyViewDelegate?
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //this stackView used in landscaped mode
    private lazy var rightVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var pictureVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var pictureDiscriptionHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var buttonVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.text = "By Samuel Jessurun de Mesquita"
        label.font = AppState.main.font.caption2
        label.textColor = .appSeconedlabelColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyrightButton: UIButton = {
        let button = UIButton()
        let text = "copyright"
        button.setTitle(text, for: .normal)
        let textRange = NSRange(location: 0, length: text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        
        button.titleLabel?.attributedText = attributedText
        
        button.titleLabel?.font = AppState.main.font.caption2
        button.setTitleColor(.appSecondaryLabel, for: .normal)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(copyrightButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You don’t have any comics here!"
        label.font = AppState.main.font.h2
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var importLabel: UILabel = {
        let label = UILabel()
        label.text = "You can also import them by iTunes (Windows) / Files (Mac)"
        label.font = AppState.main.font.caption
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .appSecondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var importButton: UIButton = {
        let button = UIButton()
        button.setTitle("Import Comics", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appBlueColor
        button.titleLabel?.font = AppState.main.font.body
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(howToAddComicsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStackViews()
    }
    
    
    private func setUpStackViews() {
        
        pictureVStackView.addArrangedSubview(imageView)
        pictureVStackView.addArrangedSubview(pictureDiscriptionHStackView)
        pictureDiscriptionHStackView.addArrangedSubview(artistNameLabel)
        pictureDiscriptionHStackView.addArrangedSubview(copyrightButton)

        buttonVStackView.addArrangedSubview(importButton)
        buttonVStackView.addArrangedSubview(importLabel)

        importButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: pictureVStackView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        
    }
    
    
    func designforportrait() {
        hStackView.removeFromSuperview()
        hStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        addSubview(vStackView)
        vStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        vStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        vStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        vStackView.addArrangedSubview(pictureVStackView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(buttonVStackView)
    }
    
    
    func designForLandscape() {
        vStackView.removeFromSuperview()
        vStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        addSubview(hStackView)
        hStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        
        hStackView.addArrangedSubview(pictureVStackView)
        hStackView.addArrangedSubview(rightVStackView)
        
        rightVStackView.addArrangedSubview(titleLabel)
        rightVStackView.addArrangedSubview(buttonVStackView)
        
    }
    
    @objc func howToAddComicsButtonTapped() {
        delegate?.importComicsButtonTapped()
    }
    
    @objc func copyrightButtonTapped() {
        delegate?.copyrightButtonDidTapped()
    }
    
    override func layoutSubviews() {
        importButton.layer.cornerRadius = importButton.bounds.height * 0.25
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

struct EmptyGroupView_Preview: PreviewProvider {
    static var previews: some View {
        UIKitPreview(view: EmptyGroupView())
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
