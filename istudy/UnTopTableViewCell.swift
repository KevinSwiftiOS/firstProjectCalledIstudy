//
//  UnTopTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/27.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class UnTopTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var studentAndDateLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
