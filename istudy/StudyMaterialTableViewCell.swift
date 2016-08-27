//
//  StudyMaterialTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/8.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class StudyMaterialTableViewCell: UITableViewCell {
    @IBOutlet weak var typeImageView:UIImageView!
    @IBOutlet weak var fileNameLalel:UILabel!
    //    @IBOutlet weak var typeLabel:UILabel!
    //    @IBOutlet weak var createTimeLabel:UILabel!
    //    @IBOutlet weak var sizeLabel:UILabel!
    @IBOutlet weak var totalLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
