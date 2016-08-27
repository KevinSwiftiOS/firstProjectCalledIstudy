//
//  ShowBigImageFactory.swift
//  istudy
//
//  Created by hznucai on 16/6/1.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import Foundation
class ShowBigImageFactory: NSObject {
    static func showBigImage(target:UIViewController,webView:UIWebView,sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
        pt = sender.locationInView(webView)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = webView.stringByEvaluatingJavaScriptFromString(imgUrl)!
        
        if(urlToSave != ""){
            let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("showBigVC") as! ImageShowBigViewController
            vc.url = urlToSave
            target.navigationController?.pushViewController(vc, animated: true)
        }
    }
     static func topViewEDit(view:UIView) {
            //设置阴影效果 x向右偏移4 y向下偏移1 默认为(0,-3)
        
        //  view.layer.shadowOffset = CGSizeMake(4.0, 1.0)
        //    view.layer.shadowColor = UIColor.blackColor().CGColor
      view.backgroundColor = RGB(249, g: 249, b: 249)
        //阴影透明度默认为0
       // view.layer.shadowOpacity = 1.0
        //view.layer.borderWidth = 0.7
    }
        //阴影透明半径 默认为3
      //  view.layer.shadowRadius
        static func addBorderSubView(targetView:UIView){
            let borderView = UIView(frame: CGRectMake(0,SCREEN_HEIGHT - 30 - 1,SCREEN_WIDTH,1))
            borderView.layer.borderWidth = 1.0
            borderView.layer.borderColor =  RGB(249, g: 249, b: 249).CGColor
            targetView.addSubview(borderView)
        }
    
   //底部阴影的设置效果
  
    
}