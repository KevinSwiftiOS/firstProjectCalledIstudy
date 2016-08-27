//
//  ComplexQusViewController.swift
//  istudy
//
//  Created by hznucai on 16/5/1.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class ComplexQusViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIWebViewDelegate,UIGestureRecognizerDelegate{
    //几个手势 为了键盘的bug
    //每个题目的范围 
    var everySubQusRange = NSMutableArray()
    //小题目的左右手势 为了加载题目
    var subUpSwipe = UISwipeGestureRecognizer()
    var subDownSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    var leftSwipe = UISwipeGestureRecognizer()
    var tap = UITapGestureRecognizer()
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    var subWebView = UIWebView()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //当前是第几种类型的题目
    var testid = NSInteger()
    //已经超过期限了
    var isSave = false
    var beforeEditing = ""
    var isOver = false
    var kindOfQusIndex = 0
    var totalKindOfQus = 0
    //阅卷的记录文字的数组
    var disPlayMarkTextArray = NSMutableArray()
    var resultTextView = UITextView()
    @IBOutlet weak var btmView:UIView!
    //题目描述的webView
    @IBOutlet weak var qusDesWebView:UIWebView?
    //承载小题的题目描述和每个小题的内容
    @IBOutlet weak var tableView:UITableView!
    //大题目这是到第几题了 和现在的题型
    @IBOutlet weak var kindOfQusLabel:UILabel?
    @IBOutlet weak var currentQusLabel:UILabel?
    //小题目现在是到第几题了 和现在的题型
    @IBOutlet weak var kindofSubQusLabel:UILabel?
    @IBOutlet weak var currentSubQusLabel:UILabel?
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    //阅卷 重置 保存的按钮
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    @IBOutlet weak var goOVerBtn:UIButton?
    @IBOutlet weak var subTopView:UIView?
    @IBOutlet weak var topView:UIView?
    var totalItems = NSArray()
    //大题目
    var items = NSArray()
    //小题目
    var subQusItems = NSMutableArray()
    //整个大题目是到第几题
    var index = 0
    //小题目到第几题
    var subIndex = 0
    //标准答案
    var subQusStandAnswer = NSMutableArray()
    //每个大题目的总共的标准答案
    var totalBigSelfAnswers = NSMutableArray()
    //一个大题目的每个小题目的答案
    var oneQusSubSelfAnswers = NSMutableArray()
    //每一个cell的高度
    var cellHeights = NSMutableArray()
    //填空题的话记录每道小题的答案
    var oneSubFillBlankSelfAnswerArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加左右的按钮
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        rightBtn?.addTarget(self, action: #selector(ComplexQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        leftBtn!.addTarget(self, action: #selector(ComplexQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        //设置左右的按钮
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
      //  self.tableView.keyboardDismissMode = .OnDrag
        //顶部加条线
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.topView!)
        
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.subTopView!)
        self.tap = UITapGestureRecognizer(target: self, action: #selector(ComplexQusViewController.webViewShowBig(_:)))
        tap.delegate = self
        self.qusDesWebView?.addGestureRecognizer(tap)
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        
        self.totalKindOfQus = self.totalItems.count - 1
        //查看现在已经做了几题了
        //contentView添加手势
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Left
        backBtn.tag = 1
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action: #selector(ComplexQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        //查看的btn
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action:#selector(ComplexQusViewController.showAct), forControlEvents: .TouchUpInside)
        //还有提交作业的btn
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.tag = 2
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.addTarget(self, action: #selector(ComplexQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComplexQusViewController.noti(_:)), name: "ComplexChoicewebViewHeight", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComplexQusViewController.completionHeight(_:)), name: "ComplexCompletionwebViewHeight", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ComplexQusViewController.tap(_:)), name: "ComplexTapBtn", object: nil)
        //获得自己填的答案的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ComplexQusViewController.AssembleCompletionAnswer(_:)), name: "ComplexCompletionAnswer", object: nil)
        //图片的预览放大
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ComplexQusViewController.showImage(_:)), name: "ComplexShowBigImage", object: nil)
        self.totalKindOfQus = self.totalItems.count
        //加载每道大题目的答案
        for i in 0 ..< self.items.count{
            if(self.items[i].valueForKey("answer") as? String != nil && self.items[i].valueForKey("answer") as! String != ""){
                self.totalBigSelfAnswers.addObject(self.items[i].valueForKey("answer") as! String)
            }else{
                self.totalBigSelfAnswers.addObject("")
            }
        }
        self.subQusItems = self.items[index].valueForKey("subquestions") as! NSMutableArray
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        // self.tableView.estimatedRowHeight = 88
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        subUpSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ComplexQusViewController.addNewSubQus(_:)))
        subUpSwipe.direction = .Left
        subDownSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ComplexQusViewController.addNewSubQus(_:)))
        subDownSwipe.direction = .Right
        self.tableView.addGestureRecognizer(subDownSwipe)
        self.tableView.userInteractionEnabled = true
        self.tableView.addGestureRecognizer(subUpSwipe)
        leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(ComplexQusViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ComplexQusViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
        self.qusDesWebView?.userInteractionEnabled = true
        self.qusDesWebView?.addGestureRecognizer(leftSwipe)
        self.qusDesWebView?.addGestureRecognizer(rightSwipe)
        self.automaticallyAdjustsScrollViewInsets = false
        self.initView()
        backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        actBtn.setFAIcon(FAType.FABook, iconSize: 25, forState: .Normal)
        goOVerBtn?.setFATitleColor(UIColor.blackColor())
        goOVerBtn?.setFAText(prefixText: "", icon: FAType.FAPencil, postfixText: "", size: 25, forState: .Normal)
        saveBtn?.setFAIcon(FAType.FASave, iconSize: 25, forState: .Normal)
        resetBtn?.setFAText(prefixText: "", icon: FAType.FAMinusSquare, postfixText: "", size: 25, forState: .Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //通用的回去按钮
    func showAct(){
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("AchVC") as! AchViewController
        vc.title = self.title
        vc.totalItems = self.totalItems
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
    //加载大题目的view
    func initView() {
        //初始化界面
        let contentString = cssDesString + (self.items[index].valueForKey("content") as! String)
        self.qusDesWebView?.loadHTMLString(contentString, baseURL: nil)
        self.subQusStandAnswer.removeAllObjects()
        
        //小题目的初始化
        self.subQusItems = self.items[index].valueForKey("subquestions") as! NSMutableArray
        for i in 0 ..< self.subQusItems.count{
            //初始化答案
            self.subQusStandAnswer.addObject(self.subQusItems[i].valueForKey("strandanswer") as! String)
            
        }
        self.kindOfQusLabel?.text = self.totalItems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQusLabel?.text = "\(self.index + 1)" + "/" + "\(self.items.count)"
        //小题目的默认为第一题
        self.subIndex = 0
        //每一道大题目的范围给他拿掉
        self.everySubQusRange.removeAllObjects()
        //初始化自己答案
        self.oneQusSubSelfAnswers.removeAllObjects()
        //阅卷的文字
        self.disPlayMarkTextArray.removeAllObjects()
        //总共有几个多少个自己的答案
        for _ in 0 ..< self.subQusItems.count{
            self.oneQusSubSelfAnswers.addObject("")
            self.disPlayMarkTextArray.addObject("")
        }
        var oneBigSelfAnswer = self.totalBigSelfAnswers[index] as! String
        //分割字符串
        oneBigSelfAnswer = oneBigSelfAnswer.stringByReplacingOccurrencesOfString("~~~", withString: "☺︎")
        //分割大题目的字符串 逆序的反转 真不知道他们是怎么组装的
        var temp = oneBigSelfAnswer.characters.count - 1
        var tempIndex = self.oneQusSubSelfAnswers.count - 1
        var tempString = ""
        while temp >= 0 {
            let adv = oneBigSelfAnswer.startIndex.advancedBy(temp)
            if(oneBigSelfAnswer[adv] == "☺︎"){
                //逆序一下字符串
                var inReverse = ""
                for letter in tempString.characters{
                    inReverse = "\(letter)" + inReverse
                }
                self.oneQusSubSelfAnswers.replaceObjectAtIndex(tempIndex, withObject: inReverse)
                tempIndex -= 1
                tempString = ""
                temp -= 1
            }else{
                temp -= 1
                tempString.append(oneBigSelfAnswer[adv])
            }
        }
        //最后也要进行替换
        var inReverse = ""
        for letter in tempString.characters{
            inReverse = "\(letter)" + inReverse
        }
        self.oneQusSubSelfAnswers.replaceObjectAtIndex(tempIndex, withObject: inReverse)
        //初始化subView
        self.subIndex = 0
        self.initSubView()
        //分割字符串就是这样
    }
    //每个subwebview的高度
    var subWebViewHeight:CGFloat = 0.0
    func initSubView() {
        self.tableView.keyboardDismissMode = .OnDrag
        //初始化小题的内容
        switch self.subQusItems[subIndex].valueForKey("type") as! String {
        case "SINGLE_CHIOCE":
            self.kindofSubQusLabel?.text = "选择题" + "(" + "\(self.subQusItems[subIndex].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        case "MULIT_CHIOCE":
            self.kindofSubQusLabel?.text = "多选题" + "(" + "\(self.subQusItems[subIndex].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        case "FILL_BLANK":
            self.kindofSubQusLabel?.text = "填空题" + "(" + "\(self.subQusItems[subIndex].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        case "JUDGE":
            self.kindofSubQusLabel?.text = "判断题" + "(" + "\(self.subQusItems[subIndex].valueForKey("totalscore") as! NSNumber)" + "分/题)"
            
        default:
            break
            
        }
   
        
        self.currentSubQusLabel?.text = "\(self.subIndex + 1)" + "/" + "\(self.subQusItems.count)"
        //tableView的headerView 小题目的描述
        subWebView = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        self.tableView.tableHeaderView = subWebView
        subWebView.delegate = self
        subWebView.loadHTMLString(self.subQusItems[subIndex].valueForKey("content") as! String, baseURL: nil)
        //初始化tableView总共有几格
        self.cellHeights.removeAllObjects()
        //判断是选择题 还是 填空题
        self.oneSubFillBlankSelfAnswerArray.removeAllObjects()
        if(self.subQusItems[subIndex].valueForKey("type") as! String != "FILL_BLANK"){
            //判断这时这个数组有没有在
            if(self.everySubQusRange.count <= subIndex){
            self.everySubQusRange.addObject(1)
            }
            for i in 0 ..< tempOptionArray.count{
                let key = "option" + tempOptionArray[i]
                if(self.subQusItems[subIndex].valueForKey(key) as? String != nil
                    && self.subQusItems[subIndex].valueForKey(key) as! String != ""){
                    
                    cellHeights.addObject(50)
                }
            }
            
        }else{
            
            //分割填空题的标准答案的字符串
            var oneFillBlankStandAnswer = self.subQusItems[subIndex].valueForKey("strandanswer") as! String
            oneFillBlankStandAnswer = oneFillBlankStandAnswer.stringByReplacingOccurrencesOfString("&&&", withString: "☺︎")
            for i in 0 ..< oneFillBlankStandAnswer.characters.count{
                let adv = oneFillBlankStandAnswer.startIndex.advancedBy(i)
                if(oneFillBlankStandAnswer[adv] == "☺︎"){
                    
                    cellHeights.addObject(40)
                    oneSubFillBlankSelfAnswerArray.addObject("")
                }
            }
            oneSubFillBlankSelfAnswerArray.addObject("")
            cellHeights.addObject(40)
            if(self.everySubQusRange.count <= subIndex){
            
         self.everySubQusRange.addObject(self.cellHeights.count)
            }
        }
         beforeEditing = self.oneQusSubSelfAnswers[subIndex] as! String
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        //是否已经阅过卷
        if(!isOver){
            if(self.disPlayMarkTextArray[subIndex] as! String != ""){
              self.Over()
                
            }
            else{
                self.tableView.tableFooterView = UIView()
            }
            

        self.tableView.reloadData()
        }
    }
    //滑动题目的内容来加载新的大题目
    func addNewQus(sender:UISwipeGestureRecognizer){
        let temp = index
        if sender.direction == .Left{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
               ProgressHUD.showSuccess("已完成全部试题")
            }
            else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.kindOfQusIndex = self.kindOfQusIndex + 1
                vc.title = self.title
                vc.testid = self.testid
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
                vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        //说明发生了滑动 选择题的按钮都要变色
        if temp != index{
            self.initView()
            
        }
    }
    //tablView加左滑右滑的手势来加载新的小题目
    func addNewSubQus(sender:UISwipeGestureRecognizer) {
        
        //阅卷的问题
        
        if(sender.direction == .Left){
            //判断是不是到最后一题
            if(self.subIndex == self.subQusItems.count - 1){
                let temp = self.index
                //手势加载下一道大题目
                //判断大题目有没有加载完
                if self.index != self.items.count - 1{
                    self.index += 1
                }
                else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
                 ProgressHUD.showSuccess("已完成全部试题")
                }
                else{
                    let vc = UIStoryboard(name: "Problem", bundle: nil)
                        .instantiateViewControllerWithIdentifier("TranslateVC") as!
                    TranslateViewController
                    vc.kindOfQusIndex = self.kindOfQusIndex + 1
                    vc.title = self.title
                    vc.testid = self.testid
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                if(temp != index){
                    self.initView()
                }
                
            }else{
                if(!isSave){
                    self.oneQusSubSelfAnswers[subIndex] = beforeEditing
                }
                
                isSave = false
                self.subIndex += 1
                self.initSubView()
            }
        }
        if(sender.direction == .Right){
            if(self.subIndex == 0){
                let temp = self.index
                if self.index != 0{
                    (self.index) -= 1
                }else{
                    
                    let vc = UIStoryboard(name: "Problem", bundle: nil)
                        .instantiateViewControllerWithIdentifier("TranslateVC") as!
                    TranslateViewController
                    vc.title = self.title
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.testid = self.testid
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                if(temp != index){
                    self.initView()
                }
                
            }else{
                if(!isSave){
                    self.oneQusSubSelfAnswers[subIndex] = beforeEditing
                    
                }
                isSave = false
                self.subIndex -= 1
                self.initSubView()
                
            }
        }
        
    }
    //webView的代理 等webView代理完成才进行tableView的刷新
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
        
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        self.resetBtn?.enabled = true
        self.goOVerBtn?.enabled = true
        self.saveBtn?.enabled = true
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        self.subWebViewHeight = CGFloat(height!) + 5
        var frame = webView.frame
        frame.size.height = self.subWebViewHeight
        webView.frame = frame
        webView.addGestureRecognizer(tap)
        self.tableView.tableHeaderView = webView
                let currentDate = NSDate()
                let result:NSComparisonResult = currentDate.compare(endDate)
                if result == .OrderedAscending{
                     isOver = false
                    if(self.disPlayMarkTextArray[subIndex] as! NSObject != ""){
                        self.Over()
                        self.saveBtn?.enabled = false
                        self.goOVerBtn?.enabled = false
                      
                    }
                }else{
                    self.disPlayMarkTextArray[subIndex] = "1"
                    isOver = true
                    self.resetBtn?.enabled = false
                    self.goOVerBtn?.enabled = false
                    self.saveBtn?.enabled = false
                    //每道题目进行阅卷
                    self.Over()
                }
        
        self.tableView.reloadData()
    }
    //tableView的代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    let tempOptionArray = ["a","b","c","d","e","f","g","h","i"]
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeights.count
    }
    //cell要进行不同的判断 填空题时就加载textField 选择题时就加载webView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //进行拆分每道题目的答案
        var oneQusSelfAnswer = self.oneQusSubSelfAnswers[subIndex] as! String
        //判断是不是空的字符串 随后判断是填空题 还是选择题
        oneQusSelfAnswer = oneQusSelfAnswer.stringByReplacingOccurrencesOfString("&&&", withString: "☺︎")
        //随后分割字符串
        if(self.subQusItems[subIndex].valueForKey("type") as! String != "FILL_BLANK"){
            //随后进行遍历 和自己答案有相同的就涂色
            
            let cell = ComplexChoiceTableViewCell(style: .Subtitle, reuseIdentifier: "ChoiceTableCell")
            if(indexPath.row < self.cellHeights.count){
                
                cell.contentView.userInteractionEnabled = true
                let key = "option" + tempOptionArray[indexPath.row]
                if(self.subQusItems[subIndex].valueForKey(key) as? String != nil &&
                    self.subQusItems[subIndex].valueForKey(key) as! String != ""){
                    let optionContentString = cssOptionString + (self.subQusItems[subIndex].valueForKey(key) as! String)
                    cell.optionWebView?.loadHTMLString(optionContentString, baseURL: nil)
                    cell.Custag = indexPath.row
                    let optionString = tempOptionArray[indexPath.row].uppercaseString + "."
                    cell.btn?.setTitle(optionString, forState: .Normal)
                    
                    //随后拿出自己的答案 无论是多选题 还是单选题 只要有这个字符 就设置背景色
                    let oneSubQusSelfAnswer = self.oneQusSubSelfAnswers[subIndex] as! String
                 
                    cell.btn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    for i in 0 ..< oneSubQusSelfAnswer.characters.count{
                        let adv = oneSubQusSelfAnswer.startIndex.advancedBy(i)
                        var compareString = ""
                        compareString.append(oneSubQusSelfAnswer[adv])
                        if(compareString == tempOptionArray[indexPath.row].uppercaseString){
                           
                            cell.btn?.setTitleColor(RGB(0, g: 153, b: 255), forState: .Normal)                        }
                    }
                }
                cell.canTap = true
                if(self.disPlayMarkTextArray[subIndex] as! String != ""){
                    
                    cell.canTap = false
                }
                cell.selectionStyle = .None
                
            }
            return cell
            
        }
        else{
            let cell = ComplexCompletionTableViewCell(style: .Default, reuseIdentifier: "CompletionTableCell")
            if(indexPath.row < self.cellHeights.count){
                //加载有没有提醒 就是blank
                let key = "blank" + "\(indexPath.row + 1)"
                if(self.subQusItems[subIndex].valueForKey(key) as? String != nil && self.subQusItems[subIndex].valueForKey(key) as! String != ""){
                    let optionContentString = cssOptionString + (self.subQusItems[subIndex].valueForKey(key) as! String)
                    cell.webView?.loadHTMLString(optionContentString, baseURL: nil)
                }else{
                    cell.webView?.loadHTMLString("", baseURL: nil)
                }
                //填空题的分割
                
                cell.Custag = indexPath.row
                var oneSubQusSelfAnswer = self.oneQusSubSelfAnswers[subIndex] as! String
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
                cell.canEdit = true
                cell.selfAnswer = (oneSubFillBlankSelfAnswerArray[indexPath.row] as? String)!
                if(self.disPlayMarkTextArray[subIndex] as! String != ""){
                    cell.canEdit = false
                }
                cell.selectionStyle = .None
            }
            return cell
        }
        
    }
    //当选中了某个cell的时候 判断是单选题还是多选题 填空题是不可选择的
    func tap(sender:NSNotification){
        //判断是多选题还是单选题 来进行不同的组装即可
        //如果是单选题的话
        //要看有没有按下保存键
        beforeEditing = self.oneQusSubSelfAnswers[subIndex] as! String
        let cell = sender.object as! ComplexChoiceTableViewCell
        if(self.subQusItems[subIndex].valueForKey("type") as! String != "MULIT_CHIOCE"){
            self.oneQusSubSelfAnswers[subIndex] = tempOptionArray[cell.Custag].uppercaseString
            
        }else{
            //如果现在的答案中有的话就删除掉这个答案 否则就添加进这个答案
            let currentTapAnswer = self.tempOptionArray[cell.Custag].uppercaseString
            var oneSubAnswerForMutiChoice = self.oneQusSubSelfAnswers[subIndex] as! String
            oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByReplacingOccurrencesOfString("&&&", withString: "")
            //遍历字符串 如果有的话 就删除这个否则就加进这个
            if(oneSubAnswerForMutiChoice.containsString(currentTapAnswer)){
                oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByReplacingOccurrencesOfString(currentTapAnswer, withString: "")
            }else{
                oneSubAnswerForMutiChoice = oneSubAnswerForMutiChoice.stringByAppendingString(currentTapAnswer)
            }
            //随后再进行组装 用与符号来进行拼接
            var tempString = ""
            if(oneSubAnswerForMutiChoice.characters.count > 0){
                for i in 0 ..< oneSubAnswerForMutiChoice.characters.count - 1{
                    let adv = oneSubAnswerForMutiChoice.startIndex.advancedBy(i)
                    tempString.append(oneSubAnswerForMutiChoice[adv])
                    tempString = tempString.stringByAppendingString("&&&")
                }
                let adv = oneSubAnswerForMutiChoice.endIndex.predecessor()
                tempString.append(oneSubAnswerForMutiChoice[adv])
            }
            self.oneQusSubSelfAnswers[subIndex] = tempString
        }
        self.tableView.reloadData()
    }
    //    //每个tableViewCell的高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < self.cellHeights.count){
            return CGFloat(cellHeights[indexPath.row] as! NSNumber)
        }else{
            return 0
        }
    }
    //
    //保存着一道题目的小题目的所有答案
    @IBAction func save(sender:UIButton){
      self.save()
    }
    func save() {
        isSave = true
        //组装字符串 变成~~~的形式
        var answerString = ""
        for i in 0 ..< self.oneQusSubSelfAnswers.count - 1{
            
            answerString += (oneQusSubSelfAnswers[i] as! String + "~~~")
        }
        
        answerString += oneQusSubSelfAnswers[oneQusSubSelfAnswers.count - 1] as! String
        self.totalBigSelfAnswers.replaceObjectAtIndex(index, withObject: answerString)
        self.postAnswer()
        }
    //向服务器传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.totalBigSelfAnswers.objectAtIndex(index)]
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(answer, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        
        
        //设置15秒
        
        
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
                   
                    if(self.disPlayMarkTextArray[self.subIndex] as? String != ""){
                        self.Over()
                    }else{
                        ProgressHUD.showSuccess("保存成功")
                    }
                }
            }
        }
        
    }
    
    func noti(sender:NSNotification){
        let cell = sender.object as! ComplexChoiceTableViewCell
        self.view.bringSubviewToFront(self.subTopView!)
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
   
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
            if(cell.Custag == self.cellHeights.count - 1){
                self.tableView?.reloadData()
            }
            if(cell.Custag == self.cellHeights.count - 1){
//                let y = 64 + 21 + 4 + SCREEN_HEIGHT * 0.4 + 21 + 5 + 21 + 21
//                self.tableView.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - y)
                //阅卷的
                if(self.disPlayMarkTextArray[subIndex] as! String != ""){
                    self.Over()
                }else{
                    self.tableView.tableFooterView = UIView()
                }
                      }
           
        }
    }
    
    
    func completionHeight(sender:NSNotification){
        
               let cell = sender.object as! ComplexCompletionTableViewCell
        //要看总共有多少个输入框
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
            //   var frame = self.tableView.frame
            
        //    self.subTableViewToTop.constant = -100
            if(cell.Custag == self.cellHeights.count - 1){
                self.subTableViewToTop.constant = 0
//                let y = 64 + 21 + 4 + SCREEN_HEIGHT * 0.4 + 21 + 5 + 21 + 21
//                self.tableView.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - y)
                
            }
                
self.tableView.beginUpdates()
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
                  self.view.setNeedsLayout()
           self.tableView.endUpdates()
        }
    }
    
    
    //在析构消失的时候必须除去所有通知
    deinit{
        print("ComplexDeinit")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    @IBOutlet weak var subTableViewToTop: NSLayoutConstraint!
    func keyboardWillShowNotification(notifacition:NSNotification) {
        self.tableView.tableFooterView = UIView()
        //解除手势
        self.tableView.removeGestureRecognizer(subUpSwipe)
        self.tableView.removeGestureRecognizer(subDownSwipe)
        self.qusDesWebView?.removeGestureRecognizer(rightSwipe)
        self.qusDesWebView?.removeGestureRecognizer(leftSwipe)
        let webViewforTableViewTotalHeight = NSInteger(self.subWebView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        var totalTableViewHeight:CGFloat = CGFloat(webViewforTableViewTotalHeight!)
        
        for i in 0 ..< self.cellHeights.count{
            totalTableViewHeight += CGFloat(self.cellHeights[i] as! NSNumber)
        }
        
        let rect = XKeyBoard.returnKeyBoardWindow(notifacition)
            //记录tablView总共的高度
    
        for i in 0 ..< self.cellHeights.count{
            totalTableViewHeight += CGFloat(self.cellHeights[i] as! NSNumber)
        }
        UIView.animateWithDuration(0.3) {
         self.subTableViewToTop.constant = -(SCREEN_HEIGHT * 0.4) - 42
            self.view.bringSubviewToFront(self.tableView)
            self.view.bringSubviewToFront(self.subTopView!)
        }
    }
    //键盘出现的时候的代理
    func keyboardWillHideNotification(notifacition:NSNotification) {
        self.tableView.addGestureRecognizer(subUpSwipe)
        self.tableView.userInteractionEnabled = true
        self.tableView.addGestureRecognizer(subDownSwipe)
        self.qusDesWebView?.addGestureRecognizer(leftSwipe)
        self.qusDesWebView?.addGestureRecognizer(rightSwipe)
        UIView.animateWithDuration(0.3) {
            self.subTableViewToTop.constant = 0
            
            self.view.setNeedsLayout()
            
        }
        
    }
    //消失键盘的代理
    func resign() {
        for i in 0 ..< self.cellHeights.count{
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? ComplexCompletionTableViewCell
            if(cell != nil){
                cell!.textField?.resignFirstResponder()
            }
            
        }
    }
    //进行填空题答案的组装
    func AssembleCompletionAnswer(sender:NSNotification) {
        let cell = sender.object as! ComplexCompletionTableViewCell
          beforeEditing = self.oneQusSubSelfAnswers[subIndex] as! String
        self.oneSubFillBlankSelfAnswerArray.replaceObjectAtIndex(cell.Custag, withObject: (cell.textField?.text)!)
        var answerString = ""
        for i in 0 ..< self.oneSubFillBlankSelfAnswerArray.count - 1{
            
            answerString += (oneSubFillBlankSelfAnswerArray[i] as! String + "&&&")
        }
        
        answerString += oneSubFillBlankSelfAnswerArray[oneSubFillBlankSelfAnswerArray.count - 1] as! String
        self.oneQusSubSelfAnswers.replaceObjectAtIndex(subIndex, withObject: answerString)
        
        //拼装答案
    }
    //重置的按钮
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
            
            self.disPlayMarkTextArray.replaceObjectAtIndex(self.subIndex, withObject: "")
            
            self.oneQusSubSelfAnswers.replaceObjectAtIndex(self.subIndex, withObject: "")
            self.tableView.tableFooterView = nil
            self.initSubView()
            self.saveBtn?.enabled = true
            self.goOVerBtn?.enabled = true
            self.save()
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    //阅卷
    @IBAction func goOver(sender:UIButton){
       // 没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
        else{
     self.disPlayMarkTextArray.replaceObjectAtIndex(subIndex, withObject: "1")
        self.save()
        }
    }
    //阅卷的功能
    func Over() {
       // 没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
        //如果没有超过指定日期且可以阅卷或者已经超过日期的
        if(!self.isOver && self.enableClientJudge || (self.isOver)){
        
     
       
         
        switch self.subQusItems[subIndex].valueForKey("type") as! String{
        case "JUDGE","SINGLE_CHIOCE","MULIT_CHIOCE":
            self.choiceOver()
        case "FILL_BLANK":
    self.filLBlankOver()
    default:
            break
        }
        }
    }
    func choiceOver() {
        //进行过滤和遍历 还要加多少
        var startRange = 0
        var endRange = 0
        for i in 0 ..< self.subIndex{
            startRange += self.everySubQusRange[i] as! NSInteger
        }
   endRange += startRange + (self.everySubQusRange[subIndex] as! NSInteger)
    //    print(self.items[index].valueForKey("id"))
        //没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
        //如果没有超过指定日期且可以阅卷或者已经超过日期的
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
                        if(judgeItems[startRange].valueForKey("Right") as! Bool == true){
                            totalString += "正确" + "\n"
                            
                        }else{
                            totalString += "错误" + "\n"
                        }
                        totalString += "知识点:"  + (self.items[self.index].valueForKey("knowledge") as! String) + "\n"
                        
                        totalString += "得分:" + "\(judgeItems[startRange].valueForKey("GotScore") as! NSNumber)"
                            + "/" + "\(judgeItems[startRange].valueForKey("FullScore") as! NSNumber)" + "\n"
                        
                        if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){                            totalString += "答案:" + (judgeItems[startRange].valueForKey("Key") as! String)
                        }
                        else{
                            totalString += "标准答案未开放" + "\n"
                            
                        }
                        if(judgeItems[startRange].valueForKey("Message") as? String != nil && judgeItems[startRange].valueForKey("Message") as! String != "") {
                            totalString += "信息:" + (judgeItems[startRange].valueForKey("Message") as! String)
                        }
                        self.resultTextView = UITextView(frame: CGRectMake(10, 0, SCREEN_WIDTH - 20, 200))
                        //设置字体
                        let totalAttriString = NSMutableAttributedString(string: totalString)
                        let range = NSMakeRange(3, 2)
                        if(judgeItems[startRange].valueForKey("Right") as! Bool == true){
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
                        self.disPlayMarkTextArray.replaceObjectAtIndex(self.subIndex, withObject: "1")
                        self.tableView.reloadData()
                    }
                case .Failure(_):
                    ProgressHUD.showError("阅卷失败")
                }
            })
        }
    }
    func filLBlankOver() {
        //进行过滤和遍历 还要加多少
        var startRange = 0
        var endRange = 0
      
        for i in 0 ..< self.subIndex{
            startRange += self.everySubQusRange[i] as! NSInteger
        }
   endRange += startRange + (self.everySubQusRange[subIndex] as! NSInteger)
//没有超过指定日期且没有开放阅卷功能的
//        if(!self.isOver && !self.enableClientJudge){
//            ProgressHUD.showError("没有开启阅卷功能")
//        }
        //如果没有超过指定日期且可以阅卷或者已经超过日期的
  //      if(!self.isOver && self.enableClientJudge || (self.isOver)){
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
                        for i in startRange ..< endRange{
                            let range = NSMakeRange(3 + (i - startRange) * 3,2)
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
                        for i in startRange ..< endRange{
                            totalString += "\(judgeItems[i].valueForKey("GotScore") as! NSNumber)" + "/" + "\(judgeItems[i].valueForKey("FullScore") as! NSNumber)" + " "
                        }
                        //随后再加载标准答案
                                             //查看标准答案是否已经开放
                          if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){
                            totalString += "\n" + "答案:"

                        for i in startRange ..< endRange{
                            totalString += (judgeItems[i].valueForKey("Key") as! String) + "\n"
                        }
                          }else{
                            totalString += "\n" + "标准答案未开放"
                        }
                        let totalAttriString = NSMutableAttributedString(string: totalString)
                        //设置颜色
                        for i in 0 ..< rangeArray.count{
                            let range = rangeArray[i] as! NSRange
                            if(judgeItems[i + startRange].valueForKey("Right") as! Bool == true){
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
                        
                        self.disPlayMarkTextArray.replaceObjectAtIndex(self.subIndex, withObject: "1")
                        self.goOVerBtn?.enabled = false
                        self.saveBtn?.enabled = false
                        self.tableView?.reloadData()
                    }
                case .Failure(_):
                    ProgressHUD.showError("阅卷失败")
                }
            })
        //}
    }    //图片放大时候的动作
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
       ShowBigImageFactory.showBigImage(self, webView: self.qusDesWebView!, sender: sender)
    }
    //图片放大的动作
      func showImage(sender:NSNotification){
        let cell = sender.object as! ComplexChoiceTableViewCell
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("showBigVC") as! ImageShowBigViewController
         vc.url = cell.url
    self.navigationController?.pushViewController(vc, animated: true)
   }
    //底部按钮的左右滑动
    func changeIndex(sender:UIButton){
        //阅卷的问题
        
        if(sender.tag == 2){
            //判断是不是到最后一题
            if(self.subIndex == self.subQusItems.count - 1){
                let temp = self.index
               //手势加载下一道大题目
                //判断大题目有没有加载完
                if self.index != self.items.count - 1{
                    self.index += 1
                }
                else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
                   ProgressHUD.showSuccess("已完成全部试题")
                }
                else{
                    let vc = UIStoryboard(name: "Problem", bundle: nil)
                        .instantiateViewControllerWithIdentifier("TranslateVC") as!
                    TranslateViewController
                    vc.kindOfQusIndex = self.kindOfQusIndex + 1
                    vc.title = self.title
                    vc.testid = self.testid
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                if(temp != index){
                    self.initView()
                }
                
        }else{
                if(!isSave){
                    self.oneQusSubSelfAnswers[subIndex] = beforeEditing
                    }
                
                isSave = false
                self.subIndex += 1
                self.initSubView()
            }
        }
        if(sender.tag == 1){
            if(self.subIndex == 0){
                let temp = self.index
                if self.index != 0{
                    (self.index) -= 1
                }else{
                    
                    let vc = UIStoryboard(name: "Problem", bundle: nil)
                        .instantiateViewControllerWithIdentifier("TranslateVC") as!
                    TranslateViewController
                    vc.title = self.title
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.testid = self.testid
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                if(temp != index){
                    self.initView()
                }
                
            }else{
                if(!isSave){
                    self.oneQusSubSelfAnswers[subIndex] = beforeEditing
                    
                }
                isSave = false
                self.subIndex -= 1
                self.initSubView()
                
            }
        }
}
    //底部的tableView出现时候的动画
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        //判断小题的类型
//        if(self.subQusItems[subIndex].valueForKey("type") as! String == "FILL_BLANK"){
////        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
////        UIView.animateWithDuration(0.8) {
////            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
////        }
////
//            cell.contentView.alpha = 0
//            UIView.animateWithDuration(0.8, animations: {
//                cell.contentView.alpha = 1
//            })
//    }
//    }
}
