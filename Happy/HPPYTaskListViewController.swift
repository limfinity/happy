//
//  HPPYTaskListViewController.swift
//  Happy
//
//  Created by Peter Pult on 03/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

import UIKit

let HORIZONTAL_CELL_SPACING: CGFloat = 5
let SECTION_SPACING: CGFloat = 15

class HPPYTaskListViewController: UIViewController {
    
    var collectionViewSizeChanged: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    lazy var tasks = HPPYTaskController.getTasks().flatMap { $0 as? HPPYTask }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ARAnalytics.pageView("Task List")
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TaskListHeader", for: indexPath) as! HPPYTaskListHeaderView
            headerView.categoryImageView.image = tasks.filter { $0.category.rawValue == indexPath.section + 1 }.first?.categoryImage()
            return headerView
        default:
            assert(false, "Error unexpected collection view for kind \(kind)")
        }
        return UICollectionReusableView() // Should never be called
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = tasks
            .filter { $0.category.rawValue == indexPath.section + 1 }
            .sorted { $0.0.title < $0.1.title }[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskListCell", for: indexPath) as! HPPYTaskListCollectionViewCell
        cell.task = task
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: collectionView.frame.size.width, height: 146)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: SECTION_SPACING, bottom: SECTION_SPACING, right: SECTION_SPACING)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return HORIZONTAL_CELL_SPACING
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 100.0
        let width = floor((collectionView.frame.size.width - 2 * SECTION_SPACING - HORIZONTAL_CELL_SPACING) / 2.0)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! HPPYTaskListCollectionViewCell
        performSegue(withIdentifier: "ShowTaskDetailDirect", sender: cell)
    }
    
}
