//
//  RoundedProgressView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/19/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

class RoundedProgressView: UIView {
    //MARK:- Variables
    
    var trackViewImage: UIImage?{
        didSet{
            trackView.image = trackViewImage
        }
    }
    var progressViewImage: UIImage?{
        didSet{
            progressView.image = progressViewImage
        }
    }
    
    var trackViewTint: UIColor?{
        didSet{
            trackView.backgroundColor = trackViewTint
        }
    }
    
    var progressViewTint: UIColor?{
        didSet{
            progressView.backgroundColor = progressViewTint
        }
    }
    
    var loadAnimationSpeed = 0.2
    
    //MARK:- UI variables
    
    private lazy var trackView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = defaultGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = defaultBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var progressViewWidth: NSLayoutConstraint!
    
    
    //MARK:- Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDesign()
    }
    
    private func setupDesign(){
        addSubview(trackView)
        trackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        trackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        trackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        trackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        trackView.addSubview(progressView)
        progressView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressViewWidth = progressView.widthAnchor.constraint(equalToConstant: 0)
        progressViewWidth.isActive = true
        
        
        progressView.clipsToBounds = true
        trackView.clipsToBounds = true
        clipsToBounds = true
        
    }
    
    override func layoutSubviews() {
        progressView.layer.cornerRadius = bounds.height * 0.5
        trackView.layer.cornerRadius = bounds.height * 0.5
    }
    
    func setProgress(to value: CGFloat, animated: Bool) {
        
        guard value <= 1 && value >= 0 else { return }
        self.progressViewWidth.constant = self.bounds.size.width * CGFloat(value)
        UIView.animate(withDuration: animated ? loadAnimationSpeed : 0.0) { [unowned self] in
            self.layoutIfNeeded()
        }
            
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK:- Default Colors

    private var defaultBlueColor : UIColor = {
        if #available(iOS 13.0, *) {
            return .systemBlue
        }else{
            return .blue
        }
    }()


    private var defaultGrayColor : UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGray4
        }else{
            return .lightGray
        }
    }()
    
    
}

