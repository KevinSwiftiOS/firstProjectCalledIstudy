//
//  ContactPersonTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/23.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ContactPersonTableViewCell: UITableViewCell {
    @IBOutlet weak var teacherHeadImageView:UIImageView?
    @IBOutlet weak var teacherNameLabel:UILabel?
    @IBOutlet weak var selectedBtn:CustomContactSelectBtn?
   
    //每个联系人的id
    var id = NSInteger()
       override func awakeFromNib() {
        super.awakeFromNib()
                // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
