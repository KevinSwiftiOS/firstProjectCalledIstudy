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
//分割文件路径上传的url
func diviseUrl(urlString:String) -> (String){
    var tempUrlString = urlString
    //先统计总共有几个/
    tempUrlString = tempUrlString.stringByReplacingOccurrencesOfString("http://dodo.hznu.edu.cn/", withString: "")
    var totalSlash = 0
    for i in 0 ..< tempUrlString.characters.count{
        let index = tempUrlString.startIndex.advancedBy(i)
        if(tempUrlString[index] == "/"){
            totalSlash += 1
        }
    }
    //分割前面一段文件路径名的字符
    var fileString = ""
    var cnt = 0
    var i = 0
    while i <  tempUrlString.characters.count{
        let index = tempUrlString.startIndex.advancedBy(i)
        if(tempUrlString[index] == "/"){
            //判断是否到达最后一个
            cnt += 1
            if(cnt == totalSlash){
                break
            }
        }
        //始终是要加上的
        fileString.append(tempUrlString[index])
        i += 1
    }
    //文件名字的提取
    var fileNameString = ""
    for j in i + 1 ..< tempUrlString.characters.count{
        let index = tempUrlString.startIndex.advancedBy(j)
        fileNameString.append(tempUrlString[index])
    }
    //将中文转换成乱码
    fileString = fileString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
    fileNameString = fileNameString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
    return(fileString)
}
//创建文件夹
func creathDir(fileURLString:String) {
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let str = NSString(string: path)
    let fileUrl = str.stringByAppendingPathComponent(fileURLString)
    let fileManager = NSFileManager.defaultManager()
    if(!fileManager.fileExistsAtPath(fileUrl)) {
        do{  try fileManager.createDirectoryAtPath(fileUrl, withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("创建文件失败")
        }
    }
}
//判断文件是否存在
func existFile(fileString:String) -> String{
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let str = NSString(string: path)
    let fileUrl = str.stringByAppendingString("/" + fileString)
    let fileManager = NSFileManager.defaultManager()
    if(fileManager.fileExistsAtPath(fileUrl)){
        return fileUrl
    }
    return ""
}
//文件下载时候的url路径
func createURLInDownLoad(fileUrl:String,fileName:String) -> NSURL{
//    let (fileString,fileNameString) = diviseUrl(url)
    
    let fileManager = NSFileManager.defaultManager()
     let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory,inDomains: .UserDomainMask)[0]
    //随后url加文件名
  return   directoryURL.URLByAppendingPathComponent(fileUrl + "/" + fileName)!

}



