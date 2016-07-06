//
//  AppDelegate.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
  let MyletterSlide = YRSideViewController()
    var MyLetter = StationLetterViewController()
    var window: UIWindow?
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let loginNavigationVC = UIStoryboard(name: "LoginAndReset",bundle: nil).instantiateViewControllerWithIdentifier("LoginNavigationVC") as! UINavigationController
//        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
//我的课程
    let myCourse = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("myCourse") as! CourseDesViewController
    let myTest = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("myTest") as! MyTestViewController
    //站内信的滑动按钮
  
 MyLetter = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyLetter") as! StationLetterViewController
    //左边按钮
    let leftMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("leftMenu") as! LeftMenuViewController
    let personal = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("personal") as! PersonalViewController
    
    MyletterSlide.rootViewController = MyLetter
    MyletterSlide.title = "站内信"
    MyletterSlide.leftViewController = leftMenuController
    MyletterSlide.leftViewShowWidth = 200
    MyletterSlide.needSwipeShowMenu = true
    //创建四个navigation
    let myCourseNav = UINavigationController(rootViewController: myCourse)
    let myTestNav = UINavigationController(rootViewController: myTest)
    let stationLetterNav = UINavigationController(rootViewController: MyletterSlide)
    let mypersonalNav = UINavigationController(rootViewController: personal)
    let mainVC = UITabBarController()
    mainVC.viewControllers = [myCourseNav,myTestNav,stationLetterNav,mypersonalNav]
    //设置按钮
    let tabitem1 = UITabBarItem(title: "我的课程", image:UIImage(named: "我的课程"),selectedImage: UIImage(named: "我的课程"))
    let tabitem2 = UITabBarItem(title: "我的考试", image: UIImage(named: "我的考试未选中"),selectedImage: UIImage(named: "我的考试未选中"))
    let tabitem3 = UITabBarItem(title: "站内信", image: UIImage(named: "收件箱选中"),selectedImage: UIImage(named: "收件箱选中"))
    let tabitem4 = UITabBarItem(title: "个人中心", image:UIImage(named: "个人信息"),selectedImage: UIImage(named: "个人信息"))

    myCourseNav.tabBarItem = tabitem1
    myTestNav.tabBarItem = tabitem2
    stationLetterNav.tabBarItem = tabitem3
    mypersonalNav.tabBarItem = tabitem4
self.window?.frame = UIScreen.mainScreen().bounds
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if(userDefaults.valueForKey("userName") == nil){
        self.window?.rootViewController = loginNavigationVC
        }else{
          self.window?.rootViewController = mainVC
    }
    self.window?.rootViewController?.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hznucai.istudy" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("istudy", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}



