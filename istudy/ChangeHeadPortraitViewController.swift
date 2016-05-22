//
//  ChangeHeadPortraitViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreData
class ChangeHeadPortraitViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var headPortraitImageView:UIImageView?
    @IBOutlet weak var selectImageFromTableView:UITableView?
    var selectFromArray = ["相册","相机"]
    var imagePicker = UIImagePickerController()
    var managedContext:NSManagedObjectContext?
    var fetchedResults = [PersonalHeadPortrait]()
    var selectedImageData = NSData()
    var isFromFromImagePicker = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print(222)
        self.headPortraitImageView?.layer.masksToBounds = true
        self.headPortraitImageView?.layer.cornerRadius = 50.0
        let saveBarItem = UIBarButtonItem(title: "保存", style:.Plain, target: self, action: #selector(ChangeHeadPortraitViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = saveBarItem
        self.selectImageFromTableView?.delegate = self
        self.selectImageFromTableView?.dataSource = self
        self.selectImageFromTableView?.layer.masksToBounds = true
        self.imagePicker.delegate = self
        self.selectImageFromTableView?.tableFooterView = UIView()
        self.selectImageFromTableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "selectedCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectedCell")
        for view in (cell?.contentView.subviews)!{
            view.removeFromSuperview()
        }
        cell?.textLabel?.text = selectFromArray[indexPath.row]
        cell?.accessoryType = .DisclosureIndicator
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.imagePicker.allowsEditing = false
        let row = indexPath.row
        switch row{
        case 0: if(UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            self.imagePicker.sourceType = .PhotoLibrary
               self.imagePicker.allowsEditing = true
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }else{
            ProgressHUD.showError("相册无法打开")
            }
        case 1: if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            self.imagePicker.sourceType = .Camera
            self.imagePicker.allowsEditing = true
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }else{
            ProgressHUD.showError("无法打开相机")
            }
        default:break
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let tempImage = info[UIImagePickerControllerEditedImage] as! UIImage
      picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectedImageData = UIImagePNGRepresentation(tempImage)!
        self.headPortraitImageView?.image = UIImage(data: self.selectedImageData)
        self.isFromFromImagePicker = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func save(sender:UIBarButtonItem){
        //做save的一些事情 将头像保存 还有后台数据也要存储
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = app.managedObjectContext
        let entity = NSEntityDescription.entityForName("PersonalHeadPortrait", inManagedObjectContext: self.managedContext!)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext) as! PersonalHeadPortrait
        person.headPortraitData = self.selectedImageData
        do {try self.managedContext?.save()
            ProgressHUD.showSuccess("保存成功")
            self.navigationController?.popViewControllerAnimated(true)
        }catch{
            ProgressHUD.showError("保存失败")
        }
    }
    override func viewWillAppear(animated: Bool) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        dispatch_async(dispatch_get_main_queue()) {
            
        self.managedContext = app.managedObjectContext
        if(self.isFromFromImagePicker == false){
            let fetchResquest = NSFetchRequest(entityName: "PersonalHeadPortrait")
            do { self.fetchedResults = try self.managedContext?.executeFetchRequest(fetchResquest) as! [PersonalHeadPortrait]
                if(self.fetchedResults.count > 0){
                    self.selectedImageData = (self.fetchedResults.last?.headPortraitData)!
                }else{
                    self.selectedImageData = UIImagePNGRepresentation(UIImage(named: "默认头像")!)!
                }
                self.headPortraitImageView?.image = UIImage(data: self.selectedImageData)
            }catch{
                ProgressHUD.showError("读取图像失败")
            }
        }
    }
    }
}
