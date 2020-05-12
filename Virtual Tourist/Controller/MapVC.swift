//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 11/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    var dataController : DataController!
    
    var pins : [Pin] = []
    
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
        addPin(coordinates)
    }
    
    func addPin(_ coordinate: CLLocationCoordinate2D){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        do{
        try dataController.viewContext.save()   ///TODO 'Show error if data not saved'
        pins.append(pin)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pin")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch{
            fatalError(error.localizedDescription)
        }
    }
    
    
    
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

extension MapVC : NSFetchedResultsControllerDelegate {
    
}
