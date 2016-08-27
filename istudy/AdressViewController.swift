//
//  AdressViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class AdressViewController: UIViewController,CLLocationManagerDelegate,HZAreaPickerDelegate,UITextFieldDelegate{
    @IBOutlet weak var addressTextField:UITextField?
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    //选择框
    var locatePicker = HZAreaPickerView()
    //记录位置
    var address = NSString()
    var locationManager:CLLocationManager!
    //经纬度
    var currLocation:CLLocation?
    let userDefault = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)

        let saveBarItem = UIBarButtonItem(title: "保存", style:.Plain, target: self, action: #selector(AdressViewController.save(_:)))
       self.currLocation = CLLocation()
        self.navigationItem.rightBarButtonItem = saveBarItem
       self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        //精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //指定水平或者竖直位置发生多少平移后开始跟新
        locationManager.distanceFilter = 200
        //发出授权
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        //当页面进入时看看有没有通讯位置
        if(userDefault.valueForKey("address") == nil){
            self.addressTextField?.text = "暂时无地址"
        }else{
            self.addressTextField?.text = userDefault.valueForKey("address") as? String
        }
        self.addressTextField?.delegate = self
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //允许定位的操作
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Denied
        {
            //允许使用定位服务
            locationManager.startUpdatingLocation()
            
        }
    }
    //保存定位地址
    func save(sender:UIBarButtonItem){
        //做save的一些事情
         self.userDefault.setValue(self.address, forKey: "address")
        self.navigationController?.popViewControllerAnimated(true)
        ProgressHUD.showSuccess("保存成功")
    }
    //当距离改变的时候回调用下面的代码
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations.last! as CLLocation
        self.currLocation = currLocation
        self.reverseGeocoder()
    }

    //当定位失败时出现一下信息
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        ProgressHUD.showError("定位失败")
    }
 //输出反编码的信息
    func reverseGeocoder() {
        let geocoder = CLGeocoder()
        var p: CLPlacemark?
        geocoder.reverseGeocodeLocation(currLocation!, completionHandler: { (placemarks, error) -> Void in
            //强制成中文
                      //显示所有信息
            if error != nil
            {
            ProgressHUD.showError("定位失败")
                return
            }
            let pm = placemarks! as [CLPlacemark]
            if pm.count > 0
            {
                p = placemarks!.last! as CLPlacemark
                self.address = (p?.name)!//输出反编码信息
                self.addressTextField?.text = self.address as String
                
            }
            else
            {
                ProgressHUD.showError("定位失败")
            }
        })
    }
    @IBAction func location(sender:UIButton){
        //开始定位
        self.locationManager.startUpdatingLocation()
    }
    //自定义按钮
    @IBAction func customLocation(sender:UIButton){
        self.cancelLocatePicker()
        self.locatePicker = HZAreaPickerView(style: HZAreaPickerWithStateAndCityAndDistrict, delegate: self)
        self.locatePicker.showInView(self.view)
      
    }
    
    func pickerDidChaneStatus(picker: HZAreaPickerView!) {
        self.address = picker.locate.state + picker.locate.city + picker.locate.district
        self.addressTextField?.text = self.address as String
        
    }
    func cancelLocatePicker() {
        self.locatePicker.cancelPicker()
        self.locatePicker.delegate = nil
    }
    //keyBoard的代理 
    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 64
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 10
           //加载新的约束
            self.view.layoutIfNeeded()
        }
    }

       //当手点击的时候底下的选择框消失
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.cancelLocatePicker()
        self.addressTextField?.resignFirstResponder()
    }
    @IBAction func resign(sender: UIControl) {
        self.cancelLocatePicker()
        self.addressTextField?.resignFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
 