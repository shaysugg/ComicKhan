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
        progressContainer.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            self.progressContainer.transform = CGAffineTransform(translationX: 0, y: self.progressContainer.bounds.height * 1.5)
        }, completion: nil)
        
        
    }
    
    func setUpProgressBarDesign(){
        view.addSubview(progressContainer)
        progressContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        progressContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: -100).isActive = true
        progressContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        progressContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    func removeProgressView() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.progressContainer.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            self.progressContainer.isHidden = true
            self.navigationController?.navigationBar.subviews.forEach({ view in
                view.alpha = 1
            })
            
        })
    }
    
    
    
}

extension LibraryVC: ExtractingProgressDelegate {
    
    func newFileAboutToExtract(withName name: String, andNumber number: Int, inTotalFilesCount: Int?) {
        DispatchQueue.main.async { [unowned self] in
            
            self.showProgressView()
            self.progressContainer.setTitleLabel(to: "Extracting: \(name)")
            self.progressContainer.setProgress(to: 0)
            if let count = inTotalFilesCount {
                self.progressContainer.setNumberLabel(to: String(number) + "/" + String(count))
            }
            
        }
        
        
    }
    
    func percentChanged(to value: Double) {
        DispatchQueue.main.async { [unowned self] in
           self.progressContainer.setProgress(to: CGFloat(value))
        }
    }
    
    func extractingProcessFinished() {
        
        DispatchQueue.main.async {[unowned self] in
            self.removeProgressView()
        }
        
    }
    
}
