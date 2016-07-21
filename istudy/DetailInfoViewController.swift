//
//  DetailInfoViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/30.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class DetailInfoViewController: UIViewController,UIWebViewDelegate{
    var  webView = UIWebView()
    var  titleLabel = UILabel()
    var authorLabel = UILabel()
    var dateLabel = UILabel()
    var contentScrollView = UIScrollView()
    var viewTimesLabel = UILabel()
    var id = NSInteger()
    //加载webView的详细内容
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
        self.automaticallyAdjustsScrollViewInsets = false
        
        ProgressHUD.show("请稍候")
        let dic:[String:AnyObject] = ["id":"\(self.id)"]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/notifyinfo", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"] != 0){
                    ProgressHUD.showError("请求失败")
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        var totalString = ""
                        self.title = json["info"]["title"].string
                        totalString += json["info"]["content"].string! + "</br>"
                        self.webView.delegate = self
                        if(json["info"]["author"].string != nil) {
                            totalString  += "发布人:" + json["info"]["author"].string! + "</br>"
                        }
                        let yearRange = NSMakeRange(0, 4)
                        let monthRange = NSMakeRange(4, 2)
                        let dateRange = NSMakeRange(6, 2)
                        let tempStartDate = json["info"]["date"].string! as NSString
                        let  date = "发布时间:" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange)
                        totalString += (date as String) + "</br>"
                        
                        
                        self.webView.loadHTMLString(totalString, baseURL: nil)
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //webView的代理
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        //        self.titleLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
        //        self.titleLabel.numberOfLines = 0
        //            titleLabel.textAlignment = .Center
        //        titleLabel.lineBreakMode = .ByWordWrapping
        //
        //        let size = titleLabel.sizeThatFits(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT))
        //        titleLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, size.height)
        //
        //        //整个的高度
        //        let titleLabelHeight = size.height + 20
        self.contentScrollView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        
        var frame = webView.frame
        frame = CGRectMake(0,0, SCREEN_WIDTH, CGFloat(height! + 5))
        webView.frame = frame
        let totalHeight = 10 + CGFloat(height!) + 5
        //        self.authorLabel.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 21)
        //        self.authorLabel.textAlignment = .Right
        //        totalHeight += 23
        //        self.dateLabel.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 21)
        //        self.dateLabel.textAlignment = .Right
        //        totalHeight += 23
        //        self.viewTimesLabel.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 21)
        //        self.viewTimesLabel.textAlignment = .Right
        //       // self.view.addSubview(self.titleLabel)
        //        self.contentScrollView.addSubview(authorLabel)
        //        self.contentScrollView.addSubview(dateLabel)
        self.contentScrollView.addSubview(webView)
        // self.contentScrollView.addSubview(titleLabel)
        // self.contentScrollView.addSubview(viewTimesLabel)
        self.view.addSubview(self.contentScrollView)
        //竖直方向的不能展示滑动条
        let scrollView = webView.subviews[0] as! UIScrollView
        scrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight + 70)
        ProgressHUD.dismiss()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    
}
