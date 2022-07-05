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
        label.font = AppState.main.font.body
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var numberLabel: UILabel = {
        let label = UILabel()
        label.font = AppState.main.font.body
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
        
        addSubview(vStackView)
        vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
        hStackView.addArrangedSubview(nameLabel)
        hStackView.addArrangedSubview(numberLabel)
        hStackView.addArrangedSubview(spinner)
        
        vStackView.addArrangedSubview(hStackView)
        vStackView.addArrangedSubview(progressView)
        
        progressView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.3
        self.makeBoundsDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 10)
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
            progressView.removeFromSuperview()
            
        }else {
            vStackView.addArrangedSubview(progressView)
        }
        
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.progressView.alpha = state == .copying ? 0 : 1
                self.layoutIfNeeded()
            }
        }
    }
    
}
