//
//  PhotosVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 11/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit

class PhotosVC: UIViewController {

    var coordinate : CLLocationCoordinate2D!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMap()
        // Do any additional setup after loading the view.
    }
    
    func setupMap(){
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
      }
}

extension PhotosVC : MKMapViewDelegate{
    
}

