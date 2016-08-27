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
import Font_Awesome_Swift
//闭包来传值
typealias send_index = (index:NSInteger) -> Void
class WritePeerAssessmentViewController: UIViewController,UIWebViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UIGestureRecognizerDelegate{
    //键盘出现时的操作
    var tap = UITapGestureRecognizer()
    var aboveCommentTextHeight = CGFloat()
    var commentTextView = JVFloatLabeledTextView()
    //scrollView
    @IBOutlet weak var btmView:UIView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pickerView:UIPickerView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var currentQusLabel:UILabel!
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    var contentWebView = UIWebView()
    var totalHeight = CGFloat()
var questions = NSMutableArray()
  //评论的是第几个
    var items = NSArray()
    var usertestid = NSInteger()
    var index = 0 
//加载视图的一些代理
    override func viewDidLoad() {
        super.viewDidLoad()
        let diveseView = UIView(frame: CGRectMake(0,SCREEN_HEIGHT * 0.8 - 30,SCREEN_WIDTH,1))
        diveseView.layer.borderWidth = 1.0
        self.view.addSubview(diveseView)
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加左右的按钮
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        rightBtn?.addTarget(self, action: #selector(WritePeerAssessmentViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        leftBtn!.addTarget(self, action:#selector(WritePeerAssessmentViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        //设置左右的按钮
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
        saveBtn?.setFAText(prefixText: "", icon: FAType.FASave, postfixText: "", size: 25, forState: .Normal)

        //键盘出现的时候
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WritePeerAssessmentViewController.resign)))
        //设置阴影效果
       ShowBigImageFactory.topViewEDit(self.topView)
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
    
 //提交评论的结果 转化为字典模式
    @IBAction func savePeer(sender:UIButton){
        pickerView.hidden = true
     //   self.callBack!(index:self.index)
        //进行保存
        let userDefault = NSUserDefaults.standardUserDefaults()
     
      
        //进行base64字符串解码
        let paramDic:[String:AnyObject] = ["usertestid":"\(self.usertestid)",
                                           "questions":self.questions]
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        let parameter:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,"data":result]
       
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/submithuping", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                                              if(json["retcode"].number != 0){
                    print(json["retcode"].number)
                ProgressHUD.showError("评论失败")
                }else{
                    ProgressHUD.showSuccess("评论成功")
          
}
            case .Failure(_):ProgressHUD.showError("评论失败")
            }
        }

        
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
                    //实际上这里就是把他的字典全部拿到 在改变评论的时候就直接在字典里面进行修改即可
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
                        for tempOut in 0 ..< self.items.count{
                            let dic1 = NSMutableDictionary()
                            dic1.setObject(self.items[tempOut].valueForKey("id") as! NSNumber, forKey: "questionid")
                            if(self.items[tempOut].valueForKey("comments") as? String != nil &&
                                self.items[tempOut].valueForKey("comments") as! String != ""){
                                    dic1.setObject(self.items[tempOut].valueForKey("comments") as! String, forKey: "comments")
                            }else{
                                   dic1.setObject("", forKey: "comments")
                            }
                        dic1.setObject(0, forKey: "isauthorvisible")
                            let rules = self.items[tempOut].valueForKey("rules") as! NSMutableArray
                            let arr1 = NSMutableArray()
                            for tempIn in 0 ..< rules.count{
                                let dic2 = NSMutableDictionary()
                            dic2.setObject(rules[tempIn].valueForKey("ruleid") as! NSNumber, forKey: "ruleid")
                             if(rules[tempIn].valueForKey("score") as? NSNumber != nil &&
                                rules[tempIn].valueForKey("score") as! NSNumber != 0){
                                dic2.setObject(rules[tempIn].valueForKey("score") as! NSNumber, forKey: "score")
                             }else{
                                dic2.setObject(0, forKey: "score")
                                }
                            arr1.addObject(dic2)
                            }
                        dic1.setObject(arr1, forKey: "rules")
                        self.questions.addObject(dic1)
                        }
                                   self.initView()
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    //webView的一些代理
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
        let webScrollView = webView.subviews[0] as! UIScrollView
        webScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, CGFloat(height!))
        tap.delegate = self
        tap.addTarget(self, action: #selector(WritePeerAssessmentViewController.showBig(_:)))
        webView.addGestureRecognizer(tap)
        let peerAssermentLabel = UILabel(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH - 10,21))
        let firTitle = NSMutableAttributedString(string: "我的评论:")
        //设置为蓝色
        let range = NSMakeRange(0, firTitle.length)
        firTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: range)
        peerAssermentLabel.attributedText = firTitle
        peerAssermentLabel.tag = 100000
        self.scrollView.addSubview(peerAssermentLabel)
        self.totalHeight += 22
        let rules = self.items[index].valueForKey("rules") as! NSMutableArray
        //循环加载rules
        let scores = self.questions[index].valueForKey("rules") as! NSMutableArray
        for i in 0 ..< rules.count{
            let ruleContentLabel = UILabel(frame: CGRectMake(5,self.totalHeight,SCREEN_WIDTH - 10,1))
            ruleContentLabel.text = rules[i].valueForKey("contents") as? String
            ruleContentLabel.numberOfLines = 0
            ruleContentLabel.lineBreakMode = .ByWordWrapping
            let size = ruleContentLabel.sizeThatFits(CGSizeMake(SCREEN_WIDTH - 10, 100))
            var ruleContentLabelSize = ruleContentLabel.frame
            ruleContentLabelSize.size = size
            ruleContentLabel.frame = ruleContentLabelSize
            self.scrollView.addSubview(ruleContentLabel)
            self.totalHeight += size.height + 2
            //评论的分数显示
            ruleContentLabel.tag = 1000000
            
            let assermentLabel = UILabel(frame: CGRectMake(5,self.totalHeight,80,21))
            assermentLabel.text = "评论分数:"
            //assermentLabel.tag = i
            self.scrollView.addSubview(assermentLabel)
            let assermentBtn = UIButton(frame: CGRectMake(90,self.totalHeight,50,21))
            assermentBtn.tag = i
            if((scores[i].valueForKey("score") as? NSNumber) != nil && scores[i].valueForKey("score") as! NSNumber != 0) {
//            let underLineString = NSMutableAttributedString(string: "  ")
//                let underLineRange = NSMakeRange(0, underLineString.length)
//                let number = NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
//     underLineString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: underLineRange)
//                  underLineString.addAttribute(NSUnderlineStyleAttributeName, value: number, range: underLineRange)
        let scoreString = NSMutableAttributedString(string: " \(scores[i].valueForKey("score") as! NSNumber)")
                let scoreStringRange = NSMakeRange(0, scoreString.length)
                scoreString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: scoreStringRange)
//            scoreString.addAttribute(NSUnderlineStyleAttributeName, value: number, range: scoreStringRange)
//                let totalString = NSMutableAttributedString()
//                totalString.appendAttributedString(underLineString)
//                totalString.appendAttributedString(scoreString)
//                totalString.appendAttributedString(underLineString)
//       assermentBtn.setAttributedTitle(totalString, forState: .Normal)
            assermentBtn.setAttributedTitle(scoreString, forState: .Normal)
            }else{
                let scoreString = NSMutableAttributedString(string: "0")
                let scoreStringRange = NSMakeRange(0, scoreString.length)
                scoreString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: scoreStringRange)
                assermentBtn.setAttributedTitle(scoreString, forState: .Normal)
            }
            assermentBtn.layer.borderWidth = 1.0
            assermentBtn.layer.borderColor = UIColor.redColor().CGColor
            let afterAssermentBtnLabel = UILabel(frame: CGRectMake(142,self.totalHeight,20,21))
            afterAssermentBtnLabel.text = "分"
            //设置下划线
            
