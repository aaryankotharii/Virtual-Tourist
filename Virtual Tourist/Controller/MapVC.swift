//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 11/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    var dataController : DataController!
    
    var fetchedResultsController : NSFetchedResultsController<Pin>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let region = MKCoordinateRegion.load(withKey: "mapregion") {
            mapView.region = region
            mapView.delegate = self
        }
    }
    
    deinit {
          mapView.annotations.forEach{mapView.removeAnnotation($0)}
          mapView.delegate = nil
          print("deinit: MapViewController")
    }
    
    
    @IBAction func mapLongTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
        let tapLocation = sender.location(in: mapView)
        print(tapLocation)
        addAnnotation(tapLocation)
        }
    }
    
    func addAnnotation(_ frompoint: CGPoint){
        let coordinates = mapView.convert(frompoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    func
    
    
    
}

extension MapVC : MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapView.region.save(withKey: "mapregion")
    }
}

extension MKCoordinateRegion {
    public  func save(withKey key:String) {
        let locationData = [center.latitude, center.longitude,
                            span.latitudeDelta, span.longitudeDelta]
        UserDefaults.standard.set(locationData, forKey: key)
    }
    
    public static func load(withKey key:String) -> MKCoordinateRegion? {
        guard let region = UserDefaults.standard.object(forKey: key) as? [Double] else { return nil }
        let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
        let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
        return MKCoordinateRegion(center: center, span: span)
    }
}
