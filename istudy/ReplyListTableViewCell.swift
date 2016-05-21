//
//  ReplyListTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ReplyListTableViewCell: UITableViewCell {
    @IBOutlet weak var contectWebView:UIWebView?
    @IBOutlet weak var headImageView:UIImageView?
    @IBOutlet weak var authorLabel:UILabel?
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
