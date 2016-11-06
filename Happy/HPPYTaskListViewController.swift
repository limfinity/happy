//
//  HPPYTaskListViewController.swift
//  Happy
//
//  Created by Peter Pult on 03/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

import UIKit

class HPPYTaskListViewController: UIViewController {
    
    var collectionViewSizeChanged: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    lazy var tasks = HPPYTaskController.getTasks().flatMap { $0 as? HPPYTask }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionViewSizeChanged = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if collectionViewSizeChanged {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        if collectionViewSizeChanged {
            collectionViewSizeChanged = false
            collectionView.performBatchUpdates({}, completion: nil)
        }
    }
    
    // MARK: Storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetailDirect" {
            if let cell = sender as? HPPYTaskListCollectionViewCell {
                let vc = segue.destination as? HPPYTaskDetailViewController
                vc?.setTask(cell.task!)
            }
        }
    }
    
}

extension HPPYTaskListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = Set(tasks.flatMap { $0.category.rawValue }).count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.filter { $0.category.rawValue == section + 1 }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = tasks
            .filter { $0.category.rawValue == indexPath.section + 1 }
            .sorted { $0.0.title < $0.1.title }[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskListCell", for: indexPath) as! HPPYTaskListCollectionViewCell
        cell.task = task
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 100.0
        let width = floor((collectionView.frame.size.width) / 2.0)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! HPPYTaskListCollectionViewCell
        performSegue(withIdentifier: "ShowTaskDetailDirect", sender: cell)
    }
    
}
