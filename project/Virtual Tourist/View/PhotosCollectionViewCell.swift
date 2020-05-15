//
//  PhotosCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 14/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func initWithPhoto(_ photo: FlickrImage) {
        
//        if photo.imageData != nil {
//
//            DispatchQueue.main.async {
//
//                self.imageView.image = UIImage(data: photo.imageData! as Data)
//                self.activityIndicator.stopAnimating()
//            }
//
//        } else {
            
            downloadImage(photo)
       // }
    }
    
    func downloadImage(_ photo: FlickrImage) {
        
        let url = photo.imageURLString()
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                   // self.activityIndicator.stopAnimating()
                   // self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
                }
            }
            
            }
            
            .resume()
    }
}
