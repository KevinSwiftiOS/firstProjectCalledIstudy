//
//  MyHomeWorkTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/16.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class MyHomeWorkTableViewCell: UITableViewCell {
    @IBOutlet weak var title:UILabel?
    @IBOutlet weak var Score:UILabel?
    //开始时间和截止时间
    @IBOutlet weak var dateStart:UILabel?
    @IBOutlet weak var answerQusBtn:UIButton?

    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
   var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //记录每个test的id
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
