//
//  ChoiceQusViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/16.
//  Copyright © 2016年 hznucai. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class ChoiceQusViewController: UIViewController,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate{
    //有没有超过指定的日期
    var isOver = false
    var tap = UITapGestureRecognizer()
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //每个cell的高度
    var cellHeight = NSMutableArray()
    //记录当前是第几个题型 还有总共有几个题型
    var kindOfQusIndex = NSInteger()
    var totalKindOfQus = NSInteger()
    //记录试卷的id
    var testid = NSInteger()
    //显示批阅的信息的数组
    //显示批阅的textView
    //每次增加的高度
    var totalItems = NSArray()
    var resultTextView = UITextView()
    var displayMarkingArray = NSMutableArray()
     var tempArray = ["a","b","c","d","e","f","g","h","i","j"]
      var queDes = UIWebView()
  @IBOutlet weak var kindOfQuesLabel:UILabel?

    @IBOutlet weak var currentQus:UILabel?
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    @IBOutlet weak var gooverBtn:UIButton?
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var topView:UIView?
    @IBOutlet weak var btmView:UIView!
    //总共有几题的collectionView
    var answers = NSMutableArray()
    var index = 0
    var items = NSArray()
    
    //每道题目选择的答案
    var selectedAnswer = NSMutableArray()
    //当在初始化的时候

    override func viewDidLoad() {
        
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //加左右的按钮
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        rightBtn?.addTarget(self, action: #selector(ChoiceQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        leftBtn!.addTarget(self, action: #selector(ChoiceQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
      //设置左右的按钮
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
        
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.topView!)
  
     

        self.tap = UITapGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.webViewShowBig(_:)))
        self.tap.delegate = self
        //加线
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChoiceQusViewController.reloadCellHeight(_:)), name: "ChoiceWebViewHeight", object: nil)
          NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChoiceQusViewController.tap(_:)), name: "choiceTapBtn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChoiceQusViewController.showImage(_:)), name: "ChoiceShowBigImage", object: nil)
        //用tableView来呈现题目和选项
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        //contentView添加手势
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Left
        backBtn.tag = 1
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action: #selector(ChoiceQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let actBtn = UIButton(frame: CGRectMake(10,0,43,43))
        //查看的btn
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action:#selector(ChoiceQusViewController.showAct), forControlEvents: .TouchUpInside)
        //还有提交作业的btn 
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.tag = 2
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.addTarget(self, action: #selector(ChoiceQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
             self.queDes = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        self.queDes.delegate = self
            self.automaticallyAdjustsScrollViewInsets = false
        backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        actBtn.setFAIcon(FAType.FABook, iconSize: 25, forState: .Normal)
             gooverBtn?.setFATitleColor(UIColor.blackColor())
       gooverBtn?.setFAText(prefixText: "", icon: FAType.FAPencil, postfixText: "", size: 25, forState: .Normal)
   
        resetBtn?.setFAText(prefixText: "", icon: FAType.FAMinusSquare, postfixText: "", size: 25, forState: .Normal)
        
        for i in 0 ..< self.items.count{
            self.displayMarkingArray.addObject(0)
            if(self.items[i].valueForKey("answer") as? String != nil){
            self.answers.addObject(self.items[i].valueForKey("answer")!)
            }else{
            self.answers.addObject("")
            }
        }
       
     self.initView()
     

//    //随后这个view加载左滑右滑的手势 来滑动到下一道题目
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
         let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
    self.view.addGestureRecognizer(rightSwipe)
    self.view.addGestureRecognizer(leftSwipe)
    self.tableView?.addGestureRecognizer(leftSwipe)
    self.tableView?.addGestureRecognizer(rightSwipe)
   
       
  }
   //移除所有通知
    deinit{
    print("ChoiceDeinit")
          NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    //到题目列表
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
    //阅卷的按钮
    @IBAction func goOver(sender:UIButton){
      self.Over()
        }
    func Over() {
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
                            //设置字体
                            let length = totalAttriString.length
                            let totalRange = NSMakeRange(0, length)
                          totalAttriString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: totalRange)
                           
                            self.resultTextView.attributedText = totalAttriString
                            self.gooverBtn?.enabled = false
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
    //重置的按钮
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
        self.displayMarkingArray.replaceObjectAtIndex(self.index, withObject: 0)
        self.tableView?.tableFooterView = UIView()
       self.gooverBtn?.enabled = true
       self.answers.replaceObjectAtIndex(self.index, withObject: "")
        self.tableView?.reloadData()
        self.postAnswer()

    }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
     
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    //添加新题目的按钮
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
//初始化视图的动作
    func initView() {
    self.kindOfQuesLabel?.text = self.totalItems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
        var contentString = self.items[index].valueForKey("content") as! String
        contentString = cssDesString + contentString + "</p>"

     queDes.loadHTMLString(contentString, baseURL: nil)
       self.queDes.delegate = self
             self.cellHeight.removeAllObjects()
            for i in 0 ..< 8 {
                   let dic = self.items[index]
                let tempKey = "option" + (tempArray[i])
                if ((dic.valueForKey(tempKey) as? String) != nil && dic.valueForKey(tempKey) as? String != ""){
                       cellHeight.addObject(40)
                }
            }
self.tableView?.reloadData()
    }
    //点击来改变答案
    func tap(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        //以前那个刷没
        let answer = self.answers[index].lowercaseString
        var i = 0
        while i < self.tempArray.count{
            if(answer == self.tempArray[i]){
              break
            }
            i += 1
        }
     
             self.answers.replaceObjectAtIndex(index, withObject: self.tempArray[cell.Custag].uppercaseString)
      self.tableView?.reloadData()
        self.postAnswer()
        }
    //向服务器传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.answers.objectAtIndex(index)]
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
    //webView的一些代理
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
      
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
            var frame = webView.frame
        frame.size.height = CGFloat(height!) + 10
        webView.frame = frame
