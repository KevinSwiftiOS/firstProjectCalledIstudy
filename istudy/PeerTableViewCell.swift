//
//  PeerTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/7/1.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class PeerTableViewCell: UITableViewCell {
    @IBOutlet weak var numLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    @IBOutlet weak var YorNLabel:UILabel!
    @IBOutlet weak var peerBtn:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
