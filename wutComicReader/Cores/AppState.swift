//
//  AppState.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/7/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import Foundation
import UIKit

final class AppState {
    static let main = AppState()
    var storage = UserDefaults()
    
    @Published private(set) var readerTheme: AppTheme!
    @Published private(set) var shouldShowComicNames = false
    
    
    private enum Keys {
        static let apptheme = "readerTheme"
        static let showComicNames = "showComicNames"
        static let appDidLunchedBefore = "appDidLunchedBefore"
        static let readerDidPresentedBefore = "readerDidPresentedBefore"
    }
    
    init() {
        readerTheme = getTheme()
        shouldShowComicNames = getShouldShowComics()
    }
    
    func setTheme(to theme: AppTheme) {
        storage.setValue(theme.id, forKey: Keys.apptheme)
        self.readerTheme = theme
    }
    
    private func getTheme() -> AppTheme {
        if let id = storage.string(forKey: Keys.apptheme),
           let theme = AppTheme.theme(byID: id) {
            return theme
        }else {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark: return .dark
            default: return .light
            }
        }
    }
    
    func setShouldShowComicNames(to show: Bool) {
        storage.setValue(show, forKey: Keys.showComicNames)
        self.shouldShowComicNames = show
    }
    
    private func getShouldShowComics() -> Bool {
        storage.bool(forKey: Keys.showComicNames)
    }
    
    func appLaunchedForFirstTime() -> Bool {
        let didLaunchedBefore = storage.bool(forKey: Keys.appDidLunchedBefore)
        return !didLaunchedBefore
    }
    
    func setAppDidLaunchedFlag() {
        storage.set(true, forKey: Keys.appDidLunchedBefore)
    }
    
    //FIXME: WHAT THE ACTUAL FUCK
    func readerPresentForFirstTime() -> Bool {
        let didPresentBefore = storage.bool(forKey: Keys.readerDidPresentedBefore)
        if !didPresentBefore {
            storage.set(true, forKey: Keys.readerDidPresentedBefore)
            return true
        }else{
            return false
        }
    }
    
    
}
