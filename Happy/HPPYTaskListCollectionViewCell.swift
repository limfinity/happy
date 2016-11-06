//
//  HPPYTaskListCollectionViewCell.swift
//  Happy
//
//  Created by Peter Pult on 06/11/2016.
//  Copyright © 2016 Peter Pult. All rights reserved.
//

import UIKit

class HPPYTaskListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    // Never set before UI was initialized
    var task: HPPYTask? {
        didSet {
            title.text = task?.title
            title.backgroundColor = task?.categoryColor().withAlphaComponent(0.3)
        }
    }
    
}
