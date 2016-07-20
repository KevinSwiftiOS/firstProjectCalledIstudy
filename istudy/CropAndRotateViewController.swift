//
//  CropAndRotateViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/30.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
typealias pushBack = (image:UIImage) -> Void
class CropAndRotateViewController: UIViewController {
    var image = UIImage()
    //进行裁剪和缩放的图片
    var callBack:pushBack?
    @IBOutlet weak var saveBtn:UIButton!
    @IBOutlet weak var resetBtn:UIButton!
    @IBOutlet weak var cropAndRotateView:ImageCropperView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "编辑"
        cropAndRotateView?.hidden = false
        cropAndRotateView?.setup()
        cropAndRotateView?.layer.borderWidth = 1.0
        cropAndRotateView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.backgroundColor = UIColor.blackColor()
        cropAndRotateView?.contentMode = .ScaleAspectFill
        cropAndRotateView?.inputView?.contentMode = .ScaleAspectFill
        cropAndRotateView!.image = image
        saveBtn.layer.cornerRadius = 6.0
        resetBtn.layer.cornerRadius = 6.0
        saveBtn.layer.masksToBounds = true
        resetBtn.layer.masksToBounds = true
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func  save(sender:UIButton){
        cropAndRotateView?.finishCropping()
        self.callBack!(image:(cropAndRotateView?.croppedImage)!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func cancel(sender:UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
