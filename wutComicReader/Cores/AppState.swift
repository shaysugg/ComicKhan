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
    let font: AppFont
    private let storage = UserDefaults()
    
    @Published private(set) var readerTheme: ReaderTheme!
    @Published private(set) var showComicNames: Bool!
    @Published private(set) var readerPageMode: ReaderPageMode!
    
    init() {
        font = SystemFont()
        readerTheme = getTheme()
        showComicNames = getShouldShowComics()
        readerPageMode = getbookReaderPageMode()
        
    }
    
    func setTheme(to theme: ReaderTheme) {
        storage.setValue(theme.rawValue, forKey: Keys.apptheme)
        self.readerTheme = theme
    }
    
    private func getTheme() -> ReaderTheme {
        if let id = storage.string(forKey: Keys.apptheme),
           let theme = ReaderTheme.init(rawValue: id) {
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
        showComicNames = show
        
    }
    
    func setbookReaderPageMode(_ mode: ReaderPageMode) {
        storage.set(mode.rawValue, forKey: Keys.bookReaderPageMode)
        readerPageMode = mode
    }
    
    private func getShouldShowComics() -> Bool {
        storage.bool(forKey: Keys.showComicNames)
    }
    
    private func getbookReaderPageMode() -> ReaderPageMode {
        ReaderPageMode(rawValue: storage.integer(forKey: Keys.bookReaderPageMode)) ?? .single
    }
    
    func didAppLaunchedForFirstTime() -> Bool {
        let didLaunchedBefore = storage.bool(forKey: Keys.appDidLunchedBefore)
        return !didLaunchedBefore
    }
    
    func setAppDidLaunchedForFirstTime() {
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

extension AppState {
    private enum Keys {
        static let apptheme = "readerTheme"
        static let showComicNames = "showComicNames"
        static let appDidLunchedBefore = "appDidLunchedBefore"
        static let readerDidPresentedBefore = "readerDidPresentedBefore"
        static let bookReaderPageMode = "bookReaderPageMode"
    }
}

enum ReaderPageMode: Int, CaseIterable {
    case single = 1
    case double = 2
    
    var name: String {
        switch self {
        case .single:
            return "Single"
        case .double:
            return "Double"
        }
    }
}
