//
//  DetailTopicViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class DetailTopicViewController: UIViewController,UIWebViewDelegate{
    //webView来加载字符串
    @IBOutlet weak var replyBtn:UIButton!
    @IBOutlet weak var webView:UIWebView?
   var detailString = ""
    var projectid = NSInteger()
    //帖子的id
    var id = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView?.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
        self.webView?.delegate = self
self.webView?.loadHTMLString(detailString, baseURL: nil)
       self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func replyTopic(sender:UIButton){
        let replyTopicVC = UIStoryboard(name: "Discuss", bundle: nil).instantiateViewControllerWithIdentifier("ReplyTopicVC") as! ReplyTopicViewController
        replyTopicVC.title = "回复"
        replyTopicVC.id = self.id
        replyTopicVC.projectid = self.projectid
        self.navigationController?.pushViewController(replyTopicVC, animated: true)
    }
    func webViewDidStartLoad(webView: UIWebView) {
        ProgressHUD.show("请稍候")
        let frame = CGRectMake(0, 0, SCREEN_WIDTH, 2)
        webView.frame = frame
        self.view.bringSubviewToFront(self.replyBtn)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
    ProgressHUD.dismiss()
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        var frame = webView.frame
        frame.size.height = CGFloat(height!)
        webView.frame = frame
        self.view.bringSubviewToFront(self.replyBtn)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
        self.view.bringSubviewToFront(self.replyBtn)
    }
}
