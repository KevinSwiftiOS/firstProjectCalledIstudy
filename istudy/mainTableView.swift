//
//  mainTableView.swift
//  istudy
//
//  Created by hznucai on 16/4/9.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class mainTableView: UITableView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.nextResponder()?.touchesBegan(touches, withEvent: event)
    }
    
}
