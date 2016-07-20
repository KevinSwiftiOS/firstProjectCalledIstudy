//
//  CourseInfoTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/28.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class CourseInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel?
  
    @IBOutlet weak var dateLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
