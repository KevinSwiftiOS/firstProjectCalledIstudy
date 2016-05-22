//
//  TopDiscussTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/27.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class TopDiscussTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var teacherAndDateLabel:UILabel?
    @IBOutlet weak var headImageView:UIImageView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
