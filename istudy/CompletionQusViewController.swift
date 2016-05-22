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
    //阅卷的内容
    var displayMarkingView:UIView?
    @IBOutlet weak var tableView:UITableView?
    var disPlayMarkingArray = NSMutableArray()
    var totalAnswerArray = NSMutableArray()
    var queDes = UIWebView()
    //记录题目的高度
    //试卷的id 
    var testid = NSInteger()
    @IBOutlet weak var currentQus:UILabel?
    @IBOutlet weak var qusScore:UILabel?
    @IBOutlet weak var topView:UIView?
    var standAnswers = NSMutableArray()
    var beforeEditString = ""
    //为了避免出现 点击view的时候 键盘不消失
    //自己的回答
    var oneQusAnswers = NSMutableArray()
    //当前在第几道题目 总共有几道题目
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //顶部加条线
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

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
            self.disPlayMarkingArray.addObject("")
            if(self.items[i].valueForKey("answer") as? String != nil && self.items[i].valueForKey("answer") as! String != "") {
                self.totalAnswerArray.addObject(self.items[i].valueForKey("answer") as! String)
            }else{
                self.totalAnswerArray.addObject("")
                
            }
        }
        self.displayMarkingView?.hidden = true
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

    //当键盘出现的时候
    @IBAction func resign(sender: UIControl) {
    
    }
    
    @IBAction func save(sender:UIButton){
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
                    ProgressHUD.showSuccess("保存成功")
                }
            }
        }

    }
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定要重置吗", preferredStyle: UIAlertControllerStyle.Alert)
          let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
        
        self.totalAnswerArray.replaceObjectAtIndex(self.index, withObject: "")
        self.initView()
        
        self.displayMarkingView?.hidden = true
        self.disPlayMarkingArray.replaceObjectAtIndex(self.index, withObject: "")
            self.tableView?.reloadData()
        self.postAnswer()
        }
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    func Over(index:NSInteger) {
       
        //没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
        //如果没有超过指定日期且可以阅卷或者已经超过日期的
        if(!self.isOver && self.enableClientJudge || (self.isOver)){

        self.displayMarkingView = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,100))
        let trueOrFalseArray = NSMutableArray()
        trueOrFalseArray.removeAllObjects()
        let tempCompareStringArray = NSMutableArray()
        
        for i in 0 ..< self.standAnswers.count{
            tempCompareStringArray.removeAllObjects()
            trueOrFalseArray.addObject("0")
            var myAnswer = (self.oneSubFillBlankSelfAnswerArray[i] as! String)
            //myAnswer要把空格拿掉
            myAnswer = myAnswer.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            var standAnswer = self.standAnswers[i] as! String
            standAnswer = standAnswer.stringByReplacingOccurrencesOfString("|||", withString: "☺︎")
            //比较字符串
            var tempString = ""
            for temp in 0 ..< standAnswer.characters.count{
                let index = standAnswer.startIndex.advancedBy(temp)
                if(standAnswer[index] == "☺︎"){
                    
                    tempCompareStringArray.addObject(tempString)
                    tempString = ""
                }else{
                    tempString.append(standAnswer[index])
                }
            }
            tempCompareStringArray.addObject(tempString)
            for tempIndex in 0 ..< tempCompareStringArray.count{
                if myAnswer == (tempCompareStringArray[tempIndex] as! String){
                    trueOrFalseArray.replaceObjectAtIndex(i, withObject: "1")
                }
                
            }
        }
        for view in (self.displayMarkingView?.subviews)!{
            view.removeFromSuperview()
        }
        let knowledge = "知识点: " + (self.items[index].valueForKey("knowledge") as! String) + "\n"
        let knowLedgeLabel = UILabel(frame: CGRectMake(0,0,SCREEN_WIDTH,21))
        knowLedgeLabel.text = knowledge
        var totalStandAnswerString = "参考答案:" + "\n"
        let standAnswerTextView = UITextView(frame: CGRectMake(0, 21 * 3, SCREEN_WIDTH, 35))
        for i in 0 ..< self.standAnswers.count{
            totalStandAnswerString += self.standAnswers[i] as! String + "\n"
        }
            //没有超过日期并且可以查看标准答案的 或者超过日期了 但是可以查看标准答案的
            if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){
        standAnswerTextView.text = totalStandAnswerString
            }else{
                standAnswerTextView.text = ""
            }
        var count = 0
        var totalString = ""
        for i in 0 ..< trueOrFalseArray.count{
            let trueOrFalseLabel = UILabel(frame: CGRectMake(CGFloat((i+1) * 42) + 5,21,42,21))
            if(trueOrFalseArray[i] as! String == "1"){
                count += 1
                totalString += "1"
                trueOrFalseLabel.text = "正确"
                trueOrFalseLabel.textColor = UIColor.greenColor()
            }else{
                totalString += "0"
                trueOrFalseLabel.text = "错误"
                trueOrFalseLabel.textColor = UIColor.redColor()
            }
            self.displayMarkingView?.addSubview(trueOrFalseLabel)
        }
        let resultLabel = UILabel(frame: CGRectMake(0,21,42,21))
        resultLabel.text = "结果:"
        self.disPlayMarkingArray.replaceObjectAtIndex(index, withObject: totalString)
        
        let scoreLabel = UILabel(frame: CGRectMake(0,21 * 2,SCREEN_WIDTH,21))
        let score = CGFloat(count) / CGFloat(trueOrFalseArray.count) * CGFloat((self.items[index].valueForKey("totalscore") as! NSNumber))
        scoreLabel.text = "得分" + "\(score)"
        self.displayMarkingView?.hidden = false
        
        self.displayMarkingView?.addSubview(knowLedgeLabel)
        self.displayMarkingView?.addSubview(resultLabel)
        self.displayMarkingView?.addSubview(scoreLabel)
        self.displayMarkingView?.addSubview(standAnswerTextView)
        self.tableView?.tableFooterView = self.displayMarkingView
        self.tableView?.reloadData()
        }
    }

    //阅卷与重做的功能
    @IBAction func goOver(sender:UIButton){
      
        self.Over(self.index)
        if(!isOver && self.enableClientJudge){
        //组装答案后进行post
        var answerString = ""
        for i in 0 ..< self.oneSubFillBlankSelfAnswerArray.count - 1{
            
            answerString += (self.oneSubFillBlankSelfAnswerArray[i] as! String + "&&&")
        }
        answerString += self.oneSubFillBlankSelfAnswerArray[self.oneSubFillBlankSelfAnswerArray.count - 1] as! String
        self.totalAnswerArray.replaceObjectAtIndex(index, withObject: answerString)
    self.postAnswer()
        }
        
        
    }
       func addNewQus(sender:UISwipeGestureRecognizer){
        let temp = index
        if sender.direction == .Left{
            if index != self.items.count - 1{
                index += 1
            }
            else if self.totalKindOfQus - 1 == self.kindOfQusIndex{
                ProgressHUD.showSuccess("已经完成全部试题")
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
                self.navigationController?.pushViewController(vc, animated: true)
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
            if(self.disPlayMarkingArray[index] as! String != ""){
                displayMarkingView = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT))
                for view in (self.displayMarkingView?.subviews)!{
                    view.removeFromSuperview()
                }
                let knowledge = "知识点: " + (self.items[index].valueForKey("knowledge") as! String) + "\n"
                let knowLedgeLabel = UILabel(frame: CGRectMake(0,0,SCREEN_WIDTH,21))
                knowLedgeLabel.text = knowledge
                var totalStandAnswerString = "参考答案:" + "\n"
                let standAnswerTextView = UITextView(frame: CGRectMake(0, 21 * 3, SCREEN_WIDTH, 35))
                for i in 0 ..< self.standAnswers.count{
                    totalStandAnswerString += self.standAnswers[i] as! String + "\n"
                }
                standAnswerTextView.text = totalStandAnswerString
                var count = 0
                let string = self.disPlayMarkingArray[index] as! String
                for i in 0 ..< string.characters.count{
                    let trueOrFalseLabel = UILabel(frame: CGRectMake(CGFloat((i + 1) * 42) + 5,21,42,21))
                    let tempIndex = string.startIndex.advancedBy(i)
                    if(string[tempIndex] == "1"){
                        count += 1
                        trueOrFalseLabel.text = "正确"
                        trueOrFalseLabel.textColor = UIColor.greenColor()
                    }else{
                        trueOrFalseLabel.text = "错误"
                        trueOrFalseLabel.textColor = UIColor.redColor()
                    }
                    self.displayMarkingView?.addSubview(trueOrFalseLabel)
                }
                
                let resultLabel = UILabel(frame: CGRectMake(0,21,42,21))
                resultLabel.text = "结果:"
                self.displayMarkingView?.hidden = false
                let scoreLabel = UILabel(frame: CGRectMake(0,21 * 2,SCREEN_WIDTH,21))
                let score = CGFloat(count) / CGFloat(self.standAnswers.count) * CGFloat((self.items[index].valueForKey("totalscore") as! NSNumber))
                scoreLabel.text = "得分" + "\(score)"
                self.displayMarkingView?.addSubview(knowLedgeLabel)
                self.displayMarkingView?.addSubview(resultLabel)
                self.displayMarkingView?.addSubview(scoreLabel)
                self.displayMarkingView?.addSubview(standAnswerTextView)
               
                self.tableView?.tableFooterView = self.displayMarkingView
            }else{
                
              self.tableView?.tableFooterView = nil
            }
        }
    }
    //初始化界面
    func initView(){
        self.tableHeaderWebViewHeight = 0
        self.currentQus?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
        self.qusScore?.text = self.totalitems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
     
        self.queDes.loadHTMLString(self.items[index].valueForKey("content") as! String,
                                   baseURL: nil)
        self.queDes.delegate = self
        self.tableView?.tableHeaderView = self.queDes
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
        self.tableView?.reloadData()
        //比较日期 若是已经过了期限 就把阅卷的结果拿出来
        //进行比较
        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            
        }else{
          
             self.isOver = true
            //每道题目进行阅卷
            self.Over(index)
            self.resetBtn?.enabled = false
            self.goOVerBtn?.enabled = false
            self.saveBtn?.enabled = false
          
        }

    }
    
 //键盘的两个通知
    func keyboardWillHideNotification(notification:NSNotification){
        self.tableView?.addGestureRecognizer(self.leftSwap)
        self.tableView?.addGestureRecognizer(rightSwap)
        UIView.animateWithDuration(0.3) {
            
         
            self.tableView?.frame = CGRectMake(0, 64 + 21 + 2, SCREEN_WIDTH, SCREEN_HEIGHT * 0.6)
        }
    }
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
    func resign() {
        for i in 0 ..< self.cellHeights.count{
            let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? CompletionTableViewCell
            if(cell != nil){
        cell!.textField?.resignFirstResponder()
            }
        }
    }
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
       
        self.tableView?.tableHeaderView = webView
        webView.addGestureRecognizer(tap)
        if(self.disPlayMarkingArray[index] as! String == ""){
            self.tableView?.tableFooterView = UIView()
        }
        webView.stopLoading()
    
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = CompletionTableViewCell(style: .Default, reuseIdentifier: "CompletionTableViewCell")
        if(indexPath.row < self.cellHeights.count){
            //加载有没有提醒 就是blank
            let key = "blank" + "\(indexPath.row + 1)"
            if(self.items[index].valueForKey(key) as? String != nil && self.items[index].valueForKey(key) as! String != ""){
                cell.webView?.loadHTMLString(self.items[index].valueForKey(key) as! String, baseURL: nil)
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
            if(self.disPlayMarkingArray[index] as! String != ""){
                cell.canEdit = false
            }
            cell.selectionStyle = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeights.count
    }
    func completionHeight(sender:NSNotification){
    //    var frame = self.tableView?.frame
        let cell = sender.object as! CompletionTableViewCell
        //要看总共有多少个输入框
        if(cell.Custag < cellHeights.count){
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
//            if(cell.Custag != self.cellHeights.count - 1){
//                frame?.origin.y = -100
//                self.tableView?.frame = frame!
//            }else{
//                frame?.origin.y = 21 + 64 + 3
//                self.tableView?.frame = frame!
//            }
            self.tableView?.reloadData()
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
        
        pt = sender.locationInView(self.queDes)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.queDes.stringByEvaluatingJavaScriptFromString(imgUrl)!
        
        
        let data = NSData(contentsOfURL: NSURL(string: urlToSave)!)
       
        if(data != nil){
            let image = UIImage(data: data!)
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = [image!]
            previewPhotoVC.contentOffsetX = 0
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    }
}