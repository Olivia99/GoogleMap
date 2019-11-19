//
//  ViewController.swift
//  GoogleMap
//
//  Created by JieyingYang  on 11/17/19.
//  Copyright © 2019 JieyingYang . All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
let regionInMeters = 10000



class ViewController: UIViewController {
var previousLocation : CLLocation?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    let locationManeger = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    func setUpLocationManeger(){
        locationManeger.delegate = self
        locationManeger.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func centerViewOfUserLocation(){
        
        if let location = locationManeger.location?.coordinate{
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
                //set up our location
            setUpLocationManeger()
           checkLocationAuthorization()

        }else{
            
            //show alert to user know they have to turn this on
        }
    }
    
    
    func checkLocationAuthorization(){
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // do map stuff
           
         startTrackingUserLocation()
            
        case.denied:
            break
            
        case.notDetermined:
            locationManeger.requestWhenInUseAuthorization()
            break
        
        case.restricted:
            break
            
        case.authorizedAlways:
            break
     
    }

    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
                   centerViewOfUserLocation()
                   locationManeger.startUpdatingLocation()
                   previousLocation = getCenterLocation(for: mapView)
                   
    }
    
    func getCenterLocation(for mapView: MKMapView)->CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}


extension ViewController: CLLocationManagerDelegate{
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else{return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
//
//        mapView.setRegion(region, animated: true)
//
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
checkLocationAuthorization()
    }
    
   
    }



extension ViewController: MKMapViewDelegate{
       
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
     let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard var previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) < 50 else { return }
        previousLocation = center
        geoCoder.reverseGeocodeLocation(center){[weak self] (placemarks, error) in
            guard let self = self else{return}
            
            if let _ = error{
                return
            }
            
            guard let placemark = placemarks?.first else{
                return
            }
            
            
                let streetNumber = placemark.subThoroughfare ?? ""
          let streetName = placemark.thoroughfare ?? ""
                
                DispatchQueue.main.sync {
                    self.addressLabel.text = "\(streetNumber) \(streetName)"
                }
        }
    }
      
    
    
    
}



