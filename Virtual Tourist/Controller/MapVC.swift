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
        
    var fetchedResultsController : NSFetchedResultsController<Pin>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController(completion: loadMap(fetchSuccessful:))
        if let region = MKCoordinateRegion.load(withKey: "mapregion") {
            mapView.region = region
            mapView.delegate = self
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        addPin(coordinate)
        }
    }
    
    
    func AddAnnotationToMap(_ fromCoordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoordinate
        mapView.addAnnotation(annotation)
    }
    
    func addPin(_ coordinate: CLLocationCoordinate2D){
        let pin = Pin(context: dataController.viewContext)      /// Initialise Pin
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        do{
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func setupFetchedResultsController(completion: @escaping (Bool)->()) {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        //fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pin")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            completion(true)
        } catch{
            completion(false)
            fatalError(error.localizedDescription)
        }
    }
    
    
    func loadMap(fetchSuccessful success: Bool){
        if success {
        if let points = fetchedResultsController.fetchedObjects{
        for point in points {
            let coordinate = point.coordinate
            addPin(coordinate)
                }
            }
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       //
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       //
    }


    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let point = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        print(point)
        switch type {
        case .insert:
            AddAnnotationToMap(point.coordinate)
            print("insert")
        case .delete:
            print("delete")
            //folderTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("update")
              //folderTableView.reloadRows(at: [indexPath!], with: .fade)
          case .move:
            print("move")
              //folderTableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}
