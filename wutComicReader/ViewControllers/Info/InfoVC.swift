//
//  InfoVC.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/7/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import StoreKit
import Combine

class InfoVC: UITableViewController {
    
    @IBOutlet weak var mailImageView: UIImageView!
    @IBOutlet weak var githubImageView: UIImageView!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var comicNameSwitch: UISwitch!
    private var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupDesign()
        setVersionLabel()
        setupComicNameSwitch()
    }
    
    func setupDesign(){
        
        let githubImage = UIImage(named: "github")?.withRenderingMode(.alwaysTemplate)
        githubImageView.tintColor = .appMainColor
        githubImageView.image = githubImage
        
        let emailImage = UIImage(named: "mail")?.withRenderingMode(.alwaysTemplate)
        mailImageView.tintColor = .appMainColor
        mailImageView.image = emailImage
        
        let rateImage = UIImage(named: "smile")?.withRenderingMode(.alwaysTemplate)
        rateImageView.tintColor = .appMainColor
        rateImageView.image = rateImage
        
        iconImage.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 3)
        
        navigationController?.navigationBar.tintColor = .appMainColor
        
        
    }
    
    func setVersionLabel() {	
        if let versionText = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = "version: " + versionText
        }
    }
    
    func setupComicNameSwitch() {
        AppState.main.$showComicNames.replaceNil(with: false)
            .weakAssign(to: \.isOn, on: comicNameSwitch)
            .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0 { emailCellTapped() }
            if indexPath.row == 1 { githubCellTapped() }
            if indexPath.row == 2 { rateCellTapped() }
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        indexPath.section != 0 
    }
    
    func emailCellTapped() {
        if MFMailComposeViewController.canSendMail() {
                 let email = MFMailComposeViewController()
                 email.mailComposeDelegate = self
                 email.setToRecipients(["shaysugg@protonmail.com"])
                 
                 present(email, animated: true)
             }
        
    }
    
    func githubCellTapped() {
        guard let url = URL(string: "https://github.com/shaysugg/ComicKhan") else { return }
        UIApplication.shared.open(url)
    }
    
    func rateCellTapped() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1516810943") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func comicNameSwitchDidTapped(_ sender: Any) {
        AppState.main.setShouldShowComicNames(to: comicNameSwitch.isOn)
    }
}

extension InfoVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

