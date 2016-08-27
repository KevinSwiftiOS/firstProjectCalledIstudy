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
//css修饰html格式的文件
let cssDesString =  "<head><style>p{text-indent: 2em; font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}" + "img{max-width: 100%}" +  "</style></head>" +  "" +  "<p>"
let cssOptionString = "<head><style>p{font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}" + "img{max-width: 100%}" +  "</style></head>" +  "" +  "<p>"
func RGB(r:Float,g:Float,b:Float) -> UIColor{
    return UIColor(colorLiteralRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
//描述图片的string
let imageDecString = "<head><style>p{font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}" + "img{width: 50.123px;height:50.123px}" +  "</style></head>" +  "" +  "<p>"
//分割文件的字符串
//记录字符串 随后进行截取
func diviseFileUrl(urlString:String) -> String{
    var tempString = ""
var cnt = 0
var i = 0
while i < urlString.characters.count{
    let index = urlString.startIndex.advancedBy(i)
    if(urlString[index] == "/"){
        cnt += 1
    }
    if(cnt == 6){
        break
        
    }
    i += 1
}
for j in i + 1 ..< urlString.characters.count{
    let index = urlString.startIndex.advancedBy(j)
    tempString.append(urlString[index])
}
   return tempString
}

