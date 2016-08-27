//
//  StationLetterCellTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class StationLetterCellTableViewCell: UITableViewCell {
    @IBOutlet weak var clickBtn:UIButton?
    @IBOutlet weak var kingOfLetterImageView:UIImageView?
    @IBOutlet weak var sendLetterPersonNameAndDateLabel:UILabel?
    @IBOutlet weak var subjectLabel:UILabel?

    var isRead = 0
    //是否是第一次赋值已读和未读
    var isFirstTimeToAssign = true
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
