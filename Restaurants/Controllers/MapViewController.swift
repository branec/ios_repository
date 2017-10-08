//
//  MapViewController.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 04.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Material
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    fileprivate let service = APIService()
    fileprivate var mapView: MKMapView! = MKMapView()
    fileprivate var locationManager:CLLocationManager! = CLLocationManager()
    fileprivate let addButton = FABButton(image: Icon.cm.add, tintColor: .white)
    fileprivate let infoButton = RaisedButton(title: "Details", titleColor: .white)
    fileprivate var selectedPin: MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadDataFromApi()
        prepareViewAndNotifications()
        prepareMapView()
        determineCurrentLocation()
        prepareAddButton()
        prepareInfoButton()

    }
    
    private func downloadDataFromApi(){
        
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                CoreDataStack.sharedInstance.clearAllData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            }
        }
        
    }
    
    private func prepareViewAndNotifications(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        isMotionEnabled = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataStack.sharedInstance.persistentContainer.viewContext)
        
    }
    
    private func prepareMapView(){
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        
        mapView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.center = view.center
        
        view.addSubview(mapView)
        
        mapView.delegate = self
        
    }
    
    private func determineCurrentLocation()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        if let location = locationManager.location {
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            
            let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            self.mapView.setRegion(region, animated: true)
            
        }
        
    }
    
    
    private func prepareAddButton(){
        
        addButton.pulseColor = .white
        addButton.backgroundColor = Color.red.base
        addButton.shadowColor = Color.grey.base
        addButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.layout(addButton).size(CGSize(width: 56, height: 56)).bottom(CGFloat(24)).right(CGFloat(24))
        
    }
    
    private func prepareInfoButton(){
        
        infoButton.pulseColor = .white
        infoButton.backgroundColor = Color.blue.base
        infoButton.isHidden = true
        infoButton.addTarget(self, action: #selector(infobuttonAction), for: .touchUpInside)
        view.layout(infoButton)
            .width(CGFloat(150))
            .height(CGFloat(44)).center().bottom(CGFloat(30))
    }

    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print(inserts)
            for insert in inserts {
                if insert is Restaurant{
                    let restaurant: Restaurant = insert as! Restaurant
                    setPins(restaurant: restaurant)

                }
                
            }
            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                let restaurant = update as! Restaurant
                
                    for pin in mapView.annotations {
                        if ((pin.coordinate.latitude == restaurant.latitude) && (pin.coordinate.longitude == restaurant.longitude)){
                            mapView.removeAnnotation(pin)
                            setPins(restaurant: restaurant)
                        }
                    }
            }
               // print(update.changedValues())
            
            print("+++++++++++++++")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
    }
    
    
    private func setPins(restaurant: Restaurant){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(restaurant.latitude, restaurant.longitude)
        annotation.title = restaurant.name!
        annotation.subtitle = restaurant.address!
        mapView.addAnnotation(annotation)

    }
    
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createPhotoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
        
    }
    
    private func createPhotoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: context) as? Restaurant {
            restaurant.address = dictionary["Address"] as? String
            restaurant.latitude = (dictionary["Latitude"] as? Double)!
            restaurant.longitude = (dictionary["Longitude"] as? Double)!
            restaurant.name = dictionary["Name"] as? String
            return restaurant
        }
        return nil
    }
    

 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc private func buttonAction(sender: UIButton!) {
        if let location = locationManager.location{
            present(AddPinViewController(lat: location.coordinate.latitude, long: location.coordinate.longitude), animated: true)
        }
    }
    
    @objc private func infobuttonAction(sender: UIButton!) {
        present(DetailsViewController(pin: selectedPin), animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       infoButton.isHidden = false
       selectedPin = view.annotation as! MKPointAnnotation
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        infoButton.isHidden = true
        selectedPin = MKPointAnnotation()
    }
    
    /*func mapView(_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        else {
            let annotationView = MKAnnotationView()
            annotationView.canShowCallout = true
            return annotationView
        }
    }*/

}
