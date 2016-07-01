//
//  ComplexCompletionTableViewCell.swift
//  istudy
//
//  Created by hznucai on 16/5/2.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ComplexCompletionTableViewCell: UITableViewCell,UITextFieldDelegate,UIWebViewDelegate{
    var textField:UITextField?
    var webView:UIWebView?
    var cellHeight:CGFloat = 0.0
    var canEdit = false
    //自己填写的答案
    var selfAnswer = ""
    var Custag = NSInteger()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override  init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        webView = UIWebView(frame: CGRectMake(10,0,SCREEN_WIDTH - 20,1))
        webView?.delegate = self
        
        textField = UITextField(frame:CGRectMake(10, self.cellHeight,SCREEN_WIDTH - 20, 30))
      self.contentView.addSubview(textField!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    return true
    }
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
        cellHeight = 0.0
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
        textField?.frame = CGRectMake(10, self.cellHeight,SCREEN_WIDTH - 20, 30)
        self.cellHeight += 32
        textField?.delegate = self
       self.contentView.setNeedsDisplay()
        self.contentView.addSubview(webView)
        self.contentView.addSubview(textField!)
        if(self.selfAnswer == ""){
            textField?.placeholder = "请输入答案"
            textField!.setValue(UIFont.boldSystemFontOfSize(15), forKeyPath: "_placeholderLabel.font")

        }else{
            textField?.text = self.selfAnswer
        }
        textField?.layer.borderWidth = 0.3
        textField?.enabled = canEdit
            //发送通知
        NSNotificationCenter.defaultCenter().postNotificationName("ComplexCompletionwebViewHeight", object: self, userInfo: nil)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        //发送通知 通知到complex那个VC后进行进行组装
        //发送通知
        NSNotificationCenter.defaultCenter().postNotificationName("ComplexCompletionAnswer", object: self, userInfo: nil)
    }
}
