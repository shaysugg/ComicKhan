//
//  progressContainerView.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/2/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

class ProgressContainerView: UIView {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: HelvetincaNeueFont.bold.name, size: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: HelvetincaNeueFont.bold.name, size: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var progressView: RoundedProgressView = {
        let progressView = RoundedProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressViewTint = .appProgressColor
        progressView.trackViewTint = .appTrackProgressColor
        return progressView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpDesign()
    }
    
    
    
    private func setUpDesign() {
        
        backgroundColor = .appBlueColor
        clipsToBounds = true
        self.makeDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 20)
        
        addSubview(progressView)
        progressView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        progressView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        progressView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        addSubview(numberLabel)
        numberLabel.leftAnchor.constraint(equalTo: progressView.leftAnchor).isActive = true
        numberLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor , constant: -10).isActive = true
        numberLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor , constant: -10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: progressView.rightAnchor).isActive = true
        
        
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height * 0.3
    }
    
    func setProgress(to value: CGFloat) {
        progressView.setProgress(to: value, animated: true)
    }
    
    func setTitleLabel(to string: String) {
        nameLabel.text = string
    }
    
    func setNumberLabel(to string: String) {
        numberLabel.text = string
    }
    
}
