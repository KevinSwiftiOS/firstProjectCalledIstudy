//
//  StudyResourcePreviewViewController.swift
//  istudy
//
//  Created by hznucai on 16/5/23.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class StudyResourcePreviewViewController: UIViewController,UIWebViewDelegate{
    var url = NSURL()
    @IBOutlet weak var webView:UIWebView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView?.loadRequest(NSURLRequest(URL: url))
        self.webView?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webViewDidStartLoad(webView: UIWebView) {
        ProgressHUD.show("请稍候")
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        ProgressHUD.dismiss()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