//        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
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
        self.gooverBtn?.enabled = true
        self.resetBtn?.enabled = true
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            self.isOver = false
            if(self.displayMarkingArray[index] as! NSObject != 0){
                self.Over()
                self.gooverBtn?.enabled = false
            }else{
                self.tableView?.tableFooterView = UIView()
            }
        }else{
            self.isOver = true
            //每道题目进行阅卷
            self.Over()
            self.gooverBtn?.enabled = false
            self.resetBtn?.enabled = false
            self.displayMarkingArray[index] = 1
        }
        self.tableView?.reloadData()
        }
    //tableView的一些代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeight.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < cellHeight.count){
            return cellHeight[indexPath.row] as! CGFloat
        }else{
            return 0
        }
    }
    //刷新cell的高度
    func reloadCellHeight(sender:NSNotification){
     let cell = sender.object as! ChoiceTableViewCell
        if(self.cellHeight[cell.Custag] as! CGFloat != cell.cellHeight){
            self.cellHeight.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
            if(cell.Custag == self.cellHeight.count - 1){
                self.tableView?.reloadData()
            }

            
        }
//        }else{
//   
//                   }
    
    
}
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ChoiceTableViewCell(style: .Default, reuseIdentifier: "ChoiceTableViewCell")
        if(indexPath.row < cellHeight.count){
            let key = "option" + tempArray[indexPath.row]
            let optionContentString = cssOptionString + (self.items[index].valueForKey(key) as! String)
            cell.optionWebView?.loadHTMLString(optionContentString, baseURL: nil)
            cell.selectionStyle = .None
            cell.contentView.userInteractionEnabled = true
            cell.Custag = indexPath.row
            let optionString = tempArray[indexPath.row].uppercaseString + "."
            cell.btn?.setTitle(optionString, forState: .Normal)
            let oneSelfAnswer = self.answers[index] as! String
            cell.btn?.backgroundColor = UIColor.whiteColor()
            cell.btn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
            cell.view?.userInteractionEnabled = true
            cell.canTap = true
            if(self.displayMarkingArray[index] as! NSInteger != 0){
                cell.canTap = false
            }
            if(oneSelfAnswer == tempArray[indexPath.row].uppercaseString){
               
                cell.btn?.setTitleColor(RGB(0, g: 153, b: 255), forState: .Normal)
            }
            
            }
    return cell
    }
    //点击图片的放大动作
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
    //放大动作
    func webViewShowBig(sender:UITapGestureRecognizer){
    ShowBigImageFactory.showBigImage(self, webView: self.queDes, sender: sender)
    }

    func showImage(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
     
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("showBigVC") as! ImageShowBigViewController
        vc.url = cell.url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    //手势的左右滑动来加载题目
    func changeIndex(sender:UIButton){
        let temp = index
        if(sender.tag == 2){
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
}
