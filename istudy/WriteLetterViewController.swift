//
//  WriteLetterViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/12.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class WriteLetterViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,AJPhotoPickerProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
 //收件人的添加
    var parentcode  = NSInteger()
    //主题
//主题的id
    //看是有回复发件人的还是没有回复发件人的
    var repleyToOneId = NSInteger()
    var repleyToOneName = ""
  var alertView = GUAAlertView()
    var subject = ""
      var photos = NSMutableArray()
    var tempString = ""
    var isReply = false
    @IBOutlet weak var subjectTextField:UITextField?
@IBOutlet weak var writeTextView: JVFloatLabeledTextView!
    @IBOutlet weak var collectionView:UICollectionView!
  var selectedPersonIdArray = NSMutableArray()
   var selectedPersonNameArray = NSMutableArray()
    var items = NSArray()
    
    @IBOutlet weak var recevieBtn:UIButton?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subjectTextField?.enabled = !isReply
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.writeTextView.placeholder = "请输入内容"
       self.subjectTextField?.text = self.subject
     self.tabBarController?.tabBar.hidden = true
     self.automaticallyAdjustsScrollViewInsets = false
        self.title = "写邮件"
        //键盘的代理
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        
      
                tempString += self.repleyToOneName
        
    self.recevieBtn?.addTarget(self, action: #selector(WriteLetterViewController.showmoreReceivedPerson(_:)), forControlEvents: .TouchUpInside)
        // Do any additional setup after loading the view.
         }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func selectPerson(sender:UIButton){
        //var tempString = "收件人"
        let contactPersonVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("ContactPersonVC") as! ContactPersonViewController
        contactPersonVC.title = "联系人"
        contactPersonVC.callBack =  { (idArray:NSMutableArray,items:NSArray) -> Void in
            
            self.items = items
            //拿到整个数组后进行整合 抽取
            self.tempString = ""
            for i in 0 ..< self.items.count{
                let contactPersonArray = self.items[i].valueForKey("ContacterList") as! NSArray
                
                for tempOut in 0 ..< contactPersonArray.count{
                    for tempIn in 0 ..< idArray.count{
                        if(idArray[tempIn] as! NSInteger == contactPersonArray[tempOut].valueForKey("Id") as! NSInteger){
                            self.tempString += contactPersonArray[tempOut].valueForKey("Name") as! String + ","
                        }
                    }
                }
            }
                var i = 0
                while i < self.selectedPersonIdArray.count {
                    if NSInteger(self.selectedPersonIdArray[i] as! NSNumber) == self.repleyToOneId{
                        break
                    }
                    i += 1
                }
                if(i == self.selectedPersonIdArray.count){
                self.tempString += self.repleyToOneName
                }
            
            

self.selectedPersonIdArray = idArray
        }
    contactPersonVC.selectedPersonIdArray = self.selectedPersonIdArray
    
      self.navigationController?.pushViewController(contactPersonVC, animated: true)
    }
    func showmoreReceivedPerson(sender:UIButton){
     self.subjectTextField?.resignFirstResponder()
        self.writeTextView.resignFirstResponder()
        if(self.tempString != ""){
            self.alertView = GUAAlertView(title: "已选择收件人", message: self.tempString, buttonTitle: "确定", buttonTouchedAction: {
                
            }){}
        alertView.show()
        }
        }
    //键盘消失
    @IBAction func resign(sender: UIControl) {
        self.subjectTextField?.resignFirstResponder()
        self.writeTextView?.resignFirstResponder()
    }
    func keyboardWillHideNotification(notification:NSNotification){
       UIView.animateWithDuration(0.3) { 
        self.bottomLayout.constant = 8
        self.view.setNeedsLayout()
        }
    }
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    func keyboardWillShowNotification(notification:NSNotification){
       UIView.animateWithDuration(0.3) { 
        self.bottomLayout.constant = 50
self.view.setNeedsLayout()
        }
    }
    //发送的信箱
    @IBAction func sendEmail(sender:UIButton){
        //遍历循环看有没有replyToOneId
        var i = 0
        while i < self.selectedPersonIdArray.count{
            if NSInteger(self.selectedPersonIdArray[i] as! NSNumber) == self.repleyToOneId{
                break
            }
            i += 1
        }
        if(i == self.selectedPersonIdArray.count && self.repleyToOneId != 0)
        {
            self.selectedPersonIdArray.addObject(self.repleyToOneId)
        }
            
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //主题
    
        let subject = self.subjectTextField?.text
        var content = ""
        content = self.writeTextView.text
        //转换成base64字符串
        for i in 0 ..< self.photos.count{
            let widthAndHeight = " width = " + "\(50)" + " height = " + "\(50)"
            let base64String = imageToBae64(self.photos[i] as! UIImage)
            let imgHtml = "<img"  + widthAndHeight +  " src = " + "\"" +  "data:image/jpg;base64," + base64String +  "\"" + "/>"
            
            content += imgHtml

        }
        var receives = ""
        if(self.selectedPersonIdArray.count > 0){
            for i in 0 ..< self.selectedPersonIdArray.count - 1{
                receives += String(self.selectedPersonIdArray[i] as! NSNumber) + ","
            }
        receives += String(self.selectedPersonIdArray[self.selectedPersonIdArray.count - 1] as! NSNumber)
        }
        var  dic = [String:AnyObject]()
        if(parentcode == 0 ){
         dic = ["subject":subject!,
                "parentcode":"",
                "content":content,
                "receives":receives
          ]
        }else{
            dic = ["subject":subject!,
                   "parentcode":"\(self.parentcode)",
                   "content":content,
                   "receives":receives
            ]

        }
        print(dic)
 var result = ""
    do { let paramData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            result = paramData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("发送失败")
          
                 }
        
        let paramDic:[String:AnyObject] = ["authtoken":authtoken,
                                           "data":result]
        print(paramDic)
Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/messagesend", parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
           
            switch response.result{
                
            case .Failure(_):
                ProgressHUD.showError("发送失败")
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
        )
}
    //添加照片的按钮
    @IBAction func addPhoto(sender:UIButton){
        let photoPicker = AJPhotoPickerViewController()
        photoPicker.delegate = self
        
        //设置最大的数量
        photoPicker.maximumNumberOfSelection = 6
        photoPicker.multipleSelection = true
        //资源过滤
        photoPicker.assetsFilter = ALAssetsFilter.allPhotos()
        photoPicker.showEmptyGroups = true
        photoPicker.delegate = self
        photoPicker.selectionFilter = NSPredicate(block: { (evaluatedObjecy:AnyObject, dic:[String : AnyObject]?) -> Bool in
            return true
        })
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    //每张图片转化成base64的字符串
    func imageToBae64(image:UIImage) -> String{
        let data = UIImageJPEGRepresentation(image, 0.5)
        let encodeString = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return encodeString!
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoWaterfallCollectionViewCell
        if(indexPath.row < self.photos.count){
            cell.imageView?.image = self.photos[indexPath.row] as? UIImage
            cell.imageView?.tag = indexPath.row
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
        previewPhotoVC.toShowBigImageArray = self.photos
        previewPhotoVC.contentOffsetX = CGFloat(indexPath.row)
        self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    //选取照片的一些代理
    //当选择超过最大比重时
    func photoPickerDidMaximum(picker: AJPhotoPickerViewController!) {
        ProgressHUD.showError("已超过最大选择数")
    }
    //当点击取消按钮时
    func photoPickerDidCancel(picker: AJPhotoPickerViewController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //当点击了照相机的时候
    func photoPickerTapCameraAction(picker: AJPhotoPickerViewController!) {
        let cameraPicker = UIImagePickerController()
        if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil){
            cameraPicker.sourceType = .Camera
            cameraPicker.delegate = self
            picker.presentViewController(cameraPicker, animated: true, completion: nil)
        }else{
            ProgressHUD.showError("不支持相机")
        }
    }
    //当相机拍完了照片后
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
        self.photos.addObject(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.collectionView?.reloadData()
    }
    //退出照相机的时候
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    //当选择好相册后
    func photoPicker(picker: AJPhotoPickerViewController!, didSelectAssets assets: [AnyObject]!) {
        for i in 0 ..< assets.count {
            let asset = assets[i]
            let tempImage = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
            self.photos.addObject(tempImage)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView?.reloadData()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }

}
