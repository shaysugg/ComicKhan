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
    
    enum State {
        case copying
        case extracting
    }
    
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
    var nameLabalCopyingLeftConstraint: NSLayoutConstraint!
    var nameLabalExtractingLeftConstraint: NSLayoutConstraint!
    
    private var progressView: RoundedProgressView = {
        let progressView = RoundedProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressViewTint = .appProgressColor
        progressView.trackViewTint = .appTrackProgressColor
        return progressView
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
       let view = UIActivityIndicatorView()
        view.color = .white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        numberLabel.topAnchor.constraint(equalTo: topAnchor , constant: 15).isActive = true
        numberLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(spinner)
        spinner.rightAnchor.constraint(equalTo: progressView.rightAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: topAnchor , constant: 15).isActive = true
        
        addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: topAnchor , constant: 15).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: spinner.leftAnchor, constant: -5).isActive = true
        nameLabalExtractingLeftConstraint = nameLabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 5)
        nameLabalCopyingLeftConstraint = nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        
        nameLabalCopyingLeftConstraint.isActive = true
        
        
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
    
    func makeProgressBarFor(state: State, animated: Bool) {
        
        if state == .copying {
            nameLabalExtractingLeftConstraint.isActive = false
            nameLabalCopyingLeftConstraint.isActive = true
            
        }else {
            nameLabalCopyingLeftConstraint.isActive = false
            nameLabalExtractingLeftConstraint.isActive = true
        }
        self.progressView.alpha = state == .copying ? 0 : 1
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
        }
    }
    
}
