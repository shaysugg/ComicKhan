//
//  newGroupVC.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/8/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import CoreData


class NewGroupVC: UIViewController {
    
    var dataService: DataService!
    var comicsAboutToGroup: [Comic] = []
    
    var groups: [ComicGroup]! { didSet {
        groupNames = groups.map({
            $0.name ?? ""
        })
    } }
    var groupNames: [String]!
    
    var newComicGroupAboutToAdd: ((_ name: String, _ comics: [Comic]) -> Void)?
    var comicsGroupAboutToMove: ((_ group: ComicGroup, _ comics: [Comic]) -> Void)?
    
    @IBOutlet weak var alreadyExistLabel: UILabel!
    @IBOutlet weak var newGroupTextField: UITextField!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet var addButton: UIButton!
    

    @IBAction func addGroupButtonTapped(_ sender: Any) {
        addButtonTapped()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try dataService.deleteEmptyGroups()
            groups = try dataService.fetchComicGroups()
        }catch{
            groups = []
        }
        
        setUpDesign()
        
        groupTableView.delegate = self
        groupTableView.dataSource = self
        newGroupTextField.delegate = self
        
        newGroupTextField.becomeFirstResponder()
        
        addButton.isEnabled = false
        addButton.alpha = 0.5
    }
    
    private func setUpDesign(){
        newGroupTextField.clipsToBounds = true
        newGroupTextField.layer.cornerRadius =  newGroupTextField.bounds.height *  0.25
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 10
        
        let rect = CGRect(x: 0, y: 0, width: newGroupTextField.bounds.height *  0.5 , height: 50)
        newGroupTextField.leftView = UIView(frame: rect)
        newGroupTextField.leftViewMode = .always
        
        groupTableView.tableFooterView = UIView()
        
        
        
    }
    
    
    private func addButtonTapped(){
            if let text = newGroupTextField.text,
               !text.isEmpty,
               !groupNames.contains(text) {
                newComicGroupAboutToAdd?(text, comicsAboutToGroup)
                dismiss(animated: true, completion: nil)
            }else {
                alreadyExistLabel.isHidden = false
            }
    }
    
}

extension NewGroupVC: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        if groups[indexPath.row].isForNewComics {
            cell.textLabel?.text = "Untitled"
        }else {
            cell.textLabel?.text = groups[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            comicsGroupAboutToMove?(groups[indexPath.row], comicsAboutToGroup)
            dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
}


extension NewGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addButtonTapped()
        return true
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            addButton.isEnabled = true
            addButton.alpha = 1
        }else {
            addButton.isEnabled = false
            addButton.alpha = 0.5
        }
    }
}
