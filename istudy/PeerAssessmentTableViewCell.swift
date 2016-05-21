//
//  PeerAssessmentTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/22.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class PeerAssessmentTableViewCell: UITableViewCell {
 //评论的按钮 要评论的试卷 老师 开始时间和截止时间
    @IBOutlet weak var title:UILabel?
    @IBOutlet weak var teacher:UILabel?
    @IBOutlet weak var startDateAndEndDate:UILabel?
    @IBOutlet weak var peerBtn:UIButton?
    //记录每个评论试卷的id
    var peerId = String()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
