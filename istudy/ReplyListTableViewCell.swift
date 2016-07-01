//
//  ReplyListTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ReplyListTableViewCell: UITableViewCell,UIWebViewDelegate {
    @IBOutlet weak var contectWebView:UIWebView?
    @IBOutlet weak var headImageView:UIImageView?
    @IBOutlet weak var authorLabel:UILabel?
    @IBOutlet weak var dateLabel:UILabel?
    var tap = UITapGestureRecognizer()
    var cellHeight  = CGFloat()
    var cellTag = NSInteger()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contectWebView?.delegate = self
               // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 21 + 21 + 10 + 10, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        //webView不能动
        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
      
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        var frame = webView.frame
        frame.size.height = CGFloat(height!) + 4
        webView.frame = frame
       self.cellHeight = 10 + 21 + 10 + 21 + 12 + frame.size.height
        NSNotificationCenter.defaultCenter().postNotificationName("replyListContentWebViewHeight", object: self, userInfo: nil)
     tap = UITapGestureRecognizer(target: self, action: #selector(ReplyListTableViewCell.showBig(_:)))
        self.contectWebView?.addGestureRecognizer(tap)
        self.contectWebView?.userInteractionEnabled = true
        self.contectWebView?.multipleTouchEnabled = true
    }
 //图片的放大也发送通知
    
    func showBig(sender:UITapGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("replyListShowBig", object: self, userInfo: nil)
    }

}
extension UIImage{
    func circleImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        //获得图形上下文
        let ctx = UIGraphicsGetCurrentContext()
        //设置一个范围
        let rect = CGRectMake(0,0, self.size.width, self.size.height)
        //根据一个rect创建一个椭圆
        CGContextAddEllipseInRect(ctx, rect)
        //裁剪
        CGContextClip(ctx)
        //将原照片画到图形上下文
        self.drawInRect(rect)
        //从上下文获得裁剪后的照片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        return newImage
    }
}
