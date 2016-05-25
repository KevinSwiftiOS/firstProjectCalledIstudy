//
//  WritePeerAssessmentViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/22.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//闭包来传值
typealias send_index = (index:NSInteger) -> Void
class WritePeerAssessmentViewController: UIViewController {
  //评论的是第几个
    var items = NSArray()
    var usertestid = NSInteger()
    var index = NSInteger()
    var callBack:send_index?
    override func viewDidLoad() {
        super.viewDidLoad()
    print(usertestid)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 //提交评论的结果
    @IBAction func savePeer(sender:UIButton){
        self.callBack!(index:self.index)
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillAppear(animated: Bool) {
        ProgressHUD.show("请稍候")
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //写请求时间等等
        let urlString = "http://dodo.hznu.edu.cn/api/hupingusertest?usertestid=" + "\(self.usertestid)" + "&authtoken=" + authtoken
    
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!, cachePolicy:NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
        request.HTTPMethod = "GET"
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            case .Success(let Value):
                let json = JSON(Value)
                print(json)
                if(json["retcode"].number != 0){
                    
                    ProgressHUD.showError("请求失败")
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
                        
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
