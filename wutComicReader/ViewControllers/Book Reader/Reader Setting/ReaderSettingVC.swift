//
//  SettingBar.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/28/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

class ReaderSettingVC: UINavigationController {
    init(settingDelegate: ReaderSettingVCDelegate? = nil) {
        let vc = SettingVC()
        vc.delegate = settingDelegate
        super.init(rootViewController: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ReaderSettingVCDelegate: AnyObject {
    func doneButtonTapped()
}

fileprivate final class SettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ReaderSettingVCDelegate?
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pageModeSegmentControll: UISegmentedControl = {
        let view = UISegmentedControl(frame: .zero, actions: ReaderPageMode.allCases.map({ pageMode in
            return UIAction(title: pageMode.name, handler: { [weak self] _ in
                self?.pageModeChanged(to: pageMode)
            })
        }))
        view.selectedSegmentIndex = ReaderPageMode.allCases.firstIndex(of: AppState.main.readerPageMode)!
        return view
    }()
    
    private lazy var ReaderThemeSegmentControll: UISegmentedControl = {
        let view = UISegmentedControl(frame: .zero, actions: ReaderTheme.allCases.map({ theme in
            return UIAction(title: theme.rawValue.capitalized, handler: {[weak self] _ in
                self?.readerThemeChanged(to: theme)
            })
        }))
        view.selectedSegmentIndex = ReaderTheme.allCases.firstIndex(of: AppState.main.readerTheme)!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var pageModeCell = UITableViewCell()
    private var readerThemeCell = UITableViewCell()
    
    private let cellInset: CGFloat = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(doneButtonTapped)),
            animated: false)
        navigationController?.navigationBar.tintColor = .appMainColor
        
        title = "Reader Setting"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        view.layer.cornerRadius = 20
        
        configurePageModeCell()
        configureReaderThemeCell()
        
        
        
    }
    
    @objc private func doneButtonTapped() {
        delegate?.doneButtonTapped()
    }
    
    
    private func configurePageModeCell() {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Page mode:"
        label.font = AppState.main.font.body
        label.translatesAutoresizingMaskIntoConstraints = false
        
        pageModeCell.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: pageModeCell.contentView.leftAnchor, constant: cellInset),
            stackView.rightAnchor.constraint(equalTo: pageModeCell.contentView.rightAnchor, constant: -cellInset),
            stackView.topAnchor.constraint(equalTo: pageModeCell.contentView.topAnchor, constant: cellInset),
            stackView.bottomAnchor.constraint(equalTo: pageModeCell.contentView.bottomAnchor, constant: -cellInset),
        ])
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(pageModeSegmentControll)
        
    }
    
    private func configureReaderThemeCell() {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Reader theme:"
        label.font = AppState.main.font.body
        label.translatesAutoresizingMaskIntoConstraints = false
        
        readerThemeCell.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: readerThemeCell.contentView.leftAnchor, constant: cellInset),
            stackView.rightAnchor.constraint(equalTo: readerThemeCell.contentView.rightAnchor, constant: -cellInset),
            stackView.topAnchor.constraint(equalTo: readerThemeCell.contentView.topAnchor, constant: cellInset),
            stackView.bottomAnchor.constraint(equalTo: readerThemeCell.contentView.bottomAnchor, constant: -cellInset),
        ])
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(ReaderThemeSegmentControll)
        
    }
    
    private func readerThemeChanged(to theme: ReaderTheme) {
        AppState.main.setTheme(to: theme)
    }
    
    private func pageModeChanged(to pageMode: ReaderPageMode) {
        AppState.main.setbookReaderPageMode(pageMode)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return pageModeCell
        }
        
        if indexPath.row == 1 {
            return readerThemeCell
            
        }
        
        fatalError()
        
        
    }
}
