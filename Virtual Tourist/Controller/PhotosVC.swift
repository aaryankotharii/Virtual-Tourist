//
//  PhotosVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var coordinate : CLLocationCoordinate2D!
    
    /// Core data Stack
    var dataController : DataController!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    var pin : Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects?.count == 0 {
        FlickrClient.getFlickrImages(lat: coordinate.latitude, lng: coordinate.longitude) { (success, result, error) in
            if success {
                if let result = result{
                    for image in result {
                        let url = image.imageURLString()
                        let imageUrl = URL(string: url)
                        FlickrClient.requestImageFile(imageUrl!, completionHandler: self.handleImageDownload(data:error:))
                    }
                }
            }
        }
        }
    }
    
    func addNote(_ data : Data) {
        let photo = Photo(context: dataController.viewContext)
        photo.pin = pin
        photo.imageData = data
        try? dataController.viewContext.save()  ///TODO 'Show error if data not saved'
    }
    
    func handleImageDownload(data:Data?,error:Error?){
        if let data = data {
            print(data,"data saved")
            addNote(data)
        } else {
            print(error?.localizedDescription,"Error saving data")
        }
    }

    
    fileprivate func setupFetchedResultsController() {
            let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch{
            fatalError(error.localizedDescription)
        }
    }
    
    
}

extension  PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        
        cell.imageView.image = UIImage(data: aPhoto.imageData!)
        
        return cell
    }
}

extension PhotosVC : NSFetchedResultsControllerDelegate{
    
}
