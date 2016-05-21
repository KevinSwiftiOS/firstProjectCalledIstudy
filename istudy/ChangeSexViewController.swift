//
//  ChangeSexViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ChangeSexViewController: UIViewController {
    @IBOutlet weak var manBtn:UIButton?
    //选择性别的
    var selectedSex = NSInteger()
    @IBOutlet weak var womanBtn:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
       
         self.manBtn?.addTarget(self, action: #selector(ChangeSexViewController.selectMan), forControlEvents: .TouchUpInside)
        self.womanBtn?.addTarget(self, action: #selector(ChangeSexViewController.selectWoman), forControlEvents: .TouchUpInside)
        let saveBarItem = UIBarButtonItem(title: "保存", style:.Plain, target: self, action: #selector(ChangeSexViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = saveBarItem
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func selectMan() {
        self.manBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
        self.womanBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
        self.selectedSex = 1
    }
    func selectWoman() {
        self.womanBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
        self.manBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
        self.selectedSex = 0
    }
    func save(sender:UIBarButtonItem){
        //做save的一些事情
        var sex = String()
        if(self.selectedSex == 1){
            sex = "男"
        }else{
            sex = "女"
        }
    let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(sex, forKey: "sex")
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if(userDefaults.valueForKey("sex") == nil || userDefaults.valueForKey("sex") as! String == "男"){
            self.manBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
            self.womanBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
            self.selectedSex = 1
        
        }else{
            self.womanBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
            self.manBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
            self.selectedSex = 0
        }
    }
}
