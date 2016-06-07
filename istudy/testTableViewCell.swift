//
//  testTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class testTableViewCell: UITableViewCell {
    @IBOutlet weak var testCourseName:UILabel?
    @IBOutlet weak var testCourseTime:UILabel?
    @IBOutlet weak var testCourseAdress:UILabel?
    @IBOutlet weak var testCourseTea:UILabel?
    @IBOutlet weak var fontTimeLabel:UILabel!
    @IBOutlet weak var fontAdressLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.testCourseTea?.backgroundColor = RGB(0, g: 153, b: 255)
        self.testCourseTea?.tintColor = UIColor.whiteColor()
        self.testCourseTea?.textColor = UIColor.whiteColor()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
