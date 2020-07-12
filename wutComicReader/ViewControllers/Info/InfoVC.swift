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

class InfoVC: UITableViewController {
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    @IBAction func emailButtonTapped(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
                 let email = MFMailComposeViewController()
                 email.mailComposeDelegate = self
                 email.setToRecipients(["shayanb@protonmail.com"])
                 
                 present(email, animated: true)
             }
        
    }
    
    @IBAction func githubButtonTapped(_ sender: Any) {
        guard let url = URL(string: "https://github.com/shaysugg/ComicKhan") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func howToCellTapped(_ sender: Any) {
        let howToVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HowToVC") as! HowToVC
        present(howToVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .groupTableViewBackground
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupDesign()
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    func setupDesign(){
        let twitterImage = UIImage(named: "github")?.withRenderingMode(.alwaysTemplate)
        githubButton.setImage(twitterImage, for: .normal)
        
        let emailImage = UIImage(named: "mail")?.withRenderingMode(.alwaysTemplate)
        emailButton.setImage(emailImage, for: .normal)
        
        navigationController?.navigationBar.tintColor = .appBlueColor
        
        
    }
}

extension InfoVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

