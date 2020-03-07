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
    
    var comicsAboutToGroup: [Comic] = []
    private var groups: [ComicGroup] = [] {
        didSet{
            addLabel.isHidden = groups.isEmpty
        }
    }
    
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
        
        fetchGroupComics()
        
        setUpDesign()
        
        groupTableView.delegate = self
        groupTableView.dataSource = self
        newGroupTextField.delegate = self
        
        newGroupTextField.becomeFirstResponder()
        
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
    
    override func viewDidLayoutSubviews() {
        
    }
    
    private func addButtonTapped(){
        if let text = newGroupTextField.text {
            addComicGroup(withName: text)
        }
        NotificationCenter.default.post(name: .newGroupAdded, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func addComicGroup(withName name:String) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let comicGroup = ComicGroup(context: managedContext)
        comicGroup.name = name
        comicGroup.id = UUID()
        comicGroup.comics = NSOrderedSet(array: comicsAboutToGroup)
        comicGroup.isForNewComics = false
        
        do {
            try managedContext.save()
        }catch let err{
            print(err.localizedDescription)
            #warning("error handeling")
        }
    }
    
    
    private func fetchGroupComics(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
        
        do{
            groups = try managedContext.fetch(fetchRequest)
        }catch let error{
            print("error happed while fetching from core Data: " + error.localizedDescription)
        }
    }
    
}

extension NewGroupVC: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        let label = cell.viewWithTag(101) as! UILabel
        label.text = groups[indexPath.row].name
        let image = UIImage(named: "addToGroup")?.withRenderingMode(.alwaysTemplate)
        let imageView = cell.viewWithTag(102) as! UIImageView
        imageView.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderedSet = NSOrderedSet(array: comicsAboutToGroup)
        groups[indexPath.row].addToComics(orderedSet)
        NotificationCenter.default.post(name: .newGroupAdded, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
}


extension NewGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let groupNames:[String] = groups.map({
            $0.name ?? ""
        })
        if groupNames.contains(textField.text ?? "") {
            alreadyExistLabel.isHidden = false
        }else{
            alreadyExistLabel.isHidden = true
            addButtonTapped()
        }
        
        return true
    }
}
