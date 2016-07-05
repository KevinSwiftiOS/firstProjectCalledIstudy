//
//  LaunchViewController.swift
//  istudy
//
//  Created by hznucai on 16/7/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    @IBOutlet weak var desTextView:UITextView!
    override func viewDidLoad() {
        let desString = "一个集作业、练习、测评、考务、题库管理于一体的在线实践平台"
        super.viewDidLoad()
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(15.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: desString, attributes: dic)
        self.desTextView.attributedText = attriString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
