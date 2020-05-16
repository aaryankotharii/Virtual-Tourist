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
    
    //MARK:- Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var barButton: UIButton!
    @IBOutlet var noPhotosLabel: UILabel!
    
    //MARK:- Variables
    
    /// Selected Coordinate
    var coordinate : CLLocationCoordinate2D!
    
    /// Core data Stack
    var dataController : DataController!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    // pin of photo
    var pin : Pin!
    
    
    // Datasource of collectionView
    var photos : [UIImage] = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: 25){
        didSet{
            if !(photos.contains(#imageLiteral(resourceName: "placeholder"))){
                /** once images are presented newcollection button is enabled **/
                barButton.isEnabled = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    //MARK: Constants
    let spaceBetweenItem:CGFloat = 5
    let totalCellCount:Int = 25
    let cellIdentifier = "cell"
    
    
    //MARK: - View Lifecycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noPhotosLabel.alpha = 0
    }
    
    //MARK: Initial setup
    func initialSetup(){
        //collectionView FlowLayout setup
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = spaceBetweenItem
        flowLayout.minimumLineSpacing = spaceBetweenItem
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Map + fetchedResultsController setup
        setupMap()
        setupFetchedResultsController()
        fetchSuccess()
    }
    
    //MARK:- NEW COLLECTION TAPPED
    @IBAction func newCollectionClicked(_ sender: Any) {
        barButton.isEnabled = false
        deleteAllPhotos()
        photos = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: 25)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        let page = nextPage()
        pin.page = Int32(page)
        try? dataController.viewContext.save()
        FlickrClient.getFlickrImages(lat: coordinate.latitude, lng: coordinate.longitude, page: page, completion: handleSuccessFlickerImages(pages:result:error:))  // DOwnlaod new images
    }
    
    func nextPage() -> Int {
        return ((pin.page+1) <= pin.pages) ? Int(pin.page+1) : 1
    }
    
    func deleteAllPhotos(){
        for photo in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photo)
            do{
                try dataController.viewContext.save()
                print("success delete")
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: Get array of FlickrImages
    func fetchSuccess(){
        if pin.photo?.count == 0 {
            FlickrClient.getFlickrImages(lat: coordinate.latitude, lng: coordinate.longitude, page: 1, completion: handleSuccessFlickerImages(pages:result:error:))
        }
    }
    
    //MARK: Get Array of imageUrls
    func handleSuccessFlickerImages(pages:Int,result:[FlickrImage]?,error:Error?){
        if pages == 0{
            handleNoImages()
            return
        }
        saveNumberOfPagesToPin(pages)
        if let result = result{
            photos = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: result.count-1)
            for image in result {
                let imageUrl = URL(string: image.imageURLString())
                FlickrClient.requestImageFile(imageUrl!, completion: self.handleImageDownload(data:error:))
            }
        }
    }
    
    func saveNumberOfPagesToPin(_ pages: Int){
        // Saves pages attribute of pin the first time data is fetched
        if pin.pages == 0{
            pin.pages = Int32(pages)
            try? dataController.viewContext.save()
        }
    }
    
    func handleNoImages(){
        photos = []
        collectionView.reloadData()
        collectionView.alpha = 0
        noPhotosLabel.alpha = 1
    }
    
    //MARK: Download Images from imageUrls
    func handleImageDownload(data:Data?,error:Error?){
        if let data = data {
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
    
    //MARK: Delete Image from database and photos array
    func deleteImage(at index: Int) {
        if let photos = fetchedResultsController.fetchedObjects{
            let imageToDelete = photos[index]
            do{
                dataController.viewContext.delete(imageToDelete)
                try dataController.viewContext.save()
                self.photos.remove(at: index)
                reFetch()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    //ADD Downloaded Image to Photos array
    func addImageToPhotos(_ image: UIImage){
        if photos.contains(#imageLiteral(resourceName: "placeholder")){
            let index = photos.firstIndex(of: #imageLiteral(resourceName: "placeholder"))
            photos[index!] = image
        }else{
            photos.append(image)
        }
    }
    
}

//MARK:-  UICollectionView Methods
extension  PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count     /// Number of cells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotosCollectionViewCell
        cell.imageView.image = photos[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - spaceBetweenItem
        return CGSize(width: width, height: width)  /// SQAURE CELL
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenItem
    }
    
    // Delete photo on selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deleteImage(at: indexPath.item)
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
            let numberOfPhotos = fetchedResultsController.fetchedObjects?.count ?? 0
            photos = Array(repeating: #imageLiteral(resourceName: "placeholder"), count: numberOfPhotos)
            for photo in fetchedResultsController.fetchedObjects!{
                if let aPhoto = UIImage(data: photo.imageData!){
                    addImageToPhotos(aPhoto)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } catch{
            fatalError(error.localizedDescription)
        }
    }
    
    fileprivate func reFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("reFetch - \(error)")
        }
    }
}

//MARK:- MapView setup
extension PhotosVC: MKMapViewDelegate{
    
    // SETUP MAP
    func setupMap(){
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
}
