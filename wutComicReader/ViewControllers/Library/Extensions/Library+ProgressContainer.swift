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
    
     fileprivate func showProgressView() {
        makeBarButtons(hidden: true)
        
        progressContainer.isHidden = false
        progressContainerHideBottomConstrait.isActive = false
        progressContainerAppearedBottomConstrait.isActive = true
        
        progressContainer.spinner.startAnimating()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
        
        
    }
    
    func setUpProgressBarDesign(){
        view.addSubview(progressContainer)
        
        RHConstratis.append(
            progressContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6))
        CHConstratis.append(
            progressContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9))
        
        progressContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        progressContainerHideBottomConstrait = progressContainer.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        progressContainerAppearedBottomConstrait = progressContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        
        progressContainerHideBottomConstrait.isActive = true
    }
    
    
    fileprivate func redesignForExtractingState() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
            self.progressContainer.spinner.stopAnimating()
            
            })
        editingMode = false
    }
    
    
     fileprivate func makeBarButtons(hidden: Bool) {
        infoButton.isEnabled = !hidden
        addComicsButton.isEnabled = !hidden
        editBarButton.isEnabled = !hidden
    }
    
    
}

extension LibraryVC: ProgressDelegate {
    func newFileAboutToCopy(withName name: String) {
        showProgressView()
        progressContainer.makeProgressBarFor(state: .copying, animated: false)
        progressContainer.setTitleLabel(to: "Copying Files ...")
        progressContainer.setNumberLabel(to: "10/100")
        progressContainer.setProgress(to: 20)
    }
    
    
    func newFileAboutToExtract(withName name: String, andNumber number: Int, inTotalFilesCount: Int?) {
        DispatchQueue.main.async { [weak self] in
            
            ///this is quick fix should consider a betterway later
            if self?.progressContainerHideBottomConstrait.isActive ?? false {
                self?.showProgressView()
            }
            self?.redesignForExtractingState()
            self?.progressContainer.makeProgressBarFor(state: .extracting, animated: true)
            self?.progressContainer.setTitleLabel(to: "Extracting: \(name)")
            self?.comicNameThatExtracting = name
            self?.progressContainer.setProgress(to: 0)
            if let totalNumber = inTotalFilesCount {
                self?.progressContainer.setNumberLabel(to: String(number) + "/" + String(totalNumber))
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
