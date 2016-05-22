//
//  StudyMaterialViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
//这里是一个tableView 随后每次点击这个tableView的时候就会预览文档
import QuickLook
class StudyMaterialViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDataSource{
    @IBOutlet weak var studyMaterialsTableView:UITableView?
    //应该接受到一个url 和每份资料的标题等
    var studyMaterialsArray = NSMutableArray()
    var fileUrl = NSURL()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studyMaterialsTableView?.delegate = self
        self.studyMaterialsTableView?.dataSource = self
        self.studyMaterialsTableView?.tableFooterView = UIView()
        self.studyMaterialsTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(StudyMaterialViewController.headerRefresh))
        let segmentController = AKSegmentedControl(frame: CGRectMake(20,SCREEN_HEIGHT - SCREEN_HEIGHT * 0.8 - 35,SCREEN_WIDTH - 40, 37))
        let btnArray =  [["image":"箭头","title":"名称"],
                         ["image":"箭头","title":"创建时间"],
                                                 ]
        // Do any additional setup after loading the view.
        segmentController.initButtonWithTitleandImage(btnArray)
        self.view.addSubview(segmentController)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studyMaterialsArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //自定义tableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("StudyMaterialCell")
            as! StudyMaterialTableViewCell
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        //定义cell的属性
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //当选择每个cell的时候 预览每个文件 访问到一个url即可
        let previewVC = QLPreviewController()
        previewVC.dataSource = self
        let row = indexPath.row
        //随后改变url 然后推进preViewVC即可
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return self.fileUrl
    }
    func headerRefresh() {
        
    }
}
