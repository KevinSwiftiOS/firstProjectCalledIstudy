//
//  TranslateViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/25.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import Font_Awesome_Swift
import SwiftyJSON
//每个界面的过渡界面 从选择题到填空题时的过渡界面

class TranslateViewController: UIViewController{
    //左右滑动的按钮和底部view
    @IBOutlet weak var leftBtn:UIButton?
    @IBOutlet weak var rightBtn:UIButton?
    @IBOutlet weak var bottomView:UIView?
    //描述文本内容的textView
    @IBOutlet weak var desTextView:UITextView!
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //是不是第一次加载
    var isFirstTime = Bool()
    //记录是第几个试卷
    //试卷的名字
    var testid = NSInteger()
    //考虑到当前是第几个题型
    var totalItems = NSArray()
    var kindOfQusIndex = NSInteger()
    @IBOutlet weak var kindOfQusLabel:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //左右按钮
        
        ShowBigImageFactory.topViewEDit(self.bottomView!)
        ShowBigImageFactory.addBorderSubView(self.view)
        leftBtn?.tag = 1
        rightBtn?.tag = 2
        leftBtn?.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        rightBtn?.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        leftBtn?.setTitleColor(UIColor.blueColor(), forState: .Normal)
        rightBtn?.setTitleColor(UIColor.blueColor(), forState: .Normal)
        leftBtn?.addTarget(self, action: #selector(TranslateViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        rightBtn?.addTarget(self, action: #selector(TranslateViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        backBtn.contentHorizontalAlignment = .Left
        backBtn.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action: #selector(TranslateViewController.back as (TranslateViewController) -> () -> ()), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
    }
    //通用的返回按钮
    func back() {
        let vc = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
        
        for temp in (self.navigationController?.viewControllers)!{
            if(temp .isKindOfClass(vc.classForCoder)){
                self.navigationController?.popToViewController(temp, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var canMove = false
    func goToNewKindQus(sender:UISwipeGestureRecognizer){
        //先判断手势
        
        if(sender.direction == .Right){
            if(self.kindOfQusIndex == 0){
                
                ProgressHUD.showError("第一大题")
            }else{
                
                self.kindOfQusIndex -= 1
                switch self.totalItems[kindOfQusIndex].valueForKey("type") as! String {
                    
                case "JUDGE","SINGLE_CHIOCE":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ChoiceQusVC") as! ChoiceQusViewController
                    vc.testid = self.testid
                    vc.totalKindOfQus = self.totalItems.count
                    vc.totalItems = self.totalItems
                    vc.title = self.title
                    
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                case "MULIT_CHIOCE":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("MultipleChoiceVC") as! MultipleChoiceViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.totalitems = self.totalItems
                    vc.testid = self.testid
                    vc.title = self.title
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                case "FILL_BLANK","PROGRAM_FILL_BLANK":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("CompletionQusVC") as! CompletionQusViewController
                    vc.testid = self.testid
                    vc.totalKindOfQus = self.totalItems.count
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.title = self.title
                    vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                    vc.totalitems = self.totalItems
                    
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    vc.endDate = self.endDate
                    self.navigationController?.pushViewController(vc, animated: false)
                case "COMPLEX":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ComplexQusVC") as!
                    ComplexQusViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.title = self.title
                    vc.testid = self.testid
                    vc.totalItems = self.totalItems
                    vc.index = vc.items.count - 1
                    
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                // 程序设计题的时候 不过相信也没人在手机上打代码
                case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ProgramDesignVC") as!
                    ProgramDesignViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.totalitems = self.totalItems
                    
                    vc.title = self.title
                    vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                    vc.testid = self.testid
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    vc.endDate = self.endDate
                    self.navigationController?.pushViewController(vc, animated: false)
                case "DESIGN":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("SubjectiveQusVC") as!
                    SubjectiveQusViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.totalItems = self.totalItems
                    
                    vc.testid = self.testid
                    vc.title = self.title
                    vc.isFromOtherKindQus = false
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.index = vc.items.count - 1
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                default:
                    break
                    
                }
            }
        }
        //左右手势的判别
        if(sender.direction == .Left){
            
            switch self.totalItems[kindOfQusIndex].valueForKey("type") as! String {
                
            case "JUDGE","SINGLE_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ChoiceQusVC") as! ChoiceQusViewController
                vc.testid = self.testid
                vc.totalKindOfQus = self.totalItems.count
                vc.totalItems = self.totalItems
                vc.title = self.title
                vc.index = 0
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "MULIT_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("MultipleChoiceVC") as! MultipleChoiceViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                vc.testid = self.testid
                vc.title = self.title
                
                
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "FILL_BLANK","PROGRAM_FILL_BLANK":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("CompletionQusVC") as! CompletionQusViewController
                vc.testid = self.testid
                vc.index = 0
                vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                vc.title = self.title
                
                vc.totalKindOfQus = self.totalItems.count
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                vc.endDate = self.endDate
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "COMPLEX":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ComplexQusVC") as!
                ComplexQusViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalItems = self.totalItems
                vc.index = 0
                vc.testid = self.testid
                vc.title = self.title
                vc.endDate = self.endDate
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            // 程序设计题的时候 不过相信也没人在手机上打代码
            case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ProgramDesignVC") as!
                ProgramDesignViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                
                vc.testid = self.testid
                vc.index = 0
                vc.title = self.title!
                vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "DESIGN":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("SubjectiveQusVC") as!
                SubjectiveQusViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalItems = self.totalItems
                vc.testid = self.testid
                vc.index = 0
                vc.title = self.title
                vc.isFromOtherKindQus = false
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            default:
                break
                //设计题
                
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        //刚开始的时候不能够点击 以免出现bug
        leftBtn?.enabled = false
        rightBtn?.enabled = false
        ProgressHUD.show("请稍候")
        self.kindOfQusLabel?.text = ""
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let dic:[String:AnyObject] = ["authtoken":authtoken,
                                      "testid":"\(self.testid)"]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/testinfo", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    print(json["retcode"].number)
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.totalItems = json["items"].arrayObject! as NSArray
                        self.kindOfQusLabel?.text = self.totalItems[self.kindOfQusIndex].valueForKey("title") as? String
                        //左滑 返回上一个界面 右滑 到下一种提醒
                        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TranslateViewController.goToNewKindQus(_:)))
                        leftSwipe.direction = .Left
                        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TranslateViewController.goToNewKindQus(_:)))
                        rightSwipe.direction = .Right
                        self.view.addGestureRecognizer(leftSwipe)
                        self.view.addGestureRecognizer(rightSwipe)
                        self.self.leftBtn?.enabled = true
                        self.rightBtn?.enabled = true
                        var desString = ""
                        let tempItem = self.totalItems[self.kindOfQusIndex].valueForKey("questions") as! NSArray
                        switch self.totalItems[self.kindOfQusIndex].valueForKey("type") as! String{
                        case "JUDGE":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请从每小题中选择正确或者错误的一项"
                        case "SINGLE_CHIOCE":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请从每小题给出的选项中选择出正确的一项"
                        case "MULIT_CHIOCE":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请从每小题给出的选项中选择出正确的多项"
                        case "FILL_BLANK","PROGRAM_FILL_BLANK":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请填写符合题意的内容"
                        case "COMPLEX":
                            desString = "本大题共" + "\(tempItem.count)" + "小题, 请选择或者填写正确的内容"
                        case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请编写程序"
                        case "DESIGN":
                            desString = "本大题共" + "\(tempItem.count)" + "小题,请添加文字或者图片"
                        default:
                            break
                        }
                        
                        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(15.0),
                            NSForegroundColorAttributeName:UIColor.grayColor()]
                        let attriString = NSMutableAttributedString(string: desString, attributes: dic)
                        self.desTextView.attributedText = attriString
                        
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            }
        })
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    deinit{
        print("TranslateDeinit")
    }
    func changeIndex(sender:UIButton){
        //先判断手势
        
        if(sender.tag == 1){
            if(self.kindOfQusIndex == 0){
                
                ProgressHUD.showError("第一大题")
            }else{
                
                self.kindOfQusIndex -= 1
                switch self.totalItems[kindOfQusIndex].valueForKey("type") as! String {
                    
                case "JUDGE":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("JudgeQusVC") as! JudgeQueViewController
                    vc.testid = self.testid
                    vc.totalKindOfQus = self.totalItems.count
                    vc.totalItems = self.totalItems
                    vc.title = self.title
                    
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                case "SINGLE_CHIOCE":
                    //是否可以阅卷 截止日期等
                    
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ChoiceQusVC") as! ChoiceQusViewController
                    vc.testid = self.testid
                    vc.totalKindOfQus = self.totalItems.count
                    vc.totalItems = self.totalItems
                    vc.title = self.title
                    
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.endDate = self.endDate
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                case "MULIT_CHIOCE":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("MultipleChoiceVC") as! MultipleChoiceViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.totalitems = self.totalItems
                    vc.testid = self.testid
                    vc.title = self.title
                    
                    
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                case "FILL_BLANK","PROGRAM_FILL_BLANK":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("CompletionQusVC") as! CompletionQusViewController
                    vc.testid = self.testid
                    vc.totalKindOfQus = self.totalItems.count
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.title = self.title
                    vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                    vc.totalitems = self.totalItems
                    
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    vc.endDate = self.endDate
                    self.navigationController?.pushViewController(vc, animated: false)
                case "COMPLEX":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ComplexQusVC") as!
                    ComplexQusViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.title = self.title
                    vc.testid = self.testid
                    vc.totalItems = self.totalItems
                    vc.index = vc.items.count - 1
                    
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                // 程序设计题的时候 不过相信也没人在手机上打代码
                case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ProgramDesignVC") as!
                    ProgramDesignViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.index = vc.items.count - 1
                    vc.totalitems = self.totalItems
                    
                    vc.title = self.title
                    vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                    vc.testid = self.testid
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    vc.endDate = self.endDate
                    self.navigationController?.pushViewController(vc, animated: false)
                case "DESIGN":
                    let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("SubjectiveQusVC") as!
                    SubjectiveQusViewController
                    vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                    vc.totalItems = self.totalItems
                    
                    vc.testid = self.testid
                    vc.title = self.title
                    vc.isFromOtherKindQus = false
                    vc.kindOfQusIndex = self.kindOfQusIndex
                    vc.totalKindOfQus = self.totalItems.count
                    vc.index = vc.items.count - 1
                    vc.enableClientJudge = self.enableClientJudge
                    vc.keyVisible = self.keyVisible
                    vc.endDate = self.endDate
                    vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                    self.navigationController?.pushViewController(vc, animated: false)
                default:
                    break
                    
                }
            }
        }
        if(sender.tag == 2){
            
            switch self.totalItems[kindOfQusIndex].valueForKey("type") as! String {
                
            case "JUDGE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("JudgeQusVC") as! JudgeQueViewController
                vc.testid = self.testid
                vc.totalKindOfQus = self.totalItems.count
                vc.totalItems = self.totalItems
                vc.title = self.title
                
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.index = 0
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
                
            case "SINGLE_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ChoiceQusVC") as! ChoiceQusViewController
                vc.testid = self.testid
                
                
                
                vc.totalKindOfQus = self.totalItems.count
                vc.totalItems = self.totalItems
                vc.title = self.title
                vc.index = 0
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "MULIT_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("MultipleChoiceVC") as! MultipleChoiceViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                vc.testid = self.testid
                vc.title = self.title
                
                
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "FILL_BLANK","PROGRAM_FILL_BLANK":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("CompletionQusVC") as! CompletionQusViewController
                vc.testid = self.testid
                vc.index = 0
                vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                vc.title = self.title
                
                vc.totalKindOfQus = self.totalItems.count
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                vc.endDate = self.endDate
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "COMPLEX":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ComplexQusVC") as!
                ComplexQusViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalItems = self.totalItems
                vc.index = 0
                vc.testid = self.testid
                vc.title = self.title
                vc.endDate = self.endDate
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            // 程序设计题的时候 不过相信也没人在手机上打代码
            case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ProgramDesignVC") as!
                ProgramDesignViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalitems = self.totalItems
                
                vc.testid = self.testid
                vc.index = 0
                vc.title = self.title!
                vc.type = self.totalItems[kindOfQusIndex].valueForKey("type") as! String
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            case "DESIGN":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("SubjectiveQusVC") as!
                SubjectiveQusViewController
                vc.items = self.totalItems[kindOfQusIndex].valueForKey("questions") as! NSArray
                vc.totalItems = self.totalItems
                
                vc.testid = self.testid
                vc.index = 0
                vc.title = self.title
                vc.isFromOtherKindQus = false
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)
            default:
                break
                //设计题
                
            }
        }
    }
}
