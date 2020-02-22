//
//  progressView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/16/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

extension LibraryVC {
    
    func showProgressView() {
        
        navigationController?.navigationBar.subviews.forEach({ view in
            view.alpha = 0
        })
        progressContainerView.isHidden = false
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options: .curveEaseOut, animations: {
            self.progressContainerView.transform = CGAffineTransform(translationX: 0, y: self.progressContainerHeight - 10)
        }, completion: nil)
        
    }
    
    func setUpProgressBarDesign(){
        
        progressNameLabel = UILabel()
        progressContainerView = UIView()
        progressView = RoundedProgressView()
        progressNumberLabel = UILabel()
        
        progressNumberLabel.font = UIFont(name: HelvetincaNeueFont.bold.name, size: 15)
        progressNameLabel.font = UIFont(name: HelvetincaNeueFont.medium.name, size: 14)
        progressNameLabel.textAlignment = .center
        progressNumberLabel.textColor = .appSecondaryLabel
        progressNameLabel.textColor = .appSecondaryLabel
        
        progressView.progressViewTint = .appBlueColor
        
        progressContainerView.backgroundColor = .appSystemSecondaryBackground
        progressContainerView.isHidden = true
        
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressNameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressContainerView)
        progressContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        progressContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: -progressContainerHeight).isActive = true
        progressContainerView.heightAnchor.constraint(equalToConstant: progressContainerHeight).isActive = true
        progressContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        progressContainerView.addSubview(progressView)
        progressView.leftAnchor.constraint(equalTo: progressContainerView.leftAnchor, constant: 15).isActive = true
        progressView.rightAnchor.constraint(equalTo: progressContainerView.rightAnchor, constant: -15).isActive = true
        progressView.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -15).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        progressContainerView.addSubview(progressNumberLabel)
        progressNumberLabel.leftAnchor.constraint(equalTo: progressView.leftAnchor).isActive = true
        progressNumberLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor , constant: -10).isActive = true
        progressNumberLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        progressContainerView.addSubview(progressNameLabel)
        progressNameLabel.leftAnchor.constraint(equalTo: progressNumberLabel.rightAnchor, constant: 5).isActive = true
        progressNameLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor , constant: -10).isActive = true
        progressNameLabel.rightAnchor.constraint(equalTo: progressView.rightAnchor).isActive = true
        
    }
    
    func removeProgressView() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.progressContainerView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            self.progressContainerView.isHidden = true
            self.navigationController?.navigationBar.subviews.forEach({ view in
                view.alpha = 1
            })
            
        })
    }
    
    
    
}

extension LibraryVC: ExtractingProgressDelegate {
    
    func newFileAboutToExtract(withName name: String, andNumber number: Int, inTotalFilesCount: Int) {
        DispatchQueue.main.async { [unowned self] in
            
            self.showProgressView()
            self.progressNameLabel.text = "Extracting: \(name)"
            self.progressNumberLabel.text = String(number) + "/" + String(inTotalFilesCount)
            self.progressView.setProgress(to: 0, animated: false)
        }
        
        
    }
    
    func percentChanged(to value: Double) {
        DispatchQueue.main.async {
            self.progressView.setProgress(to: CGFloat(value), animated: true)
        }
    }
    
    func extractingProcessFinished() {
        
        DispatchQueue.main.async {[unowned self] in
            self.removeProgressView()
        }
        
    }
    
}
