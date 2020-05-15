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

class PhotosVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var barButton: UIButton!
    
    var coordinate : CLLocationCoordinate2D!
    
    /// Core data Stack
    var dataController : DataController!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    var pin : Pin!
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup(){
        //collectionView FlowLayout setup
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        setupMap()
        setupFetchedResultsController()
        fetchSuccess()
    }
    
    // SETUP MAP
    func setupMap(){
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    //MARK: Get array of FlickrImages
    func fetchSuccess(){
        if pin.photo?.count == 0 {
            FlickrClient.getFlickrImages(lat: coordinate.latitude, lng: coordinate.longitude, completion: handleSuccessFlickerImages(result:error:))
        }
    }
    
    //MARK: Get Array of imageUrls
    func handleSuccessFlickerImages(result:[FlickrImage]?,error:Error?){
        if let result = result{
            for image in result {
                let imageUrl = URL(string: image.imageURLString())
                FlickrClient.requestImageFile(imageUrl!, completion: self.handleImageDownload(data:error:))
            }
        }
    }
    
    //MARK: Download Images from imageUrls
    func handleImageDownload(data:Data?,error:Error?){
        if let data = data {
            print(data,"data saved")
            addImageToCoreData(data)
        } else {
            print(error!.localizedDescription,"Error saving data")
        }
    }
    
    //MARK: Save Image Data to coreData
    func addImageToCoreData(_ data : Data) {
        let photo = Photo(context: dataController.viewContext)
        photo.pin = pin
        photo.imageData = data
        do {
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: Delete Image from database
    func deleteImage(at indexPath: IndexPath) {
        let imageToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(imageToDelete)
        do{
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK:-  UICollectionView Methods
extension  PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        
        cell.imageView.image = UIImage(data: aPhoto.imageData!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.5
            self.deleteImage(at: indexPath)
            cell?.contentView.alpha = 1
        }
    }
}

//MARK:- FetchedResultsController Methods
extension PhotosVC : NSFetchedResultsControllerDelegate{
    
    fileprivate func setupFetchedResultsController(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            print("delete")
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            print("update")
        //notesTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            print("move")
        //notesTableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}
