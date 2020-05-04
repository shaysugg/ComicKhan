//
//  AddNewComicVC.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/3/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

class AddNewComicVC: UIViewController {
    
    var appFileManager: AppFileManager!
    var dataService: DataService!
    
    var groups = [ComicGroup]()

    @IBOutlet weak var addThemToLibraryButton: UIButton!
    @IBOutlet weak var addThemtoNewGroupButton: UIButton!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    
    @IBAction func justAddThemToLibraryTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addThemToNewGroupTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataService = DataService()
        
        appFileManager = AppFileManager(dataService: dataService)
        
        do {
            try dataService.deleteEmptyGroups()
            groups = try dataService.fetchComicGroups()
        }catch{
            groups = []
        }
        
        groupNameTextField.delegate = self
        groupTableView.delegate = self
        groupTableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        setupDesign()
    }
    
    private func setupDesign() {
        
        addThemtoNewGroupButton.clipsToBounds = true
        addThemtoNewGroupButton.layer.cornerRadius = 10
        
        addThemToLibraryButton.clipsToBounds = true
        addThemToLibraryButton.layer.cornerRadius = 10
        
        groupNameTextField.clipsToBounds = true
        groupNameTextField.layer.cornerRadius =  groupNameTextField.bounds.height *  0.25
        let rect = CGRect(x: 0, y: 0, width: groupNameTextField.bounds.height *  0.5 , height: 50)
        groupNameTextField.leftView = UIView(frame: rect)
        groupNameTextField.leftViewMode = .always
        
        groupTableView.tableFooterView = UIView()
    }

}

extension AddNewComicVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        let label = cell.viewWithTag(101) as! UILabel
        let imageView = cell.viewWithTag(102) as! UIImageView
        
        label.text = groups[indexPath.row].name
        let image = UIImage(named: "addToGroup")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}


extension AddNewComicVC: UITextFieldDelegate{
    
}
