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
    
    var photos : [UIImage] = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: 25)
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    @IBAction func newCollectionClicked(_ sender: Any) {
        
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
            photos = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: result.count-1)
            print(result.count)
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
            DispatchQueue.main.async {
                if let aPhoto = UIImage(data: data){
                    self.addImageToPhotos(aPhoto)
                self.collectionView.reloadData()
            }
                self.addImageToCoreData(data)
            }
        } else {
            print(error!.localizedDescription,"Error saving data")
        }
    }
    
    //MARK: Save Image Data to coreData
    func addImageToCoreData(_ data : Data) {
        let photo = Photo(context: dataController.viewContext)
        photo.pin = pin
        photo.imageData = data
        try? dataController.viewContext.save()
    }
    
    //MARK: Delete Image from database
    func deleteImage(at indexPath: IndexPath) {
        let imageToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(imageToDelete)
        try? dataController.viewContext.save()
        photos.remove(at: indexPath.item)
    }
    
    func addImageToPhotos(_ image: UIImage){
        if photos.contains(#imageLiteral(resourceName: "placeholder")){
            let index = photos.firstIndex(of: #imageLiteral(resourceName: "placeholder"))
            photos[index!] = image
        } else {
            photos.append(image)
        }
    }
}

//MARK:-  UICollectionView Methods
extension  PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        
        cell.imageView.image = photos[indexPath.item]
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
            self.deleteImage(at: indexPath)
            collectionView.reloadData()
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
            for photo in fetchedResultsController.fetchedObjects!{
                let aPhoto = UIImage(data: photo.imageData!)
                addImageToPhotos(aPhoto!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } catch{
            fatalError(error.localizedDescription)
        }
    }
}
