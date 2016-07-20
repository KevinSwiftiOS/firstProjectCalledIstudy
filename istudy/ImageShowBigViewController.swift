//
//  ImageShowBigViewController.swift
//  istudy
//
//  Created by hznucai on 16/5/31.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ImageShowBigViewController: UIViewController,UIScrollViewDelegate {
    var url = ""
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var imageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "预览图"
     ProgressHUD.show("请稍候")
        //图片放大的动作
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImageShowBigViewController.back)))
      imageView.sd_setImageWithURL(NSURL(string: url)) { (_,_, _, _) in
        
        ProgressHUD.dismiss()
        }
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.minimumZoomScale  = 0.5
        self.scrollView.addSubview(self.imageView)
        self.view.backgroundColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //图片的放大
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
