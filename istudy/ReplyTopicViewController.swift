//
//  ReplyTopicViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class ReplyTopicViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 var id = NSInteger()
    var items = NSArray()
    var projectid = NSInteger()
    var topView = UIView()
    var bubbleView = AYBubbleView()
    //回复的内容
    @IBOutlet weak var writeTextView:JVFloatLabeledTextView?
    @IBOutlet weak var replyListTableView:UITableView?
    override func viewDidLoad() {
         topView = UIView(frame: CGRectMake(80,0,SCREEN_WIDTH - 80,64))
        self.navigationController?.view.addSubview(topView)
        super.viewDidLoad()
        //气泡的效果
        var point = topView.center
        point.x -= 84
        
         bubbleView = AYBubbleView(centerPoint: (point), bubleRadius: 15, addToSuperView: topView)
        bubbleView.bubbleColor = UIColor.redColor()
     
     
        
      self.automaticallyAdjustsScrollViewInsets = false
        self.writeTextView?.placeholder = "请输入回复内容"
self.replyListTableView?.dataSource = self
self.replyListTableView?.delegate = self
self.replyListTableView?.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReplyListTableViewCell")
        as! ReplyListTableViewCell
        cell.authorLabel?.text = self.items[indexPath.row].valueForKey("author") as? String
        //加载头像
//        if(self.items[indexPath.row].valueForKey("avatar_url") as? String != nil &&
//            self.items[indexPath.row].valueForKey("avatar_url") as! String != ""){
//            //将base64转化成图片 首先转化成数据流 随后再转化图片
//            let imageData = NSData(base64EncodedString: self.items[indexPath.row].valueForKey("avatar_url") as! String, options: .IgnoreUnknownCharacters)
//        let image = UIImage(data: imageData!)
//            cell.headImageView?.image = image
//        
//        }else{
        cell.headImageView?.image = UIImage(named: "教师头像")
        
        //}
        //时间的切割
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
    let  tempDate = items[indexPath.row].valueForKey("date") as! NSString
        let date = "于" + (tempDate.substringWithRange(yearRange) + "年" + tempDate.substringWithRange(monthRange) + "月" + tempDate.substringWithRange(dateRange)  + "日 "  + "发表")
        cell.dateLabel?.text = date
      
        cell.contectWebView?.loadHTMLString(self.items[indexPath.row].valueForKey("content") as! String, baseURL: nil)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    override func viewWillAppear(animated: Bool) {
        ProgressHUD.show("请稍候")
        //查询论坛的主题回复
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let dic:[String:AnyObject] = ["authtoken":authtoken,
                                      "count":"100",
                                       "page":"1",
                                        "tag":"\(self.id)"]
        Alamofire.request(.GET, "http://dodo.hznu.edu.cn/api/forumcommentquery", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                }else{
                    self.items = json["items"].arrayObject! as NSArray
                    dispatch_async(dispatch_get_main_queue(), {
                       ProgressHUD.dismiss()
                        self.bubbleView.unReadLabel.text = "\(self.items.count)"
                        self.replyListTableView?.reloadData()
                    })
                    
                    
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            }
        }
    }
    //回复的按钮
    @IBAction func reply(sender:UIButton){
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as!  String
        //主题
        //内容
     
        let content = self.writeTextView!.text
        let dic:[String:AnyObject] = ["subject":"",
                                      "parentid":"\(self.id)",
                                      "content":content,
                                      "forumtypeid":"",
                                      "projectid":"\(self.projectid)"]
     
        var result = String()
        //先转化成data数据流 随后再转化成base64的字符串
        do{
            var paramData = NSData()
            paramData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = paramData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
        }catch{
            print(2)
        }
        let paramDic:[String:AnyObject] = ["authtoken":authtoken,
                                           "postype":"2",
                                           "data":result]
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/forumpost", parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("发送失败")
                print(2)
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("发送失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("发送成功")
                }
            }
        }
    }
    @IBAction func resign(sender: UIControl) {
        self.writeTextView?.resignFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        topView.removeFromSuperview()
    ProgressHUD.dismiss()
        self.replyListTableView?.mj_header.endRefreshing()
    }
    
}
