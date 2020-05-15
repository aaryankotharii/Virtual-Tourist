//
//  PhotosVC.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit

class PhotosVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var coordinate : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FlickrClient.getFlickrImages(lat: coordinate.latitude, lng: coordinate.longitude, completion: handleGetFlickrImages(success:result:error:))
    }
    
    func handleGetFlickrImages(success:Bool,result:[FlickrImage]?,error:Error?){
        if success {
            if let result = result {
                for image in result{
                    print(image.imageURLString())
                }
            }
        }
    }
    
    
}

extension  PhotosVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
