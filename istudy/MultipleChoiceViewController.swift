//
//  MultipleChoiceViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/13.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class MultipleChoiceViewController: UIViewController,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate{
    //阅卷 重置 保存的按钮
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    @IBOutlet weak var goOVerBtn:UIButton?
    @IBOutlet weak var btmView:UIView!
    //阅卷的框
    var resultTextView = UITextView()
 //有没有超过规定的期限
    var isOver = false
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    var tap = UITapGestureRecognizer()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //记录当前是第几个题型 还有总共有几个题型
    var kindOfQusIndex = NSInteger()
    var totalKindOfQus = NSInteger()
    var items = NSArray()
    var totalitems = NSArray()
    var isSave = false
    var testid = NSInteger()
    var qusDesWebView = UIWebView()
    //记录每次wbeView的高度和总高度
    var cellHeights = NSMutableArray()
    var tempArray = ["a","b","c","d","e","f","g","h","i","j"]
    @IBOutlet weak var kindOfQuesLabel:UILabel?
    @IBOutlet weak var currentQus:UILabel?
    @IBOutlet weak var topView:UIView?
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    var totalAnswers = NSMutableArray()
    //临时的答案变量 若保存的话 就替换掉原来的否则就不用进行替换
    var tempString = ""
    var beforeTapString = ""
    @IBOutlet weak var tableView:UITableView?
    var index = 0
    //每道题目选择的答案
    //阅卷的几个数组 保存阅卷的信息 还有阅卷的显示UIView
  
    var displayMarkingArray = NSMutableArray()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加左右的按钮
        //加左右的按钮
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        rightBtn?.addTarget(self, action:  #selector(MultipleChoiceViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        leftBtn!.addTarget(self, action: #selector(MultipleChoiceViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        //设置左右的按钮
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
                //加线
        //顶部加条线
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.topView!)
        

        self.tap = UITapGestureRecognizer(target: self, action: #selector(MultipleChoiceViewController.webViewShowBig(_:)))
        self.tap.delegate = self
        self.qusDesWebView.addGestureRecognizer(tap)
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MultipleChoiceViewController.reloadCellHeight(_:)), name: "ChoiceWebViewHeight", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MultipleChoiceViewController.tap(_:)), name: "choiceTapBtn", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MultipleChoiceViewController.showImage(_:)), name: "ChoiceShowBigImage", object: nil)
       self.tableView?.delegate = self
        self.tableView?.dataSource = self
     //添加点击的通知
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Right
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.tag = 1
        backBtn.addTarget(self, action:#selector(MultipleChoiceViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //提交作业的标示
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.tag = 2
        submitBtn.addTarget(self, action: #selector(MultipleChoiceViewController.back(_:)), forControlEvents: .TouchUpInside)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
      actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action: #selector(MultipleChoiceViewController.actShow), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
            self.automaticallyAdjustsScrollViewInsets = false
        
        //加载从后台返回的我答得答案 若有多个的话 择优&&&符号
        for i in 0 ..< self.items.count{
            
            self.displayMarkingArray.addObject(0)
            if(self.items[i].valueForKey("answer") as? String != nil){
                self.totalAnswers.addObject(self.items[i].valueForKey("answer")!)
            }else{
                self.totalAnswers.addObject("")
            }
        }
        //    //随后这个view加载左滑右滑的手势 来滑动到下一道题目
        let rightSwipe = UISwipeGestureRecognizer(target: self, action:#selector(MultipleChoiceViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MultipleChoiceViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
        self.view.addGestureRecognizer(rightSwipe)
        self.view.addGestureRecognizer(leftSwipe)
        self.view.userInteractionEnabled = true
        self.view.multipleTouchEnabled = true
        self.tableView?.addGestureRecognizer(leftSwipe)
        self.tableView?.addGestureRecognizer(rightSwipe)
        backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        actBtn.setFAIcon(FAType.FABook, iconSize: 25, forState: .Normal)
        goOVerBtn?.setFAText(prefixText: "", icon: FAType.FAPencil, postfixText: "", size: 25, forState: .Normal)
        saveBtn?.setFAText(prefixText: "", icon: FAType.FASave, postfixText: "", size: 25, forState: .Normal)
        resetBtn?.setFAText(prefixText: "", icon: FAType.FAMinusSquare, postfixText: "", size: 25, forState: .Normal)
        self.initView()
         }
 //销毁所有的通知
    deinit{
        print("MutilyDeinit")
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    //到作业列表的跳转
    func actShow() {
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("AchVC") as! AchViewController
        vc.title = self.title
         vc.endDate = self.endDate
        vc.totalItems = self.totalitems
        vc.testid = self.testid
        vc.enableClientJudge = self.enableClientJudge
        vc.keyVisible = self.keyVisible
        vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    //加载新的题目
    func addNewQus(sender:UISwipeGestureRecognizer){
        
        let temp = index
        if sender.direction == .Left{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
            ProgressHUD.showSuccess("已完成全部试题")
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
        if sender.direction == .Right{
            if self.index != 0{
                (self.index) -= 1
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
        //说明发生了滑动 选择题的按钮都要变色
        if temp != index{
            if(!isSave){
                self.totalAnswers[temp] = beforeTapString
            }
            isSave = false
            beforeTapString = ""
            tempString = ""
            self.initView()
          
        }
}
    //重置的动作
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定要重置吗", preferredStyle: UIAlertControllerStyle.Alert)
          let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
        self.totalAnswers.replaceObjectAtIndex(self.index, withObject: "")
            self.tableView?.reloadData()
        
        self.displayMarkingArray.replaceObjectAtIndex(self.index, withObject: 0)
            self.tableView?.tableFooterView = UIView()
            self.saveBtn?.enabled = true
            self.goOVerBtn?.enabled = true
       
         self.postAnswer()
            }
     
        resetAlertView.addAction(resetAction)
         resetAlertView.addAction(cancelAction)
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    
    }
    //阅卷的动作
    @IBAction func goOver(sender:UIButton){
        //确实保存了
        self.isSave = true
       self.displayMarkingArray.replaceObjectAtIndex(index, withObject: 1)
        self.postAnswer()
       }
    //阅卷的动作 会在两部分中用到 一个是一件阅过卷的 还有一个是阅过卷 跳转回来的
      func Over() {
        //没有超过指定的日期且没有开启阅卷功能
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
         //没有超过指定的日期且开启阅卷功能 或者已经超过日期了
        if(!self.isOver && self.enableClientJudge || (self.isOver)){
            //进行阅卷
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
                        if(judgeItems[0].valueForKey("Right") as! Bool == true){
                            totalString += "正确" + "\n"
                            
                        }else{
                            totalString += "错误" + "\n"
                        }
                        totalString += "知识点:"  + (self.items[self.index].valueForKey("knowledge") as! String) + "\n"
                        
                        totalString += "得分:" + "\(judgeItems[0].valueForKey("GotScore") as! NSNumber)"
                            + "/" + "\(judgeItems[0].valueForKey("FullScore") as! NSNumber)" + "\n"
                        
                        if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){                            totalString += "答案:" + (judgeItems[0].valueForKey("Key") as! String)
                        }
                        else{
                            totalString += "标准答案未开放" + "\n"
                            
                        }
                        if(judgeItems[0].valueForKey("Message") as? String != nil && judgeItems[0].valueForKey("Message") as! String != "") {
                            totalString += "信息:" + (judgeItems[0].valueForKey("Message") as! String)
                        }
                        self.resultTextView = UITextView(frame: CGRectMake(10, 0, SCREEN_WIDTH - 20, 200))
                        //设置字体
                        let totalAttriString = NSMutableAttributedString(string: totalString)
                        let range = NSMakeRange(3, 2)
                        if(judgeItems[0].valueForKey("Right") as! Bool == true){
                            totalAttriString.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor(), range: range)
                        }else{
                            totalAttriString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: range)
                        }
                        let length = totalAttriString.length
                        let totalRange = NSMakeRange(0, length)
                        totalAttriString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: totalRange)
                        

                        self.resultTextView.attributedText = totalAttriString
                        self.goOVerBtn?.enabled = false
                        self.saveBtn?.enabled = false
                        self.tableView?.tableFooterView = self.resultTextView
                        //阅卷的界面不可点击
                        self.resultTextView.editable = false

                        self.displayMarkingArray.replaceObjectAtIndex(self.index, withObject: 1)
                   self.tableView?.reloadData()
                    }
                case .Failure(_):
                    ProgressHUD.showError("阅卷失败")
                }
            })
        }
    
}
    //保存的动作
    @IBAction func save(sender:UIButton){
        //确实保存了
        self.isSave = true
     self.postAnswer()

    }
    //向服务器传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.totalAnswers.objectAtIndex(index)]
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
                    
                    //进行阅卷 先保存再阅卷
                    if(self.displayMarkingArray[self.index] as! NSInteger == 1){
                        self.Over()
                    }else{
                    ProgressHUD.showSuccess("保存成功")
                    }
                }
            }
        }

    }
    //初始化界面
    func initView() {
    //加载当前是什么题型和当前是第几题
        self.kindOfQuesLabel?.text = self.totalitems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
        //有没有选择按钮也要进行加载
        //除了按钮外的ABCDlabel选项和每个选项的内容进行加载 根据option某是否存在而进行加载
        
        self.qusDesWebView = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        let contentString = cssDesString + (self.items[index].valueForKey("content") as! String)
        self.qusDesWebView.loadHTMLString(contentString, baseURL: nil)
        self.qusDesWebView.delegate = self
        self.cellHeights.removeAllObjects()
        for i in 0 ..< 8{
            let key = "option" + tempArray[i]
            if(self.items[index].valueForKey(key) as? String != nil && self.items[index].valueForKey(key) as! String != ""){
                cellHeights.addObject(40)
            }
        }
        self.tableView?.reloadData()
        }

    //因为是多选 所以要进行匹配
    func tap(sender:NSNotification){
        //如果现在的答案中有的话就删除掉这个答案 否则就添加进这个答案
        let cell = sender.object as! ChoiceTableViewCell
        let currentTapAnswer = self.tempArray[cell.Custag].uppercaseString
        beforeTapString = self.totalAnswers[index] as! String
        var oneSubAnswerForMutiChoice = self.totalAnswers[index] as! String
     oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByReplacingOccurrencesOfString("&&&", withString: "")
        //遍历字符串 如果有的话 就删除这个否则就加进这个
        if(oneSubAnswerForMutiChoice.containsString(currentTapAnswer)){
            oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByReplacingOccurrencesOfString(currentTapAnswer, withString: "")
        }else{
            oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByAppendingString(currentTapAnswer)
        }
        //随后再进行组装 用与符号来进行拼接
     tempString = ""
        if(oneSubAnswerForMutiChoice.characters.count > 0){
        for i in 0 ..< oneSubAnswerForMutiChoice.characters.count - 1{
            let adv = oneSubAnswerForMutiChoice.startIndex.advancedBy(i)
            tempString.append(oneSubAnswerForMutiChoice[adv])
            tempString = tempString.stringByAppendingString("&&&")
        }
            let adv = oneSubAnswerForMutiChoice.endIndex.predecessor()
            tempString.append(oneSubAnswerForMutiChoice[adv])

        }
      self.totalAnswers[index] = tempString
       self.tableView?.reloadData()
    }
    //webView的代理 等webView加载结束后 进行页面的加载
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
           var frame = webView.frame
         frame.size.height = CGFloat(height!) + 5
         webView.frame = frame
        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
        webView.addGestureRecognizer(tap)
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        let tableHeaderView = UIView(frame:CGRectMake(0,0,SCREEN_WIDTH,frame.size.height + 1))
        let borderView = UIView(frame: CGRectMake(0,frame.size.height,SCREEN_WIDTH,0.3))
        borderView.layer.borderColor = UIColor.grayColor().CGColor
        borderView.layer.borderWidth = 0.3
        tableHeaderView.addSubview(webView)
        tableHeaderView.addSubview(borderView)
        webView.addGestureRecognizer(tap)
        self.tableView?.tableHeaderView = tableHeaderView

        //比较日期 若是已经过了期限 就把阅卷的结果拿出来
        //进行比较
        let currentDate = NSDate()
        self.tableView?.tableFooterView = UIView()
        self.tableView?.userInteractionEnabled = true
        self.goOVerBtn?.enabled = true
        self.saveBtn?.enabled = true
        self.resetBtn?.enabled = true
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            self.isOver = false
            if(self.displayMarkingArray[index] as! NSObject != 0){
                self.Over()
            }else{
                self.tableView?.tableFooterView = UIView()
            }
        }else{
            self.isOver = true
            //每道题目进行阅卷
            self.Over()
            self.goOVerBtn?.enabled = false
            self.resetBtn?.enabled = false
            self.saveBtn?.enabled = false
              self.displayMarkingArray[index] = 1
        }
        self.tableView?.reloadData()
    }
