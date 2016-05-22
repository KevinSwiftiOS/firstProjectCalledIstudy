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
class MultipleChoiceViewController: UIViewController,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate{
    //阅卷 保存 重置的按钮
    //阅卷 重置 保存的按钮
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var saveBtn:UIButton?
    @IBOutlet weak var goOVerBtn:UIButton?
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
    var totalAnswers = NSMutableArray()
    //临时的答案变量 若保存的话 就替换掉原来的否则就不用进行替换
    var tempString = ""
    var beforeTapString = ""
    @IBOutlet weak var tableView:UITableView?
    var index = 0
    //每道题目选择的答案
    //阅卷的几个数组 保存阅卷的信息 还有阅卷的显示UIView
  
    var displayMarkingTextArray = NSMutableArray()
    @IBOutlet weak var displayMarkingTextView:UITextView?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //加线
        //顶部加条线
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

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
            
            self.displayMarkingTextArray.addObject("")
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
        self.initView()
         }
 //销毁所有的通知
    deinit{
        print("MutilyDeinit")
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
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
    func addNewQus(sender:UISwipeGestureRecognizer){
        
        let temp = index
        if sender.direction == .Left{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
                ProgressHUD.showSuccess("题目已完成")
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
        if(self.displayMarkingTextArray[index] as! String != ""){
            self.displayMarkingTextView?.text = self.displayMarkingTextArray[index] as! String
            if(self.totalAnswers[index] as! String != self.items[index].valueForKey("strandanswer") as! String){
                self.displayMarkingTextView?.textColor = UIColor.redColor()
            }else{
                self.displayMarkingTextView?.textColor = UIColor.greenColor()
            }
           
        }else{
            self.displayMarkingTextView?.text = ""
            
        }
        
        
    }
    //重置的动作
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定要重置吗", preferredStyle: UIAlertControllerStyle.Alert)
          let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
        self.totalAnswers.replaceObjectAtIndex(self.index, withObject: "")
            self.tableView?.reloadData()
        
        self.displayMarkingTextArray.replaceObjectAtIndex(self.index, withObject: "")
        self.displayMarkingTextView?.text = self.displayMarkingTextArray[self.index] as! String
         self.postAnswer()
            }
     
        resetAlertView.addAction(resetAction)
         resetAlertView.addAction(cancelAction)
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    
    }
    //阅卷的动作
    @IBAction func goOver(sender:UIButton){
        if(self.enableClientJudge == false) {
            ProgressHUD.showError("未开启阅卷功能")
        }
        else{
            self.Over(self.index)
        }
    }
      
    func Over(index:NSInteger) {
        //没有超过指定的日期且没有开启阅卷功能
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
         //没有超过指定的日期且开启阅卷功能 或者已经超过日期了
        if(!self.isOver && self.enableClientJudge || (self.isOver)){
             isSave = true
            self.postAnswer()
                   let standAnswer = self.items[index].valueForKey("strandanswer") as! String
            //可以见到标准答案 超过日期了但是可以看见标准答案的
            var standAns = ""
            if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){
             standAns = "参考答案" + standAnswer.stringByReplacingOccurrencesOfString("&&&", withString: ",") + "\n"
            }else{
                 standAns = "未开放参考答案"
            }
            //只要字符串拿到 随后两个匹配一下即可
            var knowLedge = ""
            if(self.items[index].valueForKey("knowledge") as? String != nil){
                knowLedge = "知识点" + (self.items[index].valueForKey("knowledge") as! String) + "\n"
            }else{
                knowLedge = "知识点" + "\n"
            }
            var result = "结果:"
            var score = "得分:"
            if(self.totalAnswers[index] as! String == self.items[index].valueForKey("strandanswer") as! String){
                result += "正确" + "\n"
                score += "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "\n"
                self.displayMarkingTextView?.text = knowLedge + result + score + standAns
                self.displayMarkingTextView?.textColor = UIColor.greenColor()
                
            }else{
                result += "错误" + "\n"
                score += "0" + "\n"
                self.displayMarkingTextView?.text = knowLedge + result + score + standAns
                self.displayMarkingTextView?.textColor = UIColor.redColor()
                
            }
            self.displayMarkingTextArray.replaceObjectAtIndex(index, withObject: knowLedge + result + score + standAns)
    self.tableView?.reloadData()
        }
    }
    //保存的动作
    @IBAction func save(sender:UIButton){
        isSave = true
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
                    ProgressHUD.showSuccess("保存成功")
                }
            }
        }

    }
    //初始化界面
    func initView() {
        //比较日期 若是已经过了期限 就把阅卷的结果拿出来
        //进行比较
        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            
        }else{
            self.resetBtn?.enabled = false
            self.goOVerBtn?.enabled = false
            self.saveBtn?.enabled = false
            self.isOver = true
            //每道题目进行阅卷
          self.Over(self.index)
            }
        

        //加载当前是什么题型和当前是第几题
        self.kindOfQuesLabel?.text = self.totalitems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
        //有没有选择按钮也要进行加载
        //除了按钮外的ABCDlabel选项和每个选项的内容进行加载 根据option某是否存在而进行加载
        
        self.qusDesWebView = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        self.qusDesWebView.loadHTMLString(self.items[index].valueForKey("content") as! String, baseURL: nil)
        self.qusDesWebView.delegate = self
        self.tableView?.tableHeaderView = self.qusDesWebView
        self.tableView?.tableFooterView = UIView()
        self.cellHeights.removeAllObjects()
        for i in 0 ..< 8{
            let key = "option" + tempArray[i]
            if(self.items[index].valueForKey(key) as? String != nil && self.items[index].valueForKey(key) as! String != ""){
                cellHeights.addObject(30)
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
            self.tableView?.tableHeaderView = webView
}
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
    func reloadCellHeight(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        if(self.cellHeights[cell.Custag] as! CGFloat != cell.cellHeight){
            self.cellHeights.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
            self.tableView?.reloadData()
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = ChoiceTableViewCell(style: .Default, reuseIdentifier: "ChoiceTableViewCell")
        if(indexPath.row < cellHeights.count){
            let key = "option" + tempArray[indexPath.row]
            cell.optionWebView?.loadHTMLString(self.items[index].valueForKey(key) as! String, baseURL: nil)
            cell.selectionStyle = .None
            cell.contentView.userInteractionEnabled = true
            cell.Custag = indexPath.row
            cell.btn?.setTitle(tempArray[indexPath.row].uppercaseString, forState: .Normal)
            let oneSelfAnswer = self.totalAnswers[index] as! String
            cell.btn?.backgroundColor = UIColor.whiteColor()
            cell.btn?.setTitleColor(UIColor.blueColor(), forState: .Normal)
            cell.view?.userInteractionEnabled = true
            cell.canTap = true
            if(self.displayMarkingTextArray[index] as! String != ""){
                cell.canTap = false
            }
            //多选题 如果包含这个字符就变色
            if(oneSelfAnswer.containsString(tempArray[indexPath.row].uppercaseString)){
                cell.btn?.backgroundColor = RGB(0, g: 153, b: 255)
                
                cell.btn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            
        }
        return cell
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
        
        pt = sender.locationInView(self.qusDesWebView)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.qusDesWebView.stringByEvaluatingJavaScriptFromString(imgUrl)!
        
        
        let data = NSData(contentsOfURL: NSURL(string: urlToSave)!)
        
        if(data != nil){
            let image = UIImage(data: data!)
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = [image!]
            previewPhotoVC.contentOffsetX = 0
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    }
    func showImage(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        let data = cell.Selfdata
        let image = UIImage(data: data)
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
        previewPhotoVC.toShowBigImageArray = [image!]
        previewPhotoVC.contentOffsetX = 0
        self.navigationController?.pushViewController(previewPhotoVC, animated: true)
    }
}
