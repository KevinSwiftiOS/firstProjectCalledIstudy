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
    var url = ""
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
        frame.size.height = CGFloat(height!) + 8
        webView.frame = frame
       self.cellHeight = 10 + 21 + 10 + 21 + frame.size.height
        NSNotificationCenter.defaultCenter().postNotificationName("replyListContentWebViewHeight", object: self, userInfo: nil)
     tap = UITapGestureRecognizer(target: self, action: #selector(ReplyListTableViewCell.showBig(_:)))
      
       
      let   view = UIView(frame: CGRectMake(0,self.cellHeight - CGFloat(height!),SCREEN_WIDTH,CGFloat(height!)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReplyListTableViewCell.showBig(_:))))
        self.contentView.addSubview(view)
        self.contentView.bringSubviewToFront(view)
        view.userInteractionEnabled = true
    }
 //图片的放大也发送通知


    func showBig(sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
        
        pt = sender.locationInView(self.contectWebView)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.contectWebView!.stringByEvaluatingJavaScriptFromString(imgUrl)!
        if(urlToSave != ""){
            //发送通知 来进行预览
            url = urlToSave
            NSNotificationCenter.defaultCenter().postNotificationName("replyListShowBig", object: self, userInfo: nil)
        }

}
    }
