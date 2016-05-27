//
//  WritePeerAssessmentViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/22.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//闭包来传值
typealias send_index = (index:NSInteger) -> Void
class WritePeerAssessmentViewController: UIViewController,UIWebViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    var commentTextView = JVFloatLabeledTextView()
    //scrollView
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pickerView:UIPickerView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var currentQusLabel:UILabel!
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    var contentWebView = UIWebView()
    var totalHeight = CGFloat()
  //评论的是第几个
    var items = NSArray()
    var usertestid = NSInteger()
    var index = NSInteger()
    //评论的数组
    var scores = NSMutableArray()
    //var callBack:send_index?
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

       self.pickerView.hidden = true
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        leftSwipe.addTarget(self, action: #selector(WritePeerAssessmentViewController.addNewQus(_:)))
        rightSwipe.addTarget(self, action: #selector(WritePeerAssessmentViewController.addNewQus(_:)))
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.scrollView.addGestureRecognizer(self.leftSwipe)
        self.scrollView.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
 //self.automaticallyAdjustsScrollViewInsets = false
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 //提交评论的结果
    @IBAction func savePeer(sender:UIButton){
     //   self.callBack!(index:self.index)
        //进行保存
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    override func viewWillAppear(animated: Bool) {
        ProgressHUD.show("请稍候")
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //写请求时间等等
        let dic:[String:AnyObject] = ["usertestid":"\(self.usertestid)",
                                      "authtoken":authtoken]
    Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/hupingusertest", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
        switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    
                    ProgressHUD.showError("请求失败")
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
            self.initView()
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        var frame = webView.frame
        frame.size.height = CGFloat(height!) + 5
        totalHeight = frame.size.height + 2
        webView.frame = frame
        
        self.scrollView.addSubview(webView)
      //学生的答案
        let stuAnswerLabel = UILabel(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH, 21))
        stuAnswerLabel.text = "学生答案:"
        stuAnswerLabel.tag = 10000
        self.scrollView.addSubview(stuAnswerLabel)
        self.totalHeight += 22
        let  stuAnswerWebView = UIWebView(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,110))
        if(self.items[index].valueForKey("answer") as? String != nil && self.items[index].valueForKey("answer") as! String != ""){
        stuAnswerWebView.loadHTMLString(self.items[index].valueForKey("answer") as! String, baseURL: nil)
              self.totalHeight += 110
        }else{
            stuAnswerWebView.loadHTMLString("无学生答案", baseURL: nil)
            stuAnswerWebView.frame.size.height = 22
            self.totalHeight += 24
        }
       
        self.scrollView.addSubview(stuAnswerWebView)
        let peerAssermentLabel = UILabel(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,21))
        peerAssermentLabel.text = "我的评论:"
peerAssermentLabel.tag = 100000
        self.scrollView.addSubview(peerAssermentLabel)
        self.totalHeight += 22
        let rules = self.items[index].valueForKey("rules") as! NSArray
        //循环加载rules
        for i in 0 ..< rules.count{
            let ruleContentLabel = UILabel(frame: CGRectMake(0,self.totalHeight,SCREEN_WIDTH,1))
            ruleContentLabel.text = rules[i].valueForKey("contents") as? String
            ruleContentLabel.numberOfLines = 0
            ruleContentLabel.lineBreakMode = .ByWordWrapping
            let size = ruleContentLabel.sizeThatFits(CGSizeMake(SCREEN_WIDTH, 100))
            var ruleContentLabelSize = ruleContentLabel.frame
            ruleContentLabelSize.size = size
            ruleContentLabel.frame = ruleContentLabelSize
            self.scrollView.addSubview(ruleContentLabel)
            self.totalHeight += size.height + 2
            //评论的分数显示
            ruleContentLabel.tag = 1000000
            let assermentLabel = UILabel(frame: CGRectMake(0,self.totalHeight,100,21))
            assermentLabel.text = "评论分数:" + "\(self.scores[i] as! NSNumber)"
            assermentLabel.tag = i
            self.scrollView.addSubview(assermentLabel)
            let assermentBtn = UIButton(frame: CGRectMake(120,self.totalHeight,100,21))
            assermentBtn.tag = i + 100
            assermentBtn.setTitle("评论", forState: .Normal)
            assermentBtn.backgroundColor = RGB(0, g: 153, b: 255)
            assermentBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            assermentBtn.addTarget(self, action: #selector(WritePeerAssessmentViewController.gotoPeer(_:)), forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(assermentBtn)
            self.totalHeight += 22
        }
        //加评论的文本框
         commentTextView = JVFloatLabeledTextView(frame: CGRectMake(0,self.totalHeight,SCREEN_WIDTH,100))
        self.totalHeight += 100
        self.scrollView.addSubview(commentTextView)
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.totalHeight)
    }
    //加载新题目
    func addNewQus(sender:UISwipeGestureRecognizer){
        if sender.direction == .Left{
            if(self.index != self.items.count - 1){
                self.index += 1
                self.initView()
            }else{
                ProgressHUD.showError("已完成评论")
            }
        }
        if sender.direction == .Right{
            if(self.index != 0){
                self.index -= 1
                self.initView()
            }else{
                ProgressHUD.showError("开头")
            }
        }
    }
    func initView() {
        for view in self.scrollView.subviews{
            view.removeFromSuperview()
        }
        self.currentQusLabel.text = "\(self.index + 1)" + "/"  +  "\(self.items.count)"
        self.contentWebView.loadHTMLString(self.items[index].valueForKey("content") as! String, baseURL: nil)
        self.contentWebView.delegate = self
        self.totalHeight = 0
        //加载评论的分数
        self.scores.removeAllObjects()
        let rules = self.items[index].valueForKey("rules") as! NSMutableArray
        for i in 0 ..< rules.count{
            if(rules[i].valueForKey("score") as? NSNumber != nil && rules[i].valueForKey("score") as! NSNumber != 0 ){
                self.scores.addObject(rules[i].valueForKey("score") as! NSNumber)
            }else{
                self.scores.addObject(0)
            }
        }
    }
    func gotoPeer(sender:UIButton){
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        let tag = sender.tag - 100
        self.pickerView.tag = 1000 + tag
        self.pickerView.hidden = false
        
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rules = self.items[index].valueForKey("rules") as! NSMutableArray
        let tempIndex = pickerView.tag - 1000
       let totalscore =  rules[tempIndex].valueForKey("totalscore") as! NSInteger
        return totalscore + 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return "\(row)" + "分"
        }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
              let tag = pickerView.tag - 1000
       
        for view in self.scrollView.subviews{
            if view.isKindOfClass(UILabel.classForCoder()){
                if(view.tag == tag){
        let label =  view as! UILabel
           label.text =  "评论分数:" + "\(row)"
}
            }
        }
        pickerView.hidden = true
    }
}
