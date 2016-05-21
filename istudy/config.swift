//
//  config.swift
//  istudy
//
//  Created by hznucai on 16/3/4.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import Foundation
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let MY_FONT  = "Bauhaus ITC"
func RGB(r:Float,g:Float,b:Float) -> UIColor{
    return UIColor(colorLiteralRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}