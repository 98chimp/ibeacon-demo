//
//  AppDelegate.swift
//  ibeacons
//
//  Created by Liam Williams on 2016-08-16.
//  Copyright © 2016 Lighthouse. All rights reserved.
//
//  iBeacons Demo Project for Lighthouse Labs
//  Remember: Set NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription in info.plist

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //Remember instance of location manager must be stored somewhere where it will not be deallocated before
    // permission request, and location operations are complete (don't store it in a method variable)
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.delegate = self
        
        // Always Authorization for monitoring beacons in background
        // While in use Authorization for moitoring for beacons and ranging beacons in foreground
        locationManager.requestAlwaysAuthorization()
        
        //Local Notification permission to show beacon monitoring in background
        application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
        
        return true
    }
}

extension AppDelegate : CLLocationManagerDelegate {
    
    //Wait until permission is allowed to start listening for beacons
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("got permission")
        if status == .authorizedAlways {
            if let uuid = UUID(uuidString: "0248BD99-1141-4347-9B2C-FFE34F92C405") {
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: "")
                locationManager.startRangingBeacons(in: region)
            }
        }
    }
    
    // Confirm that we starting monitoring successfully
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("starting monitoring for region")
    }
    
    //Failure delegate methods for region monitoring and general location manager errors
    // Will not fire if you have not set NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \((error as NSError).description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \((error as NSError).description)")
    }
    
    //Saw this beacon, ie. entering its region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter Region")
        let notification = UILocalNotification()
        notification.alertBody = "Welcome :)"
        notification.soundName = "Default"
        window?.rootViewController?.view.backgroundColor = UIColor.green
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    //Haven't seen this beacon for a while (20s ish?), ie. exiting its region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit Region")
        let notification = UILocalNotification()
        notification.alertBody = "Goodbye :)"
        notification.soundName = "Default"
        window?.rootViewController?.view.backgroundColor = UIColor.white
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    //Ranging beacons delegate method, shows more details about the beacon, including identifiers and distance
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            print(nameForProximity(beacon.proximity))
        }
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            //Not found or unkown
            window?.rootViewController?.view.backgroundColor = UIColor.red
            return "Unknown"
        case .immediate:
            //About a few centimeters
            window?.rootViewController?.view.backgroundColor = UIColor.green
            return "Immediate"
        case .near:
            //About A few meters
            window?.rootViewController?.view.backgroundColor = UIColor.blue
            return "Near"
        case .far:
            //About greater than 10 meters
            window?.rootViewController?.view.backgroundColor = UIColor.yellow
            return "Far"
        }
    }
}

