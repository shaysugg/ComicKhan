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

class InfoVC: UITableViewController {
    
    @IBOutlet weak var mailImageView: UIImageView!
    @IBOutlet weak var githubImageView: UIImageView!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupDesign()
        setVersionLabel()
    }
    
    func setupDesign(){
        
        let githubImage = UIImage(named: "github")?.withRenderingMode(.alwaysTemplate)
        githubImageView.tintColor = .appBlueColor
        githubImageView.image = githubImage
        
        let emailImage = UIImage(named: "mail")?.withRenderingMode(.alwaysTemplate)
        mailImageView.tintColor = .appBlueColor
        mailImageView.image = emailImage
        
        let rateImage = UIImage(named: "smile")?.withRenderingMode(.alwaysTemplate)
        rateImageView.tintColor = .appBlueColor
        rateImageView.image = rateImage
        
        iconImage.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 3)
        
        navigationController?.navigationBar.tintColor = .appBlueColor
        
        
    }
    
    func setVersionLabel() {
        if let versionText = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = "version: " + versionText
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        
        if indexPath.row == 0 {
            emailCellTapped()
        }else if indexPath.row == 1 {
            githubCellTapped()
        }else if indexPath.row == 2 {
            rateCellTapped()
        }else{}
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
}

extension InfoVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

