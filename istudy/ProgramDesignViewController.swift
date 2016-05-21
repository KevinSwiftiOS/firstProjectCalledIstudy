//
//  ProgramDesignViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/24.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ProgramDesignViewController: UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate{
    var kindOfQusIndex = NSInteger()
    var totalKindOfQus = NSInteger()
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    var tap = UITapGestureRecognizer()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
//问题

    @IBOutlet weak var contentScrollView:UIScrollView?
    @IBOutlet weak var kindOfQusLabel:UILabel?
    @IBOutlet weak var currentQusLabel:UILabel?
    //记录是程序改错题还是程序设计题 如果是程序改错题 那么还有默认的回答的内容的初始化
    var type = ""
    //文本输入框
    var answerTextView:JVFloatLabeledTextView?
    var qusDesWebView = UIWebView()
    var items = NSArray()
    var totalitems = NSArray()
    var testid = NSInteger()
    var selfAnswers = NSMutableArray()
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    @IBOutlet weak var topView:UIView?
    //记录webView的高度
    var webViewHeight:CGFloat = 0
    //记录当前是第几题
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //顶部加条线
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

        self.automaticallyAdjustsScrollViewInsets = false
        self.tap = UITapGestureRecognizer(target: self, action: #selector(ProgramDesignViewController.webViewShowBig(_:)))
        self.tap.delegate = self
        
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Left
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action:  #selector(ProgramDesignViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        backBtn.tag = 1
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.tag = 2
        submitBtn.addTarget(self, action: #selector(ProgramDesignViewController.back(_:)), forControlEvents: .TouchUpInside)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action: #selector(ProgramDesignViewController.actShow), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
       self.qusDesWebView = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ProgramDesignViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ProgramDesignViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.qusDesWebView.delegate = self
        //先自己答案装进来
        for i in 0 ..< self.items.count{
            if(self.items[i].valueForKey("answer") as? String != nil && self.items[i].valueForKey("answer") as! String != ""){
                self.selfAnswers.addObject(self.items[i].valueForKey("answer") as! String)
            }else{
                self.selfAnswers.addObject("")
            }
        }
        self.initView()
        //注册键盘出现的时候
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        //键盘消失 scrollView加手势
        self.contentScrollView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgramDesignViewController.resign as (ProgramDesignViewController) -> () -> ())))
        // Do any additional setup after loading the view.
        
        self.initView()

    }
   
    func actShow() {
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("AchVC") as! AchViewController
        vc.title = self.title
        vc.totalItems = self.totalitems
        vc.testid = self.testid
        vc.enableClientJudge = self.enableClientJudge
        vc.keyVisible = self.keyVisible
         vc.endDate = self.endDate
        vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //返回试卷列表或者根视图
    func back(sender:UIButton) {
        
        if(sender.tag == 1) {
            let vc = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
            
            for temp in (self.navigationController?.viewControllers)!{
                if(temp .isKindOfClass(vc.classForCoder)){
                    self.navigationController?.popToViewController(temp, animated: true)
                }
            }
        }else{
            let alertView = UIAlertController(title: nil, message: "确认提交吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
            let submitAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (alert) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alertView.addAction(submitAction)
            alertView.addAction(cancelAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addNewQus(sender:UISwipeGestureRecognizer){
        let temp = index
        if(sender.direction == .Left){
            if(index != self.items.count - 1){
                index += 1
            }
            else if self.kindOfQusIndex == self.totalKindOfQus - 1{
                ProgressHUD.showSuccess("已完成全部")
            }else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.kindOfQusIndex = self.kindOfQusIndex + 1
                vc.testid = self.testid
                 vc.title = self.title
                 vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                               self.navigationController?.pushViewController(vc, animated: false)

            }
        }
        if(sender.direction == .Right){
            if(index != 0){
                index -= 1
            }else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.testid = self.testid
                 vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                 vc.title = self.title
                               self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        if(temp != index){
            self.initView()
        }
    }
    func initView() {
        for view in (self.contentScrollView?.subviews)!{
            view.removeFromSuperview()
        }
        
        self.kindOfQusLabel?.text = self.totalitems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQusLabel?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
        self.qusDesWebView.loadHTMLString(self.items[index].valueForKey("content") as! String, baseURL: nil)
        
    }
    //保存的动作 和阅卷时的动作是一样的 应该程序题都是可以阅卷的
    @IBAction func save(sender:UIButton){
        let text = self.answerTextView?.text
        self.selfAnswers.replaceObjectAtIndex(index, withObject: text!)
        self.postAnswer()
    }
    //重置的动作
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            if(self.type == "PROGRAM_DESIGN"){
                self.answerTextView?.text = ""
            }
            if self.type == "PROGRAM_CORRECT"{
                self.answerTextView?.text = self.items[self.index].valueForKey("defaultanswer") as! String
            }
            self.selfAnswers.replaceObjectAtIndex(self.index, withObject: "")
            self.postAnswer()

        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
        //也要判断类型
           }
    //初始化答案
    func initAnswer() {
        self.answerTextView = JVFloatLabeledTextView(frame: CGRectMake(10, webViewHeight, SCREEN_WIDTH - 20, 100))
        self.contentScrollView?.addSubview(self.answerTextView!)
        //设置自己的回答
        if(self.type == "PROGRAM_DESIGN"){
        self.answerTextView?.text = self.selfAnswers[index] as! String
        }
        if(self.type == "PROGRAM_CORRECT"){
            if(self.selfAnswers[index] as! String != ""){
                   self.answerTextView?.text = self.selfAnswers[index] as! String
            }else{
                 self.answerTextView?.text = self.items[index].valueForKey("defaultanswer") as! String
            }
        }
        self.contentScrollView?.contentSize = CGSizeMake(SCREEN_WIDTH, webViewHeight + 100)
        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            
        }else{
            
           
            //每道题目进行阅卷
            self.answerTextView?.editable = false
            self.answerTextView?.userInteractionEnabled = false
                        self.resetBtn?.userInteractionEnabled = false
            self.saveBtn?.userInteractionEnabled = false
            let label = UILabel(frame: CGRectMake(0,webViewHeight + 110,SCREEN_WIDTH,30))
            label.text = "标准答案:"
            let standAnswerTextView = UITextView(frame: CGRectMake(0, webViewHeight + 140, SCREEN_WIDTH, 100))
            //在截止日期后是否开启开放标准答案的工呢过
            standAnswerTextView.layer.borderWidth = 1.0
            if(self.viewOneWithAnswerKey){
            standAnswerTextView.text = self.items[index].valueForKey("strandanswer") as! String
            }else{
                   standAnswerTextView.text = "未开放标准答案"
            }
            self.contentScrollView?.addSubview(label)
            self.contentScrollView?.addSubview(standAnswerTextView)
            self.contentScrollView?.contentSize = CGSizeMake(SCREEN_WIDTH, webViewHeight + 110 + 30 + 100)
        }

    }
    //传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.selfAnswers.objectAtIndex(index)]
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(answer, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        let parameter:[String:AnyObject] = ["authtoken":authtoken,"data":result]
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/submitquestion", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                print(1)
                ProgressHUD.showError("保存失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number! != 0){
                    ProgressHUD.showError("保存失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("保存成功")
                }
            }
        }
        
    }

    func webViewDidStartLoad(webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 1
        webView.frame = frame
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        //计算题目描述的高度 随后自动进行匹配
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
      
        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
        
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        var frame = webView.frame
        frame.size.height = CGFloat(height!) + 5
        webView.frame = frame
        self.webViewHeight = CGFloat(height!) + 15
        webView.addGestureRecognizer(tap)
        self.contentScrollView?.addSubview(webView)
      self.initAnswer()
        
    }
    //键盘出现和消失时的动作
    func keyboardWillHideNotification(notification:NSNotification){
         self.contentScrollView?.contentOffset = CGPointMake(0, 0)
        self.answerTextView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func keyboardWillShowNotification(notification:NSNotification){
        self.contentScrollView?.contentOffset = CGPointMake(0, webViewHeight)
       // let rect = XKeyBoard.returnKeyBoardWindow(notification)
       
        
    }
    @IBAction func resign(sender: UIControl) {
        self.answerTextView?.resignFirstResponder()
    }
    func resign() {
        self.answerTextView?.resignFirstResponder()
    }
    //图片放大时候的动作
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

    func webViewShowBig(sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
      
            pt = sender.locationInView(self.qusDesWebView)
            let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
            urlToSave = self.qusDesWebView.stringByEvaluatingJavaScriptFromString(imgUrl)!
        
        
        let data = NSData(contentsOfURL: NSURL(string: urlToSave)!)
        print(data)
        if(data != nil){
            let image = UIImage(data: data!)
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = [image!]
            previewPhotoVC.contentOffsetX = 0
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    }
    deinit{
        print("ProgreamDeint")
    }
    }
