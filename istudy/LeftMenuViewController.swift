//
//  LeftMenuViewController.swift
//  istudy
//
//  Created by hznucai on 16/7/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
class LeftMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var labelName = ["收件箱","发信箱"]
    var imageName = ["收件箱未选中","发件箱未选中"]
    @IBOutlet weak var tableView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
     self.tableView?.delegate = self
     self.tableView?.dataSource = self
        self.tableView?.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("leftMenuCell") as! LeftMenuTableViewCell
            cell.LetterImageView.image = UIImage(named: imageName[indexPath.row])
        cell.Letterlabel.text = self.labelName[indexPath.row]
            return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let sideVC = delegate.MyletterSlide
        let vc = sideVC.rootViewController as! StationLetterViewController
        sideVC.hideSideViewController(true)
        switch indexPath.row {
        case 0:
            vc.isIn = true
            vc.isOut = false
        case 1:
            vc.isOut = true
            vc.isIn = false
        default:
            break
        }
        vc.stationLetterTableView?.mj_header.beginRefreshing()
       //用协议来传输值
        
    }
}
