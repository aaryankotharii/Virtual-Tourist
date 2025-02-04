//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {
    
    /// Map View that displays Map
    @IBOutlet var mapView: MKMapView!
    
    /// Core data Stack
    var dataController : DataController!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Pin>!
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEditButtonState()
    }
    
    func initialSetup(){
        self.navigationItem.rightBarButtonItem = self.editButtonItem            /// Set Edit Button
        if let region = MKCoordinateRegion.load(withKey: "mapregion"){
            mapView.region = region                                             /// Load persisted mapview
        }
        setupFetchedResultsController(completion: loadMap(fetchSuccessful:))    /// Setup fetchedResultsController
    }
    
    
    //MARK:- Long Tap Gesture On MapView
    @IBAction func mapLongTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            let tapLocation = sender.location(in: mapView)
            let coordinate = self.mapView.convert(tapLocation, toCoordinateFrom: self.mapView)
            addPin(coordinate)
        }
    }
    
    //MARK:-  ----------    ADD PIN FUNCTIONS   ----------
    
    //MARK: Add annotation to mapView
    func AddAnnotationToMap(_ fromCoordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoordinate
        mapView.addAnnotation(annotation)
    }
    
    //MARK: Save Pin to coreData
    func addPin(_ coordinate: CLLocationCoordinate2D){
        let pin = Pin(context: dataController.viewContext)      /// Initialise Pin
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.page = 1
        do{
            try dataController.viewContext.save()
        } catch {
            errorALert(error.localizedDescription)
        }
        updateEditButtonState()
        isEditing = false
    }
    
    //MARK:-  ----------    DELETE PIN FUNCTIONS   ----------
    
    //MARK: Remove annotation from mapView
    func deleteAnnotation(_ fromCoordinate : CLLocationCoordinate2D){
        let annotations =  mapView.annotations.filter { $0.coordinate == fromCoordinate}
        let annotationtoDelete = annotations.first
        mapView.removeAnnotation(annotationtoDelete!)
    }
    
    //MARK: Delete Pin from coreData
    func deletePin(_ pin:MKAnnotation){
        let coord = pin.coordinate
        let pinToDelete = fetchPin(coord)!
        dataController.viewContext.delete(pinToDelete)
        do {
            try dataController.viewContext.save()
        } catch{
            errorALert(error.localizedDescription)
        }
        updateEditButtonState()
    }
    
    func updateEditButtonState() {
        if let sections = fetchedResultsController.sections{
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
            if !(navigationItem.rightBarButtonItem?.isEnabled ?? false) { isEditing = false }
        }
    }
    
    //MARK: get pin from annotation
    func fetchPin(_ coordinate: CLLocationCoordinate2D) -> Pin?{
        if let pins = fetchedResultsController.fetchedObjects{
            let pin = pins.filter{ $0.coordinate == coordinate}
            return pin.first
        }
        return nil
    }
    
    // ADD Annotations from coredata pins
    func loadMap(fetchSuccessful success: Bool){
        if success {
            if let points = fetchedResultsController.fetchedObjects{
                for point in points {
                    let coordinate = point.coordinate
                    AddAnnotationToMap(coordinate)
                }
            }
        }
    }
    
    //MARK:- ---------- NAVIGATION -----------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotosVC {
            let coordinate = sender as! CLLocationCoordinate2D
            vc.coordinate = coordinate
            vc.dataController = self.dataController
            vc.pin = fetchPin(coordinate)
        }
    }
}

// MARK:- MKMapView Delegate Methods
extension MapVC : MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapView.region.save(withKey: "mapregion")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            // Delete Pin if editing on
            deleteAlert("Pin") { (result) in
                switch result{
                case .success:
                    mapView.deselectAnnotation(view.annotation, animated: true)
                    self.deletePin(view.annotation!)
                case .failure:
                    mapView.deselectAnnotation(view.annotation, animated: true)
                }
            }
            // Segue to PhotosVC if not editing
        } else {
            let coordinate = view.annotation?.coordinate
            performSegue(withIdentifier: "tophotos", sender: coordinate)
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
}

//MARK:- functions to persist map state
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

//MARK:-  FetchedResultsController Delegate Methods + Private Methods
extension MapVC : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController(completion: @escaping (Bool)->()) {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let point = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        switch type {
        case .insert:
            AddAnnotationToMap(point.coordinate)
        case .delete:
            print("Pin Delete successful")
            deleteAnnotation(point.coordinate)
        default:
            break
        }
    }    
}

//MARK:- Returns coordinate of Pin from attributes
extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}
