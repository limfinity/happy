//
//  HPPYTaskListViewController.swift
//  Happy
//
//  Created by Peter Pult on 03/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

import UIKit

class HPPYTaskListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    lazy var tasks = HPPYTaskController.getTasks().flatMap { $0 as? HPPYTask }
    
}

extension HPPYTaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = task.title
        return cell
    }
    
}
