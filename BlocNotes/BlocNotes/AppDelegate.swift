//
//  AppDelegate.swift
//  BlocNotes
//
//  Created by Charles Wesley Cho on 7/27/15.
//  Copyright (c) 2015 Charles Wesley Cho. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set Status bar to white
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        let navigationController = self.window!.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.managedObjectContext
        
        // Add iCloud
        iCloudAccountIsSignedIn()
        
        // Obtain iCloud token -----------------------------------------------------------Experimental code
        let currentiCloudToken = NSFileManager.defaultManager().ubiquityIdentityToken
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if ((currentiCloudToken) != nil) {
            let newTokenData:NSData = NSKeyedArchiver.archivedDataWithRootObject(currentiCloudToken!)
            userDefaults.setObject(newTokenData, forKey: "com.apple.BlocNotes.UbiquityIdentityToken")
            
        } else {
            userDefaults.removeObjectForKey("com.apple.BlocNotes.UbiquityIdentityToken")
        }
        // The selector is supposed to use "iCloudAccountAvailabilityChanged"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: iCloudAccountAvailabilityChanged(), name: NSUbiquityIdentityDidChangeNotification, object: nil)
        
        if ((currentiCloudToken) != nil && firstLaunchWithiCloudAvailable) {
            var alert: UIAlertController!
            alert.title = "Choose Storage Option"
            alert.message = "Should documents be stored in iCloud and available on all your devices?"
            alert.delete(self)
            alert.preferredStyle = UIAlertControllerStyle
            
            
        }
        
        
        // Obtain iCloud token -----------------------------------------------------------Experimental code

        
        return true
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BlocNotes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentationDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        let storeUrl = documentsDirectory.URLByAppendingPathComponent("CoreData.sqlite")
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Allow automatic lightweight migration
        
        let mOptions = [NSPersistentStoreUbiquitousContentNameKey: "BlocNotesStore",
                     NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: mOptions, error: &error) == nil {            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - iCloud
    
    func iCloudAccountIsSignedIn () -> Bool {
        if let token = NSFileManager.defaultManager().ubiquityIdentityToken {
            println("** iCloud is signed in with token \(token)")
            return true
        } else {
            println("iCloud is NOT signed in")
            println("--> Is iCloud Documents and Data enabled for a valid iCloud account on your Mac & iOS Device or Simulaltor?")
            println("--> Is there a CODE_SIGN_ENTITLEMENTS Xcode warning that needs fixing? You may need to specifically choose a developer instead of using Automatic Selection")
            return false
        }
    }
    
}

