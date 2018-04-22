//
//  MapViewController.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 19/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

protocol MapViewControllerDelegate: class {
    func savedLocation(latitude: Double, longitude: Double)
}

class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    let mapView = MKMapView()
    let textField = UITextField()
    
    var initialLatitude: Double?
    var initialLongitude: Double?
    
    weak var delegate: MapViewControllerDelegate?
    
    override func loadView() {
        let backView = UIView()
        backView.addSubview(mapView)
        backView.addSubview(textField)
        
        textField.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let dictViews = ["mapView": mapView, "textField": textField]
        
        var constraint = NSLayoutConstraint
            .constraints(withVisualFormat: "|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews)
        constraint.append(contentsOf: NSLayoutConstraint
            .constraints(withVisualFormat: "|-20-[textField]-20-|", options: [], metrics: nil, views: dictViews))
        constraint.append(contentsOf: NSLayoutConstraint
            .constraints(withVisualFormat: "V:|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews))
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(40)]", options: [], metrics: nil, views: dictViews))
        
        constraint.append(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20))
        
        backView.addConstraints(constraint)
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Map"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveLocation))

        textField.isUserInteractionEnabled = true
        textField.text = ""
        
        mapView.delegate = self
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if initialLatitude == nil {
            self.initialLatitude = 40.416831666
            self.initialLongitude = -3.702163858
        }
        
        let region = MKCoordinateRegion(center:
            CLLocationCoordinate2D(latitude: initialLatitude ?? 40.416831666, longitude: initialLongitude ?? -3.702163858),
                                        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        mapView.setRegion(region, animated: false)
    }

    @objc private func saveLocation() {
        delegate?.savedLocation(latitude: initialLatitude!, longitude: initialLongitude!)
        navigationController?.popViewController(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoord = mapView.centerCoordinate
        
        let location = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            if let places = placeMarkArray {
                if let place = places.first {
                    DispatchQueue.main.async {
                        if let postalAdd = place.postalAddress {
                            self.textField.text = "\(postalAdd.street), \(postalAdd.city)"
                        }
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mapView.isScrollEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.text != nil && !textField.text!.isEmpty {
            mapView.isScrollEnabled = false
            
            let geocoder = CLGeocoder()
            let postalAddress = CNMutablePostalAddress()
            
            postalAddress.street = textField.text!
            postalAddress.isoCountryCode = "ES"
            
            geocoder.geocodePostalAddress(postalAddress) { (placeMarkArray, error) in
                if placeMarkArray != nil && placeMarkArray!.count > 0 {
                    let placemark = placeMarkArray?.first
                    
                    self.initialLatitude = placemark?.location!.coordinate.latitude
                    self.initialLongitude = placemark?.location!.coordinate.longitude
                    
                    DispatchQueue.main.async {
                        let region = MKCoordinateRegion(center: placemark!.location!.coordinate,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
                        self.mapView.setRegion(region, animated: false)
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
