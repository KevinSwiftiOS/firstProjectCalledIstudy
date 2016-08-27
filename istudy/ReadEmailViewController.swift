//
//  ReadEmailViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/12.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class ReadEmailViewController: UIViewController,UIGestureRecognizerDelegate{
    //webView用来加载
   //下面的两个按钮 
    var tap = UITapGestureRecognizer()
    @IBOutlet weak var writeBtn:UIButton!
    //是发件箱的话 下面回复所有和回复的键消失
    var isOut = false
     var tempReceiveArray = NSArray()
    @IBOutlet weak var webView:UIWebView?
    @IBOutlet weak var subjectLabel:UILabel?
    @IBOutlet weak var btmView:UIView!
    var textView = UITextView()
    var trushBtn = UIButton()
    //邮件的题目
    //选了第几个
    var index = NSInteger()
    //回复信得时候的主题
    var subject = ""
    //要发送的人的名字和姓名
    var sendIds = NSMutableArray()
    var sendNames = NSMutableArray()
    //短信的code
    var code = ""
    //内容的html格式的字符串
    var string = ""
    //发信人的名字和id 单独回复的时候有用
    var senderId = NSInteger()
    var senderName = ""
    
    @IBOutlet weak var replyToOneBtn:UIButton?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加载数组
          //当有navigationBar的时候 不设置向下移动64个单位 textView和tableView都是scrollView，因此当有navigationBar的时候 都会自动的往下移
        // Do any additional setup after loading the view.
        //receiveid和recevieName 进行标示
        writeBtn.setFAIcon(FAType.FAEdit, iconSize: 30, forState: .Normal)
        replyToOneBtn?.setFAIcon(FAType.FAReply, iconSize: 30, forState: .Normal)
    self.view.bringSubviewToFront(self.writeBtn)
    self.automaticallyAdjustsScrollViewInsets = false
    self.tabBarController?.tabBar.hidden = true
        self.subjectLabel?.text = self.subject
        self.webView?.loadHTMLString(imageDecString + string, baseURL: nil)
        //加载图片放大的效果
        tap = UITapGestureRecognizer(target: self, action: #selector(ReadEmailViewController.showBig(_:)))
        self.webView?.userInteractionEnabled = true
        self.webView?.addGestureRecognizer(tap)
        self.tap.delegate = self
     
    }
    //点击图片时候的放大
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == self.tap){
            return true
        }else{
            return false
        }
    }

    func showBig(sender:UITapGestureRecognizer){
        ShowBigImageFactory.showBigImage(self, webView: self.webView!, sender: sender)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    //回复单个人的发件人
    @IBAction func replyToOne(sender:UIButton){
        if(isOut){
            ProgressHUD.showError("不能回复自己")
        }else{
        //只加载发件人
        self.sendIds.removeAllObjects()
        self.sendNames.removeAllObjects()
        self.sendIds.addObject(senderId)
        self.sendNames.addObject(senderName)
        
        let writeEmailVC = UIStoryboard(name: "StationLetter", bundle: nil)
        .instantiateViewControllerWithIdentifier("writeLetterVC") as! WriteLetterViewController
        writeEmailVC.senderName = self.senderName
        writeEmailVC.senderId = self.senderId
        writeEmailVC.title = "写邮件"
        writeEmailVC.parentcode = self.code
        writeEmailVC.subject = "回复:" + self.subject
        writeEmailVC.isReply = true
        self.navigationController?.pushViewController(writeEmailVC, animated: true)
        }
    }
      //只写信不发人的
    @IBAction func writeEmail(sender:UIButton){
        self.sendIds.removeAllObjects()
        self.sendNames.removeAllObjects()
        let writeEmailVC = UIStoryboard(name: "StationLetter", bundle: nil)
            .instantiateViewControllerWithIdentifier("writeLetterVC") as! WriteLetterViewController
//        writeEmailVC.selectedPersonIdArray = self.sendIds
//           writeEmailVC.selectedPersonNameArray = self.sendNames
        writeEmailVC.title = "写邮件"
        self.navigationController?.pushViewController(writeEmailVC, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
