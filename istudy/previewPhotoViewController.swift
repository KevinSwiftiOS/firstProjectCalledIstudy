//
//  previewPhotoViewController.swift
//  istudy
//
//  Created by 金阳 on 16/3/21.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class previewPhotoViewController: UIViewController{
    @IBOutlet weak var scrollView:UIScrollView?
    var isFromWebView = false
    var urlString = ""
    var contentOffsetX = CGFloat()
    var toShowBigImageArray = NSArray()
    var showBigImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        //点击图片或者背景后退出界面
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewPhotoViewController.tap))
        self.view.addGestureRecognizer(tap)
        //加载图片
        if(!isFromWebView){
            for i in 0 ..< self.toShowBigImageArray.count{
                let image = self.toShowBigImageArray[i] as! UIImage
                let showBigView = VIPhotoView(frame: CGRectMake(SCREEN_WIDTH * CGFloat(i),0,SCREEN_WIDTH, SCREEN_HEIGHT * 0.6), andImage: image)
                self.scrollView?.addSubview(showBigView)
                showBigView.contentMode = .ScaleAspectFill
                showBigView.inputView?.contentMode = .ScaleAspectFill
                showBigView.showsVerticalScrollIndicator = false
                showBigView.showsHorizontalScrollIndicator = false
            }
            
            self.scrollView?.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT * 0.6)
            self.scrollView?.contentSize = CGSizeMake(SCREEN_WIDTH * CGFloat(self.toShowBigImageArray.count), 0)
            self.scrollView?.contentOffset = CGPointMake(SCREEN_WIDTH * contentOffsetX, 0)
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.scrollView?.showsVerticalScrollIndicator = false
        }else{
            ProgressHUD.show("请稍候")
            let imageView = UIImageView()
            imageView.sd_setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "默认头像"))
            imageView.contentMode = .ScaleAspectFill
            if(imageView.image != UIImage(named: "默认头像")){
                ProgressHUD.dismiss()
                let showBigView = VIPhotoView(frame: CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT * 0.6), andImage: imageView.image)
                self.scrollView?.addSubview(showBigView)
                showBigView.contentMode = .ScaleAspectFill
                showBigView.inputView?.contentMode = .ScaleAspectFill
                showBigView.showsVerticalScrollIndicator = false
                showBigView.showsHorizontalScrollIndicator = false
                
                self.scrollView?.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT * 0.6)
                self.scrollView?.contentSize = CGSizeMake(SCREEN_WIDTH, 0)
                
                self.scrollView?.showsHorizontalScrollIndicator = false
                self.scrollView?.showsVerticalScrollIndicator = false
                
            }
        }
        
        
        self.navigationController?.navigationBar.hidden = false
        self.title = "预览图"
        self.view.backgroundColor = UIColor.blackColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //点击即退出该视图
    func tap() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
