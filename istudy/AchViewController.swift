//
//  AchViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/28.
//  Copyright © 2016年 hznucai. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class AchViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
   @IBOutlet weak var achCollectionView: UICollectionView!
    var totalItems = NSArray()
    var testid = NSInteger()
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        //自动移下64个单位去掉
        self.automaticallyAdjustsScrollViewInsets = false
        self.achCollectionView?.delegate = self
        self.achCollectionView?.dataSource = self
             //提交的作业
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.addTarget(self, action: #selector(AchViewController.submit(_:)), forControlEvents: .TouchUpInside)
        backBtn.tag = 1
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        let backItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backItem
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.tag = 2
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.addTarget(self, action: #selector(AchViewController.submit(_:)), forControlEvents: .TouchUpInside)
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        let submitItem = UIBarButtonItem(customView: submitBtn)
        self.navigationItem.rightBarButtonItem = submitItem
         backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        // Do any additional setup after loading the view.
    }
    func submit(sender:UIButton) {
        if(sender.tag == 1) {
            self.navigationController?.popViewControllerAnimated(true)
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
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.totalItems.count
    }
    //collectionView的delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let everyQusArray = self.totalItems[section].valueForKey("questions") as! NSArray
        return everyQusArray.count
    }
    //每个点击后进行跳转的界面
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let type = self.totalItems[indexPath.section].valueForKey("type") as! String
            switch type{
          
            case "JUDGE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("JudgeQusVC") as! JudgeQueViewController
                
                vc.testid = self.testid
                vc.totalKindOfQus = self.totalItems.count
                vc.totalItems = self.totalItems
                vc.title = self.title
                vc.index = indexPath.row
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                vc.endDate = self.endDate
                vc.kindOfQusIndex = indexPath.section
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: true)

            case "SINGLE_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ChoiceQusVC") as! ChoiceQusViewController
                vc.testid = self.testid
                vc.totalKindOfQus = self.totalItems.count
                vc.totalItems = self.totalItems
                vc.title = self.title
                vc.index = indexPath.row
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                 vc.endDate = self.endDate
                vc.kindOfQusIndex = indexPath.section
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: true)
            case "MULIT_CHIOCE":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("MultipleChoiceVC") as! MultipleChoiceViewController
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                vc.testid = self.testid
                vc.index = indexPath.row
                vc.totalitems = self.totalItems
              
                vc.title = self.title
                vc.kindOfQusIndex = indexPath.section
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                 vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                //在自己的navigation里面进行判断 若有就pop到那里  否则就push到这里
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "FILL_BLANK","PROGRAM_FILL_BLANK":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("CompletionQusVC") as! CompletionQusViewController
                vc.testid = self.testid
                vc.index = indexPath.row
                vc.totalitems = self.totalItems
                vc.totalKindOfQus = self.totalItems.count
                vc.type = self.totalItems[indexPath.section].valueForKey("type") as! String
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                              vc.title = self.title
                vc.kindOfQusIndex = indexPath.section
                 vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                //在自己的navigation里面进行判断 若有就pop到那里  否则就push到这里
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "COMPLEX":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ComplexQusVC") as!
                ComplexQusViewController
                
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                vc.index = indexPath.row
                vc.title = self.title
                vc.totalItems = self.totalItems
                vc.testid = self.testid
                vc.kindOfQusIndex = indexPath.section
                 print(self.endDate)
                 vc.endDate = self.endDate
               
             vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                //在自己的navigation里面进行判断 若有就pop到那里  否则就push到这里
                self.navigationController?.pushViewController(vc, animated: true)
                
            // 程序设计题的时候 不过相信也没人在手机上打代码
            case "PROGRAM_DESIGN","PROGRAM_CORRECT":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("ProgramDesignVC") as!
                ProgramDesignViewController
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
              vc.type = self.totalItems[indexPath.section].valueForKey("type") as! String
                vc.index = indexPath.row
                vc.title = self.title
                vc.testid = self.testid
                vc.totalitems = self.totalItems
                vc.kindOfQusIndex = indexPath.section
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                 vc.endDate = self.endDate
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                //在自己的navigation里面进行判断 若有就pop到那里  否则就push到这里
                self.navigationController?.pushViewController(vc, animated: true)
            case "DESIGN":
                let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("SubjectiveQusVC") as!
                SubjectiveQusViewController
                vc.items = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
            
                vc.isFromOtherKindQus = true
                vc.title = self.title
                vc.testid = self.testid
                vc.index = indexPath.row
                vc.kindOfQusIndex = indexPath.section
                vc.totalItems = self.totalItems
                vc.totalKindOfQus = self.totalItems.count
                vc.enableClientJudge = self.enableClientJudge
                 vc.endDate = self.endDate
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
                
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let everyQusArray = self.totalItems[indexPath.section].valueForKey("questions") as! NSArray
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AchCollectionVC", forIndexPath: indexPath) as! AchCollectionViewCell
        cell.actLabel?.text = "\(indexPath.row + 1)"
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.contentView.layer.cornerRadius = (SCREEN_WIDTH / 5 - 10) / 2
        cell.contentView.layer.masksToBounds = true
        
            if(everyQusArray[indexPath.row].valueForKey("answer") as? String != nil &&
                everyQusArray[indexPath.row].valueForKey("answer") as! String != ""){
                cell.contentView.backgroundColor = RGB(0, g: 153, b: 255)
        }
        return cell
    }
    //定义每个cell的边框大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    //定义每个cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH / 5 - 10, height: SCREEN_WIDTH / 5 - 10)
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader , withReuseIdentifier: "HeaderCollectionView", forIndexPath: indexPath) as! HeaderCollectionReusableView
        view.kindOfQus?.text = self.totalItems[indexPath.section].valueForKey("title") as? String
        return view
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH, 30)
    }
    //在显示完成多少的界面的时候 要根据是不是从其他界面跳转过来的进行判断
    override func viewWillAppear(animated: Bool) {
        self.achCollectionView.userInteractionEnabled = false
        self.achCollectionView.alpha = 0.3
        self.achCollectionView.backgroundColor = UIColor.grayColor()
         ProgressHUD.show("请稍候")
            let userDefault = NSUserDefaults.standardUserDefaults()
            let authtoken = userDefault.valueForKey("authtoken") as! String
             let dic:[String:AnyObject] = ["authtoken":authtoken,
                                          "testid":"\(self.testid)"]
            Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/testinfo", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .Failure(_):
                    ProgressHUD.showError("请求失败")
                case .Success(let Value):
                    let json = JSON(Value)
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.achCollectionView.userInteractionEnabled = true
                        self.achCollectionView.alpha = 1.0
                        self.achCollectionView.backgroundColor = UIColor.clearColor()
                        ProgressHUD.dismiss()
                        self.totalItems = json["items"].arrayObject! as NSArray
                        self.achCollectionView.reloadData()
                    })
                }
            })
        }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    deinit{
        print("AchDeinit")
    }
}
