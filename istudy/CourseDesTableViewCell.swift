//
//  CourseDesTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
class CourseDesTableViewCell: UITableViewCell {
    @IBOutlet weak var courseName:UILabel?
    @IBOutlet weak var courseTea:UILabel?
    @IBOutlet weak var courseImageBtn:UIButton?
    @IBOutlet weak var studyCourse:UIButton?
    @IBOutlet weak var arrowImageView:UIImageView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}