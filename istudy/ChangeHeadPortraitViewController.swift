//
//  ChangeHeadPortraitViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Alamofire
class ChangeHeadPortraitViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var headPortraitImageView:UIImageView?
    @IBOutlet weak var selectImageFromTableView:UITableView?
    var selectFromArray = ["相册","相机"]
    var imagePicker = UIImagePickerController()
    var selectedImageData = NSData()
    var isFromFromImagePicker = false
    //保存头像的操作
    override func viewDidLoad() {
        super.viewDidLoad()
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
    //tableView的代理
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
        
        self.selectedImageData = UIImageJPEGRepresentation(tempImage, 0.6)!
        self.headPortraitImageView?.image = UIImage(data: self.selectedImageData)
        self.isFromFromImagePicker = true
        
    }
    //imagePicker的代理
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func save(sender:UIBarButtonItem){
        self.saveProfile()
    }
    override func viewWillAppear(animated: Bool) {
        if(self.isFromFromImagePicker == false){
            let userDefault = NSUserDefaults.standardUserDefaults()
            if(userDefault.valueForKey("avtarurl") as? String != nil && userDefault.valueForKey("avtarurl") as! String != ""){
                self.headPortraitImageView?.sd_setImageWithURL(NSURL(string: userDefault.valueForKey("avtarurl") as! String), placeholderImage: UIImage(named: "默认头像"))
                
            }else{
                self.headPortraitImageView?.image = UIImage(named: "默认头像")
            }
        }
    }
    //保存头像
    func saveProfile() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let string = "http://dodo.hznu.edu.cn/api/upfile?authtoken=" + (userDefault.valueForKey("authtoken") as! String)
        Alamofire.upload(.POST, string, multipartFormData: { (formData) in
            formData.appendBodyPart(data: self.selectedImageData, name: "name", fileName: "head.jpg", mimeType: "image/jpeg")
        }) { (encodingResult) in
            switch encodingResult {
            case .Success(let upload, _, _):
                //         print((upload.request?.allHTTPHeaderFields))
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result{
                    case .Success(let Value):
                        let json = JSON(Value)
                        if(json["retcode"].number != 0){
                            ProgressHUD.showError("保存失败")
                        }else{
                            
                            if(json["info"]["succ"].bool == false){
                                ProgressHUD.showError("保存失败")
                            }else{
                                print(json["info"]["uploadedurl"].string)
                        userDefault.setValue(json["info"]["uploadedurl"].string, forKey: "avtarurl")
                        self.save()
                            }
                        }
                    case .Failure(_):
                        print(2)
                        ProgressHUD.showError("保存失败")
                    }
                })
            case .Failure(_):
                ProgressHUD.showError("保存失败")
                print(3)
            }
        }
    }
    func save(){
        let userDefault = NSUserDefaults.standardUserDefaults()
        var email = ""
        var phone = ""
        var avtarurl = ""
        var cls = ""
        var name = ""
        var gender = ""
        if(userDefault.valueForKey("email") as? String != nil && userDefault.valueForKey("email") as! String != ""){
            email = userDefault.valueForKey("email") as! String
        }
        if(userDefault.valueForKey("phone") as? String != nil && userDefault.valueForKey("phone") as! String != ""){
            phone = userDefault.valueForKey("phone") as! String
        }
        if(userDefault.valueForKey("avtarurl") as? String != nil && userDefault.valueForKey("avtarurl") as! String != ""){
            avtarurl = userDefault.valueForKey("avtarurl") as! String
        }
        if(userDefault.valueForKey("cls") as? String != nil && userDefault.valueForKey("cls") as! String != ""){
            cls = userDefault.valueForKey("cls") as! String
        }
        if(userDefault.valueForKey("name") as? String != nil && userDefault.valueForKey("name") as! String != ""){
            name = userDefault.valueForKey("name") as! String
        }
        if(userDefault.valueForKey("gender") as? String != nil && userDefault.valueForKey("gender") as! String != ""){
            gender = userDefault.valueForKey("gender") as! String
        }
        
        let dicParam:[String:AnyObject] = [
            "name":name,
            "gender":gender,
            "cls": cls,
            "phone":phone,
            "email": email,
            "avtarurl":avtarurl]        
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(dicParam, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        let parameter:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,"data":result]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/saveprofile", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
           
                if(json["retcode"].number == 0){
                    ProgressHUD.showSuccess("保存成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("保存失败")
                    print(json["retcode"].number)
                }
            case .Failure(_):ProgressHUD.showError("保存失败")
            }
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
