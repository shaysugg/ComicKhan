//
//  AppDelegate.swift
//  wutComicReader
//
//  Created by Shayan on 5/31/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if AppState.main.didAppLaunchedForFirstTime() {
            do {
                try Cores.main.dataService.createGroupForNewComics()
                try Cores.main.appfileManager.makeAppDirectory()
                AppState.main.setAppDidLaunchedForFirstTime()
                
            }catch let error {
                fatalError("Initial setup was failed: " + error.localizedDescription)
            }
        }
        
        print("🏠 \(NSHomeDirectory())")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {        
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if let bookReaderVC = navigationController.visibleViewController as? BookReaderVC,
               let page = bookReaderVC.lastViewedPage,
               let comic = bookReaderVC.comic{
                try? Cores.main.dataService.saveLastPageOf(comic: comic, lastPage: page)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let _ = diractoryWatcher?.stopWatching()
        print("terminated")
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //        let bookReaderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bookReader")
        
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if navigationController.visibleViewController is BookReaderVC ||
            navigationController.visibleViewController is LibraryVC {
                return .allButUpsideDown
            }else{
                return .portrait
            }
        }else{
            return .portrait
        }
    }
    
    
}