//tableView的一些代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeights.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < cellHeights.count){
            return CGFloat(cellHeights[indexPath.row] as! NSNumber)
        }else{
            return 0
        }
        
    }
    //等tableViewCell加载完全以后 更新cell的高度
    func reloadCellHeight(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
       
        
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
            if(cell.Custag == self.cellHeights.count - 1){
                self.tableView?.reloadData()
            }
    }
    }
    //每一个cell的内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = ChoiceTableViewCell(style: .Default, reuseIdentifier: "ChoiceTableViewCell")
        if(indexPath.row < cellHeights.count){
            let key = "option" + tempArray[indexPath.row]
            let optionContentString = cssOptionString + (self.items[index].valueForKey(key) as! String)
            cell.optionWebView?.loadHTMLString(optionContentString, baseURL: nil)
            cell.selectionStyle = .None
            cell.contentView.userInteractionEnabled = true
            cell.Custag = indexPath.row
            let optionString = tempArray[indexPath.row].uppercaseString + "."
            cell.btn?.setTitle(optionString, forState: .Normal)
            let oneSelfAnswer = self.totalAnswers[index] as! String
            cell.btn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
            cell.canTap = true
            if(self.displayMarkingArray[index] as! NSInteger != 0){
                cell.canTap = false
            }
            //多选题 如果包含这个字符就变色
            if(oneSelfAnswer.containsString(tempArray[indexPath.row].uppercaseString)){
               
                
                cell.btn?.setTitleColor(RGB(0, g: 153, b: 255), forState: .Normal)
            }
            
        }
        return cell
    }
    //手势添加放大和缩小
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
  ShowBigImageFactory.showBigImage(self, webView: self.qusDesWebView, sender: sender)
    }
    //cell里面的showImage
    func showImage(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("showBigVC") as! ImageShowBigViewController
        vc.url = cell.url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    //按钮左右的滑动
    func changeIndex(sender:UIButton){
        let temp = index
        if sender.tag == 2{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
              ProgressHUD.showSuccess("已完成全部试题")
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
        if sender.tag == 1{
            if self.index != 0{
                (self.index) -= 1
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
        //说明发生了滑动 选择题的按钮都要变色
        if temp != index{
            if(!isSave){
                self.totalAnswers[temp] = beforeTapString
            }
            isSave = false
            beforeTapString = ""
            tempString = ""
            self.initView()
            
        }
}
}
