//
//  PhotosVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 11/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosVC: UIViewController {

    var coordinate : CLLocationCoordinate2D!
    
    @IBOutlet var collextionView: UICollectionView!
    @IBOutlet var mapView: MKMapView!
    
    //var savedImages:[Photo] = []
    var coreDataPin:Pin!
   // var flickrImage : [FlickrImage] = []

    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    var dataController : DataController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMap()
        
        setupFetchedResultsController { (success) in
            print("success setup fetch")
            if success {
                if self.fetchedResultsController.fetchedObjects == nil {
                    FlickrClient.getFlickrImages(lat: self.coordinate.latitude, lng: self.coordinate.longitude) { (success, result, error) in
                        if success{
                            guard let result = result else { return }
                            
                            for photos in result {
                                self.downloadImages(photos.imageURLString())
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func setupFetchedResultsController(completion: @escaping (Bool)->()) {
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Photo")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            completion(true)
        } catch{
            completion(false)
            fatalError(error.localizedDescription)
        }
    }
    
    
    func addPhotos(_ data: Data) {
        let photo = Photo(context : dataController.viewContext)
        photo.pin = self.coreDataPin
        photo.imageData = data
        do{ try dataController.viewContext.save() }
        catch{
            print(error.localizedDescription,"error adign ")
        }
    }
    
    func downloadImages(_ imageUrl: String){
        let url = URL(string: imageUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error in dataTask")
                return
            }
            guard let data = data else {
                print("data erroe")
                return
            }
            print("Downloading images")
            self.addPhotos(data)
        }
        task.resume()
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

extension PhotosVC : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       // collextionView.beginUp
     }
     
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         //
     }
     
     
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
         
         guard let point = anObject as? Pin else {
             preconditionFailure("All changes observed in the map view controller should be for Point instances")
         }
         switch type {
         case .insert:
            collextionView.insertItems(at: [newIndexPath!])
             //AddAnnotationToMap(point.coordinate)
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

extension PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        
        let image = UIImage(data: aPhoto.imageData!)
         
        cell.imageView.image = image
        
         return cell
    }
    
}

