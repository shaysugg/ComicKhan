//
//  LoadingView.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/3/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    lazy var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.tintColor = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    lazy private var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = .appBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(backgroundView)
        backgroundView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        backgroundView.addSubview(loadingSpinner)
        loadingSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loadingSpinner.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingSpinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backgroundView.layer.cornerRadius = 25
        loadingSpinner.startAnimating()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
