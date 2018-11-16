//
//  AppDelegate.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/7/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        //MARK: Autologin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                }
            }
        })
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startUpdatingLocation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        stopUpdatingLocation()
    }
    
    //MARK: Location manager start/stop updating location
    func startUpdatingLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        }
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
         if locationManager != nil {
            locationManager?.stopUpdatingLocation()
        }
    }
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fialed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("Restricted for now")
        case .denied:
            locationManager = nil
            print("Denied")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinates = locations.last?.coordinate
    }
    
    //MARK: GoToApp
    func goToApp() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApplication") as! UITabBarController
        self.window?.rootViewController = mainView
    }
}

