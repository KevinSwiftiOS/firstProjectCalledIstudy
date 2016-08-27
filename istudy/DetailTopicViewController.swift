//
//  DetailTopicViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class DetailTopicViewController: UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate{
    //webView来加载字符串
    //添加手势放大
    var tap = UITapGestureRecognizer()
    @IBOutlet weak var replyBtn:UIButton!
    @IBOutlet weak var webView:UIWebView?
    @IBOutlet weak var btmView:UIView!
    var detailString = ""
    var projectid = NSInteger()
    //帖子的id
    var id = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        self.webView?.delegate = self
        tap = UITapGestureRecognizer(target: self, action: #selector(DetailTopicViewController.showBig(_:)))
        
        self.view.userInteractionEnabled = true
        self.view.multipleTouchEnabled = true
        self.webView?.userInteractionEnabled = true
        self.webView?.multipleTouchEnabled = true
        self.webView?.loadHTMLString(imageDecString + detailString, baseURL: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        replyBtn.setFAText(prefixText: "", icon: FAType.FAReply, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        replyBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //跳转到回复列表的界面
    @IBAction func replyTopic(sender:UIButton){
        let replyTopicVC = UIStoryboard(name: "Discuss", bundle: nil).instantiateViewControllerWithIdentifier("ReplyTopicVC") as! ReplyTopicViewController
        replyTopicVC.title = "回复"
        replyTopicVC.id = self.id
        replyTopicVC.projectid = self.projectid
        self.navigationController?.pushViewController(replyTopicVC, animated: true)
    }
    //webView的加载
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
        
        self.webView!.addGestureRecognizer(tap)
        self.webView!.userInteractionEnabled = true
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
        self.tap.delegate = self
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        
    }
    //手势图片的放大
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == self.tap){
            return true
        }else{
            return false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
        // self.view.bringSubviewToFront(self.replyBtn)
    }
    //图片的放大
    func showBig(sender:UITapGestureRecognizer){
        
        ShowBigImageFactory.showBigImage(self, webView: webView!, sender: sender)
    }
    deinit {
        print("detailTopicReadDeinit")
    }
}
