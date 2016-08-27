//
//  WriteTopicsViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/1.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
class WriteTopicsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,AJPhotoPickerProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout{
    //项目id 也就是prohected
    var projectid = NSInteger()
    @IBOutlet weak var photoBtn:UIButton!
    @IBOutlet weak var sendBtn:UIButton!
    @IBOutlet weak var titleTextField: JVFloatLabeledTextField!
    @IBOutlet weak var collectionView:UICollectionView?
    var photos = NSMutableArray()
    @IBOutlet weak var writeTextView: JVFloatLabeledTextView!
    @IBOutlet weak var btmView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加键盘的消失
        self.collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WriteTopicsViewController.resignKeyBoard)))
        ShowBigImageFactory.topViewEDit(self.btmView)
        photoBtn.setFAText(prefixText: "", icon: FAType.FAImage, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        sendBtn.setFAText(prefixText: "", icon: FAType.FASend, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
        //键盘的遮挡
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        self.view.endEditing(true)
        self.view.tintColor = UIColor.grayColor()
        self.collectionView?.layer.borderWidth = 0.3
        self.collectionView?.layer.borderColor = UIColor.grayColor().CGColor
    }
    //键盘的消失
    @IBAction func resign(sender: UIControl) {
        self.writeTextView.resignFirstResponder()
        self.titleTextField.resignFirstResponder()
    }
    func resignKeyBoard() {
        self.writeTextView.resignFirstResponder()
        self.titleTextField.resignFirstResponder()
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
     *  键盘遮挡
     */
    func keyboardWillHideNotification(notification:NSNotification){
        self.writeTextView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        UIView.animateWithDuration(0.3) {
            self.bottomLayout.constant = 25
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
    //每张图片转化成base64的字符串
    func imageToBae64(image:UIImage) -> String{
        let data = UIImageJPEGRepresentation(image, 0.5)
        let encodeString = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return encodeString!
    }
    //发出一个帖子后进行刷新列表
    @IBAction func send(sender:UIButton){
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as!  String
        //主题
        //内容
        //还有图片形式的组装成base64的字符串
        var tempHtmlString = ""
        tempHtmlString = self.writeTextView.text
        
        //循环将图片数组中的值取出 转化成html格式
        for i in 0 ..< self.photos.count{
        let base64String = imageToBae64(self.photos[i] as! UIImage)
            let imgHtml = "<img"  +  " src = " + "\"" +  "data:image/jpg;base64," + base64String +  "\"" + "/>"
            
            tempHtmlString += imgHtml
        }
        
        let subject = self.titleTextField.text
        if(subject == "" || tempHtmlString == ""){
            ProgressHUD.showError("发帖不能为空")
        }else{
        let dic:[String:AnyObject] = ["subject":subject!,
                                      "parentid":"",
                                      "content":tempHtmlString,
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
                                           "postype":"1",
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
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        }
    }
    //collectionView中的一些代理
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoWaterfallCollectionViewCell
        if(indexPath.row < self.photos.count){
            cell.btn.tag = indexPath.row
            cell.btn.setBackgroundImage(self.photos[indexPath.row] as? UIImage, forState: .Normal)
            cell.btn.addTarget(self, action: #selector(WriteTopicsViewController.collectionsPhotosShowBig(_:)), forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    //定义每个cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH / 5, SCREEN_HEIGHT / 8)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    //collectionView中图片的放大
    func collectionsPhotosShowBig(sender:UIButton){
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
        previewPhotoVC.toShowBigImageArray = self.photos
        previewPhotoVC.contentOffsetX = CGFloat(sender.tag)
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
    //当选择好相册后 跟新collectionView
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
    deinit {
        print("writeTopicDeinit")
    }
}