//            let str1 = NSMutableAttributedString(string: (assermentBtn.titleLabel?.text)!)
//            let range1 = NSRange(location: 0, length: str1.length - 1)
//            let range2 = NSRange(location: str1.length - 1, length: 1)
//            let number = NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
//            str1.addAttribute(NSUnderlineStyleAttributeName, value: number, range: range1)
//            str1.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: range1)
//            str1.addAttribute(NSForegroundColorAttributeName,value:UIColor.blackColor(), range: range2)
//            
//            assermentBtn.setAttributedTitle(str1, forState: .Normal)
           // assermentBtn.backgroundColor = RGB(0, g: 153, b: 255)
          
            assermentBtn.addTarget(self, action: #selector(WritePeerAssessmentViewController.gotoPeer(_:)), forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(afterAssermentBtnLabel)
            self.scrollView.addSubview(assermentBtn)
            self.totalHeight += 22
        }
        aboveCommentTextHeight = self.totalHeight
        let commentTextLabel = UILabel(frame: CGRectMake(5,self.totalHeight,SCREEN_WIDTH - 10,21))
        commentTextLabel.tag = 10000000
        let comentTitleString = NSMutableAttributedString(string: "评论区:")
        let comnetRange = NSMakeRange(0, comentTitleString.length)
        comentTitleString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: comnetRange)
        commentTextLabel.attributedText = comentTitleString
        self.scrollView.addSubview(commentTextLabel)
        self.totalHeight += 22
        //加评论的文本框
         commentTextView = JVFloatLabeledTextView(frame: CGRectMake(5,self.totalHeight,SCREEN_WIDTH - 10,100))
        if(self.questions[index].valueForKey("comments") as? String != nil && self.questions[index].valueForKey("comments") as! String != ""){
            commentTextView.text = self.questions[index].valueForKey("comments") as! String
        }else{
              commentTextView.placeholder = "在此处输入评论..."
        }
        commentTextView.delegate = self
        commentTextView.keyboardDismissMode = .OnDrag
        self.totalHeight += 100
        self.scrollView.addSubview(commentTextView)
   
      
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.totalHeight)
    }
    //加载新题目
    func addNewQus(sender:UISwipeGestureRecognizer){
             pickerView.hidden = true
        if sender.direction == .Left{
            if(self.index != self.items.count - 1){
                self.index += 1
                self.initView()
            }else{
                ProgressHUD.showSuccess("已完成评论")
            }
        }
        if sender.direction == .Right{
            if(self.index != 0){
                self.index -= 1
                self.initView()
            }else{
                ProgressHUD.showError("第一大题")
            }
        }
    }
    //初始化视图
    func initView() {
        for view in self.scrollView.subviews{
            view.removeFromSuperview()
        }
        var totalString = self.items[index].valueForKey("content") as! String + "学生答案:" + "<br>"
        if(self.items[index].valueForKey("answer") as? String != nil && self.items[index].valueForKey("answer") as! String != ""){
            totalString += "<pre>" + (self.items[index].valueForKey("answer") as! String)
            + "</pre>"
        }else{
            totalString += "无学生答案"
        }
        self.currentQusLabel.text = "\(self.index + 1)" + "/"  +  "\(self.items.count)"
        self.contentWebView.loadHTMLString(totalString, baseURL: nil)
        
        self.contentWebView.delegate = self
        self.contentWebView.userInteractionEnabled = true
        self.totalHeight = 0
          }
    //评论的按钮 tag要注意
    func gotoPeer(sender:UIButton){
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        let tag = sender.tag
        self.pickerView.tag = 1000 + tag
        self.pickerView.hidden = false
        let arr1 = self.questions[index].valueForKey("rules") as! NSMutableArray
        let dic1 = arr1[tag] as! NSMutableDictionary
       let score = dic1.valueForKey("score") as! NSInteger

        self.pickerView.selectRow(score, inComponent: 0, animated: true)
    }
    //pickerView的一些代理
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
    //pickerView的代理
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
              let tag = pickerView.tag - 1000
       
        for view in self.scrollView.subviews{
            if view.isKindOfClass(UIButton.classForCoder()){
                if(view.tag == tag){
        let btn =  view as! UIButton
                    let scoreString = NSMutableAttributedString(string: "\(row)")
                    let scoreStringRange = NSMakeRange(0, scoreString.length)
                    scoreString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: scoreStringRange)
                    btn.setAttributedTitle(scoreString, forState: .Normal)

            let arr1 = self.questions[index].valueForKey("rules") as! NSMutableArray
                      let dic1 = arr1[tag] as! NSMutableDictionary
                    dic1.setObject(row, forKey: "score")
                    arr1.replaceObjectAtIndex(tag, withObject: dic1)
                self.questions[index].setObject(arr1, forKey: "rules")
                }
            }
        }
     pickerView.hidden = true
    }
    func resign(){
         commentTextView.resignFirstResponder()
        self.pickerView.hidden = true
    }
    func textViewDidEndEditing(textView: UITextView) {
        //改变评论的文本
        self.questions[index].setObject(textView.text, forKey: "comments")
    }
    //键盘出现时的代理
    func keyboardWillHideNotification(notifacition:NSNotification) {
                    self.scrollView.addGestureRecognizer(self.leftSwipe)
        self.scrollView.addGestureRecognizer(self.rightSwipe)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.scrollView.contentOffset = CGPointMake(0, 0)
                 }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        pickerView.hidden = true

        self.scrollView.removeGestureRecognizer(self.leftSwipe)
        self.scrollView.removeGestureRecognizer(self.rightSwipe)
        UIView.animateWithDuration(0.3) { () -> Void in
        self.scrollView.contentOffset = CGPointMake(0, self.aboveCommentTextHeight)
        }
    }
//显示图片放大
    //图片放大的效果
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
    func showBig(sender:UITapGestureRecognizer){
        pickerView.hidden = true
         ShowBigImageFactory.showBigImage(self, webView: self.contentWebView, sender: sender)
    }
    //改变题目
    func changeIndex(sender:UIButton){
        pickerView.hidden = true
        if sender.tag == 2{
            if(self.index != self.items.count - 1){
                self.index += 1
                self.initView()
            }else{
                ProgressHUD.showError("已完成评论")
            }
        }
        if sender.tag == 1{
            if(self.index != 0){
                self.index -= 1
                self.initView()
            }else{
                ProgressHUD.showError("开头")
            }
        }
}
    @IBAction func PickerViewResign(sender: UIControl) {
        pickerView.hidden = true
    }
    
}
