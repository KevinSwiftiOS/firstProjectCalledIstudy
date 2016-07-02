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
            //设置阴影效果
          view.layer.shadowOffset = CGSizeMake(2.0, 1.0)
            view.layer.shadowColor = UIColor.blackColor().CGColor
           view.layer.shadowOpacity = 0.8
  }
   //底部阴影的设置效果
  
    
}