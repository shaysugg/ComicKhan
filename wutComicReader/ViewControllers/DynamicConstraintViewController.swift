//
//  RotatableView.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/8/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

//TODO: Dont set constraint on landscape or not landscape
class DynamicConstraintViewController: UIViewController {
    
    private var sharedConstaints: [NSLayoutConstraint] = []
    private var CVCHConstaints: [NSLayoutConstraint] = []
    private var RVRHConstaints: [NSLayoutConstraint] = []
    private var CVRHConstaints: [NSLayoutConstraint] = []
    private var RVCHConstaints: [NSLayoutConstraint] = []
    private var landscapeConstaints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    
    final func setupDynamicLayout() {
        let traitCollection = UIScreen.main.traitCollection
        let horizontal = traitCollection.horizontalSizeClass
        let vertical = traitCollection.verticalSizeClass
        
        NSLayoutConstraint.deactivate(CVCHConstaints)
        NSLayoutConstraint.deactivate(CVRHConstaints)
        NSLayoutConstraint.deactivate(RVCHConstaints)
        NSLayoutConstraint.deactivate(RVRHConstaints)
        NSLayoutConstraint.deactivate(landscapeConstaints)
        NSLayoutConstraint.deactivate(portraitConstraints)
        NSLayoutConstraint.deactivate(sharedConstaints)
        
        NSLayoutConstraint.activate(sharedConstaints)
        
        if horizontal == .compact && vertical == .compact {
            NSLayoutConstraint.activate(CVCHConstaints)
        }else if horizontal == .compact && vertical == .regular {
            NSLayoutConstraint.activate(RVCHConstaints)
        }else if horizontal == .regular && vertical == .compact {
            NSLayoutConstraint.activate(CVRHConstaints)
        }else {
            NSLayoutConstraint.activate(RVRHConstaints)
        }
        
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.activate(landscapeConstaints)
        }else {
            NSLayoutConstraint.activate(portraitConstraints)
        }
        
    }
    
    final func setConstraints(shared: [NSLayoutConstraint]) {
        self.sharedConstaints = shared
    }
    
    final func setConstraints(CVCH: [NSLayoutConstraint] = [], RVCH: [NSLayoutConstraint] = [], CVRH: [NSLayoutConstraint] = [], RVRH: [NSLayoutConstraint] = []) {
        self.CVCHConstaints = CVCH
        self.CVRHConstaints = CVRH
        self.RVCHConstaints = RVCH
        self.RVRHConstaints = RVRH
    }
    
    final func setConstraints(portrait: [NSLayoutConstraint] = [], landscape: [NSLayoutConstraint]) {
        self.portraitConstraints = portrait
        self.landscapeConstaints = landscape
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupDynamicLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //because in ipad traitCollectionDidChange would not work
        setupDynamicLayout()
    }
}

