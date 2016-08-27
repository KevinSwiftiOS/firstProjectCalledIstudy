//
//  CompletionQusViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/16.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class CompletionQusViewController: UIViewController,UITextFieldDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate{
    //手势
    var rightSwap = UISwipeGestureRecognizer()
    var leftSwap = UISwipeGestureRecognizer()
    //有没有超过指定日期
    var isOver = false
    //阅卷 重置 保存的按钮
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    @IBOutlet weak var goOVerBtn:UIButton?
    //阅卷的结果
    var resultTextView = UITextView()
    //记录tableViewheader的高度在键盘出现的时候会用到
    var tableHeaderWebViewHeight:CGFloat = 0.0
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var tap = UITapGestureRecognizer()
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    var kindOfQusIndex = NSInteger()
    var totalKindOfQus = NSInteger()
    var items = NSArray()
    //记录tableView的高度 在键盘出现的时候有用
    var frame = CGRect()
    //记录题目的类型 如果是程序填空题的话 阅卷的时候是提交到后台进行编译 否则就是直接保存
    var type = ""
    var totalitems = NSArray()
    var cellHeights = NSMutableArray()
   var oneSubFillBlankSelfAnswerArray = NSMutableArray()
    @IBOutlet weak var tableView:UITableView?
    var displayMarkingArray = NSMutableArray()
    var totalAnswerArray = NSMutableArray()
    var queDes = UIWebView()
    //记录题目的高度
    //试卷的id 
    var testid = NSInteger()
    @IBOutlet weak var currentQus:UILabel?
    @IBOutlet weak var qusScore:UILabel?
    @IBOutlet weak var topView:UIView?
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    @IBOutlet weak var btmView:UIView!
    var standAnswers = NSMutableArray()
    var beforeEditString = ""
    var isSave = Bool()
    //为了避免出现 点击view的时候 键盘不消失
    //自己的回答
    var oneQusAnswers = NSMutableArray()
    //当前在第几道题目 总共有几道题目
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加左右的按钮
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        rightBtn?.addTarget(self, action: #selector(CompletionQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        leftBtn!.addTarget(self, action: #selector(CompletionQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        //设置左右的按钮
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
              //顶部加条线
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.topView!)
        

        self.tap = UITapGestureRecognizer(target: self, action: #selector(CompletionQusViewController.webViewShowBig(_:)))
        self.tap.delegate = self
        self.qusScore?.addGestureRecognizer(self.tap)
        self.frame = (self.tableView?.frame)!
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompletionQusViewController.completionHeight(_:)), name: "CompletionWebViewHeight", object: nil)
        //获得自己填的答案的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CompletionQusViewController.AssembleCompletionAnswer(_:)), name: "CompletionAnswer", object: nil)
      self.tableView?.delegate = self
        self.tableView?.dataSource = self
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        backBtn.contentHorizontalAlignment = .Left
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action:   #selector(CompletionQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        backBtn.tag = 1
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.tag = 2
        submitBtn.addTarget(self, action: #selector(CompletionQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action: #selector(CompletionQusViewController.actShow), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
        backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        actBtn.setFAIcon(FAType.FABook, iconSize: 25, forState: .Normal)
          goOVerBtn?.setFAText(prefixText: "", icon: FAType.FAPencil, postfixText: "", size: 25, forState: .Normal)
        saveBtn?.setFAText(prefixText: "", icon: FAType.FASave, postfixText: "", size: 25, forState: .Normal)
        resetBtn?.setFAText(prefixText: "", icon: FAType.FAMinusSquare, postfixText: "", size: 25, forState: .Normal)

        self.queDes = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        self.queDes.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        //这个页面增加手势
        rightSwap = UISwipeGestureRecognizer(target: self, action: #selector(CompletionQusViewController.addNewQus(_:)))
        rightSwap.direction = .Right
        self.view.addGestureRecognizer(rightSwap)
         leftSwap = UISwipeGestureRecognizer(target: self, action: #selector(CompletionQusViewController.addNewQus(_:)))
        leftSwap.direction = .Left
        self.view.addGestureRecognizer(leftSwap)
        self.tableView?.addGestureRecognizer(leftSwap)
        self.tableView?.addGestureRecognizer(rightSwap)
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        self.totalAnswerArray.removeAllObjects()
        for i in 0 ..< self.items.count{
            self.displayMarkingArray.addObject(0)
            if(self.items[i].valueForKey("answer") as? String != nil && self.items[i].valueForKey("answer") as! String != "") {
                self.totalAnswerArray.addObject(self.items[i].valueForKey("answer") as! String)
            }else{
                self.totalAnswerArray.addObject("")
                
            }
        }
        //题目增加手势 使点击题目的时候键盘消失
     self.initView()
       
    }
    //移除所有通知
    deinit{
        print("CompletDeinit")
          NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   //到作业题目的列表
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
   //进行保存的动作
    @IBAction func save(sender:UIButton){
        self.Save()
      }
    //保存
    func Save() {
        var answerString = ""
        for i in 0 ..< self.oneSubFillBlankSelfAnswerArray.count - 1{
            
            answerString += (self.oneSubFillBlankSelfAnswerArray[i] as! String + "&&&")
        }
        answerString += self.oneSubFillBlankSelfAnswerArray[self.oneSubFillBlankSelfAnswerArray.count - 1] as! String
        self.totalAnswerArray.replaceObjectAtIndex(index, withObject: answerString)
        self.postAnswer()

    }
    //向服务器传送答案
    func postAnswer() {
        
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.totalAnswerArray.objectAtIndex(index)]
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
                    if(self.displayMarkingArray[self.index] as! NSInteger == 1){
                        self.Over()
                    }else{
                    ProgressHUD.showSuccess("保存成功")
                }
                }
            }
        }

    }
    //重置的动作 阅卷的displayMarkingArray代替为0
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定要重置吗", preferredStyle: UIAlertControllerStyle.Alert)
          let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
        self.totalAnswerArray.replaceObjectAtIndex(self.index, withObject: "")
       self.initView()
       
    self.displayMarkingArray.replaceObjectAtIndex(self.index, withObject: 0)
            self.tableView?.tableFooterView = UIView()
            self.goOVerBtn?.enabled = true
            self.saveBtn?.enabled = true
            self.tableView?.reloadData()
         self.postAnswer()
        }
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    //阅卷的动作
    func Over() {
       
        //没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
        //如果没有超过指定日期且可以阅卷或者已经超过日期的
        if(!self.isOver && self.enableClientJudge || (self.isOver)){
            let userDefault = NSUserDefaults.standardUserDefaults()
            let authtoken = userDefault.valueForKey("authtoken") as! String
            let paramDic = ["authtoken":authtoken,
                            "testid":"\(self.testid)",
                            "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)"
                ]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/judgequestion", parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .Success(let Value):
                    let json = JSON(Value)
                    if(json["info"]["Success"].bool != true){
                        ProgressHUD.showError("阅卷失败")
                        print(json["ErrorMessage"].string)
                    }
                    else{
                        let judgeItems = json["info"]["JudgeResultItemSet"].arrayObject! as NSArray
                        var totalString = "答案:"
                //设置红绿字的范围
                let rangeArray = NSMutableArray()
                for i in 0 ..< judgeItems.count{
                let range = NSMakeRange(3 + i * 3,2)
                rangeArray.addObject(range)
                        if(judgeItems[i].valueForKey("Right") as! Bool == true){
                            totalString += "正确" + " "
                            
                        }else{
                            totalString += "错误" + " "
                        }
                }
                //加载知识点
                totalString += "\n" + "知识点:" + (self.items[self.index].valueForKey("knowledge") as! String) + "\n"
                //再加得分
                        totalString += "得分:"
                        for i in 0 ..< judgeItems.count{
                            totalString += "\(judgeItems[i].valueForKey("GotScore") as! NSNumber)" + "/" + "\(judgeItems[i].valueForKey("FullScore") as! NSNumber)" + " "
                        }
                        
                        //随后再加载标准答案
                        
                        if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){
                        totalString += "\n" + "答案:"
                        for i in 0 ..< judgeItems.count{
                            totalString += (judgeItems[i].valueForKey("Key") as! String) + "\n"
                        }
                        }else{
                            totalString += "\n" + "标准答案未开放"
                        }
              let totalAttriString = NSMutableAttributedString(string: totalString)
                    //设置颜色
                        for i in 0 ..< rangeArray.count{
                            let range = rangeArray[i] as! NSRange
                            if(judgeItems[i].valueForKey("Right") as! Bool == true){
                                totalAttriString.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor(), range: range)
                            }else{
                                totalAttriString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: range)
                            }
   
                        }
                self.resultTextView = UITextView(frame: CGRectMake(10, 0, SCREEN_WIDTH - 20, 200))
                        let length = totalAttriString.length
                        let totalRange = NSMakeRange(0, length)
                        totalAttriString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: totalRange)
                        

                        self.resultTextView.attributedText = totalAttriString
                        self.tableView?.tableFooterView = self.resultTextView
                        //阅卷的界面不可点击
                        self.resultTextView.editable = false
  
                        self.displayMarkingArray.replaceObjectAtIndex(self.index, withObject: 1)
                        self.goOVerBtn?.enabled = false
                        self.saveBtn?.enabled = false
                    self.tableView?.reloadData()
                    }
                case .Failure(_):
                ProgressHUD.showError("阅卷失败")
                }
                })
      }
    }

    //阅卷与保存的功能
    @IBAction func goOver(sender:UIButton){
      
      
        if(!isOver && self.enableClientJudge){
        //组装答案后进行post
        var answerString = ""
        for i in 0 ..< self.oneSubFillBlankSelfAnswerArray.count - 1{
            
            answerString += (self.oneSubFillBlankSelfAnswerArray[i] as! String + "&&&")
        }
        answerString += self.oneSubFillBlankSelfAnswerArray[self.oneSubFillBlankSelfAnswerArray.count - 1] as! String
        self.totalAnswerArray.replaceObjectAtIndex(index, withObject: answerString)
            self.displayMarkingArray.replaceObjectAtIndex(index, withObject: 1)
       self.postAnswer()
            
        }
        
        
    }
    //加载新题目
       func addNewQus(sender:UISwipeGestureRecognizer){
        let temp = index
        if sender.direction == .Left{
            if index != self.items.count - 1{
                index += 1
            }
            else if self.totalKindOfQus - 1 == self.kindOfQusIndex{
                ProgressHUD.showSuccess("已完成全部试题")
            }else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                 vc.title = self.title
                vc.kindOfQusIndex = self.kindOfQusIndex + 1
                vc.testid = self.testid
                 vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        if sender.direction == .Right{
            if index != 0{
                index -= 1
            }else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                 vc.title = self.title
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.testid = self.testid
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                 vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                              self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        if(temp != index){
                       self.initView()
            self.currentQus?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
            self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
            
        }
    }
    //初始化界面
    //拆分组装标准答案 就有几个cell
    func initView(){
        self.tableHeaderWebViewHeight = 0
        self.currentQus?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
        self.qusScore?.text = self.totalitems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
     let contentString = cssDesString + (self.items[index].valueForKey("content") as! String)
        self.queDes.loadHTMLString(contentString,
                                   baseURL: nil)
        self.queDes.delegate = self
        //总共有几个答案 分割字符串
        self.standAnswers.removeAllObjects()
        self.cellHeights.removeAllObjects()
        self.oneSubFillBlankSelfAnswerArray.removeAllObjects()
     
        var standAnswer = self.items[index].valueForKey("strandanswer") as! String
        standAnswer = standAnswer.stringByReplacingOccurrencesOfString("&&&", withString: "☺︎")
        var tempString = ""
        for i in 0 ..< standAnswer.characters.count{
            let index = standAnswer.startIndex.advancedBy(i)
            if(standAnswer[index] == "☺︎"){
                self.cellHeights.addObject(30)
                self.standAnswers.addObject(tempString)
                self.oneSubFillBlankSelfAnswerArray.addObject("")
                tempString = ""
            }else{
                tempString.append(standAnswer[index])
            }
            
        }
        self.cellHeights.addObject(30)
        self.standAnswers.addObject(tempString)
        self.oneSubFillBlankSelfAnswerArray.addObject("")
    }
    
 //键盘的两个通知
    func keyboardWillHideNotification(notification:NSNotification){
        self.tableView?.addGestureRecognizer(self.leftSwap)
        self.tableView?.addGestureRecognizer(rightSwap)
        UIView.animateWithDuration(0.3) {
            
         
            self.tableView?.frame = CGRectMake(0, 64 + 21 + 2, SCREEN_WIDTH, SCREEN_HEIGHT * 0.6)
        }
    }
    //在show以后 要进行键盘高度的计算 来计算出tableView的高度
    func keyboardWillShowNotification(notification:NSNotification){
        self.tableView?.removeGestureRecognizer(leftSwap)
        self.tableView?.removeGestureRecognizer(rightSwap)
       let rect = XKeyBoard.returnKeyBoardWindow(notification)
         self.tableHeaderWebViewHeight = self.queDes.frame.size.height
        //记录tablView总共的高度
        var totalTableViewHeight = self.tableHeaderWebViewHeight
        for i in 0 ..< self.cellHeights.count{
            totalTableViewHeight += CGFloat(self.cellHeights[i] as! NSNumber)
        }
     UIView.animateWithDuration(0.3) {
        if(SCREEN_HEIGHT - totalTableViewHeight - rect.height <= 64){
        self.tableView?.frame = CGRectMake(0, SCREEN_HEIGHT - totalTableViewHeight - rect.height, SCREEN_WIDTH, totalTableViewHeight)
        }
        else{
        self.tableView?.tableFooterView = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT - totalTableViewHeight - rect.height))
        self.tableView?.tableFooterView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CompletionQusViewController.resign as (CompletionQusViewController) -> () -> ())))
        }
        }
    }
    //消失键盘
    func resign() {
        for i in 0 ..< self.cellHeights.count{
            let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? CompletionTableViewCell
            if(cell != nil){
        cell!.textField?.resignFirstResponder()
            }
        }
    }
    //webView的代理操作
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        var NewFrame = webView.frame
              NewFrame.size.height = CGFloat(height!) + 5
        webView.frame = NewFrame
        let scrollView = webView.subviews[0] as! UIScrollView
      scrollView.showsVerticalScrollIndicator = false
       let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
       
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
       self.saveBtn?.enabled = true
        self.goOVerBtn?.enabled = true
        self.resetBtn?.enabled = true
        self.tableView?.tableHeaderView = self.queDes
        self.tableView?.tableFooterView = UIView()
        //比较日期 若是已经过了期限 就把阅卷的结果拿出来
        //进行比较
        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            
            if(self.displayMarkingArray[index] as! NSObject != 0){
                self.isOver = false
                self.Over()
            self.goOVerBtn?.enabled = false
            self.saveBtn?.enabled = false
            }else{
                self.tableView?.tableFooterView = UIView()
            }
            
        }else{
            
            self.isOver = true
            //每道题目进行阅卷
            self.Over()
            self.resetBtn?.enabled = false
            self.goOVerBtn?.enabled = false
            self.saveBtn?.enabled = false
            self.displayMarkingArray[index] = 1
            
        }
        webView.addGestureRecognizer(tap)
      self.tableView?.reloadData()
    
    }
    //tableView的一些代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = CompletionTableViewCell(style: .Default, reuseIdentifier: "CompletionTableViewCell")
        if(indexPath.row < self.cellHeights.count){
            //加载有没有提醒 就是blank
            let key = "blank" + "\(indexPath.row + 1)"
            if(self.items[index].valueForKey(key) as? String != nil && self.items[index].valueForKey(key) as! String != ""){
                let optionContentString = cssOptionString + (self.items[index].valueForKey(key) as! String)
                cell.webView?.loadHTMLString(optionContentString, baseURL: nil)
            }else{
                cell.webView?.loadHTMLString("", baseURL: nil)
            }
            //填空题的分割
            
            cell.Custag = indexPath.row
            var oneSubQusSelfAnswer = self.totalAnswerArray[index] as! String
            //分割字符串
            
            //分割自己的答案
            oneSubQusSelfAnswer = oneSubQusSelfAnswer.stringByReplacingOccurrencesOfString("&&&", withString: "☺︎")
            var tempString = ""
            var temp = oneSubQusSelfAnswer.characters.count - 1
            
            var tempIndex = oneSubFillBlankSelfAnswerArray.count - 1
            while temp >= 0 {
                let adv = oneSubQusSelfAnswer.startIndex.advancedBy(temp)
                if(oneSubQusSelfAnswer[adv] == "☺︎"){
                    //逆序一下字符串
                    var inReverse = ""
                    for letter in tempString.characters{
                        inReverse = "\(letter)" + inReverse
                    }
                    oneSubFillBlankSelfAnswerArray.replaceObjectAtIndex(tempIndex, withObject: inReverse)
                    tempIndex -= 1
                    tempString = ""
                    temp -= 1
                }else{
                    temp -= 1
                    tempString.append(oneSubQusSelfAnswer[adv])
                }
            }
            var inReverse = ""
            for letter in tempString.characters{
                inReverse = "\(letter)" + inReverse
            }
            oneSubFillBlankSelfAnswerArray.replaceObjectAtIndex(tempIndex, withObject: inReverse)
            
            cell.selfAnswer = (oneSubFillBlankSelfAnswerArray[indexPath.row] as? String)!
            //是否可以编辑
            cell.canEdit = true
            if(self.displayMarkingArray[index] as! NSObject != 0){
                cell.canEdit = false
            }
            cell.selectionStyle = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeights.count
    }
    //键盘高度的整合
    func completionHeight(sender:NSNotification){
    //    var frame = self.tableView?.frame
        let cell = sender.object as! CompletionTableViewCell
        //要看总共有多少个输入框
        if(cell.Custag < cellHeights.count){
            
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
            self.tableView?.beginUpdates()
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
                       
        self.tableView?.endUpdates()
        }
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < cellHeights.count){
            return CGFloat(cellHeights[indexPath.row] as! NSNumber)
        }else{
            return 0
        }
    }
    //组装答案
    //进行填空题答案的组装
    func AssembleCompletionAnswer(sender:NSNotification) {
        let cell = sender.object as! CompletionTableViewCell
        
        self.oneSubFillBlankSelfAnswerArray.replaceObjectAtIndex(cell.Custag, withObject: (cell.textField?.text)!)
       
    }
    //图片的放大
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
  ShowBigImageFactory.showBigImage(self, webView: self.queDes, sender: sender)
            }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    //左右按钮的滑动
    func changeIndex(sender:UIButton){
    //左右的滑动
    let temp = index
    if sender.tag == 2{
    if index != self.items.count - 1{
    index += 1
    }
    else if self.totalKindOfQus - 1 == self.kindOfQusIndex{
    ProgressHUD.showSuccess("已完成全部试题")
    }else{
    let vc = UIStoryboard(name: "Problem", bundle: nil)
    .instantiateViewControllerWithIdentifier("TranslateVC") as!
    TranslateViewController
    vc.title = self.title
    vc.kindOfQusIndex = self.kindOfQusIndex + 1
    vc.testid = self.testid
    vc.endDate = self.endDate
    vc.enableClientJudge = self.enableClientJudge
    vc.keyVisible = self.keyVisible
    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
    self.navigationController?.pushViewController(vc, animated: false)
    }
    }
    if sender.tag == 1{
    if index != 0{
    index -= 1
    }else{
    let vc = UIStoryboard(name: "Problem", bundle: nil)
    .instantiateViewControllerWithIdentifier("TranslateVC") as!
    TranslateViewController
    vc.title = self.title
    vc.kindOfQusIndex = self.kindOfQusIndex
    vc.testid = self.testid
    vc.enableClientJudge = self.enableClientJudge
    vc.keyVisible = self.keyVisible
    vc.endDate = self.endDate
    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
    self.navigationController?.pushViewController(vc, animated: false)
    }
    }
    if(temp != index){
    self.initView()
    self.currentQus?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
    self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
    
    }
}
}