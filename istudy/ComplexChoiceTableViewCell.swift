//
//  ComplexChoiceTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/5/1.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ComplexChoiceTableViewCell: UITableViewCell,UIWebViewDelegate{
    var  optionWebView:UIWebView?
     var btn:UIButton?
    var url = ""
    var cellHeight:CGFloat = 0
    var canTap  = false
    var view:UIView?
    var tap = UITapGestureRecognizer()
    var Custag = NSInteger()
    override func awakeFromNib() {
        super.awakeFromNib()
        //optionWebView?.delegate = self
        // Initialization code
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        btn = UIButton(frame: CGRectMake(10,10,30,30))
        for view in self.contentView.subviews{
            view.removeFromSuperview()
        }
        self.optionWebView = UIWebView(frame:CGRectMake(30, 0, SCREEN_WIDTH - 30, 1))
        self.optionWebView?.delegate = self
      
        self.contentView.addSubview(btn!)
      self.tap = UITapGestureRecognizer(target: self, action: #selector(ComplexChoiceTableViewCell.tap(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
    }
    func webViewDidStartLoad(webView: UIWebView) {
        self.cellHeight = 0
        webView.frame = CGRectMake(40, 0, SCREEN_WIDTH - 45, 1)
        
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
        frame.size.height = CGFloat(height!) + 5
        webView.frame = frame
        self.cellHeight = CGFloat(height!) + 10
   
        //小于按钮的高度
        if(self.cellHeight < 50){
            self.cellHeight = 50
        }
        self.contentView.addSubview(webView)
         view = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,self.cellHeight))
        view!.addGestureRecognizer(tap)
        self.contentView.addSubview(view!)
        self.contentView.bringSubviewToFront(view!)
        view!.userInteractionEnabled = canTap
        
        //发送通知
        NSNotificationCenter.defaultCenter().postNotificationName("ComplexChoicewebViewHeight", object: self, userInfo: nil)
    }
    func tap(sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
    
        pt = sender.locationInView(self.optionWebView)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.optionWebView!.stringByEvaluatingJavaScriptFromString(imgUrl)!
        if(urlToSave != ""){
            self.url = urlToSave
        NSNotificationCenter.defaultCenter().postNotificationName("ComplexShowBigImage", object: self, userInfo: nil)
        
    }
    
      //发送点击的通知
            NSNotificationCenter.defaultCenter().postNotificationName("ComplexTapBtn", object: self, userInfo: nil)
    }
    deinit{
        self.optionWebView?.delegate = nil
    }
    
}
