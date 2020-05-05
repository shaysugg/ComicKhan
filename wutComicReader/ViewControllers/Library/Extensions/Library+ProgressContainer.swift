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
        makeBarButtons(hidden: true)
        
        progressContainer.isHidden = false
        progressContainerHideBottomConstrait.isActive = false
        progressContainerAppearedBottomConstrait.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
        
        
    }
    
    func setUpProgressBarDesign(){
        view.addSubview(progressContainer)
        progressContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        progressContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        progressContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        progressContainerHideBottomConstrait = progressContainer.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
            progressContainerAppearedBottomConstrait = progressContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        progressContainerHideBottomConstrait.isActive = true
    }
    
    func removeProgressView() {
        
        progressContainerAppearedBottomConstrait.isActive = false
        progressContainerHideBottomConstrait.isActive = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutSubviews()
        }, completion: { _ in
            self.progressContainer.isHidden = true
            self.progressContainer.setProgress(to: 0)
            self.makeBarButtons(hidden: false)
            })
        editingMode = false
    }
    
    
     func makeBarButtons(hidden: Bool) {
        infoButton.isEnabled = !hidden
//        refreshButton.isEnabled = !hidden
        addComicsButton.isEnabled = !hidden
        editBarButton.isEnabled = !hidden
    }
    
    
}

extension LibraryVC: ExtractingProgressDelegate {
    
    func newFileAboutToExtract(withName name: String, andNumber number: Int, inTotalFilesCount: Int?) {
        DispatchQueue.main.async { [weak self] in
            
            self?.showProgressView()
            self?.progressContainer.setTitleLabel(to: "Extracting: \(name)")
            self?.comicNameThatExtracting = name
            self?.progressContainer.setProgress(to: 0)
            if let count = self?.newFilesCount {
                self?.progressContainer.setNumberLabel(to: String(number) + "/" + String(count))
            }
            
        }
        
        
    }
    
    func percentChanged(to value: Double) {
        DispatchQueue.main.async { [weak self] in
           self?.progressContainer.setProgress(to: CGFloat(value))
        }
    }
    
    func extractingProcessFinished() {
        
        DispatchQueue.main.async {[weak self] in
            self?.comicNameThatExtracting = nil
            self?.removeProgressView()
        }
        
    }
    
}
