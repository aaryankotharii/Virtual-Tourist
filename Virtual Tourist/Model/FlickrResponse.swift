//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation


struct PhotosResponse:Codable {
    let photos: PhotosInfo
    let stat: String
}

struct PhotosInfo: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrImage]
}
struct FlickrImage:Codable {
    let id: String
    let owner: String
    let secret: String
    let farm : Int
    let server : String
    let title : String
    let ispublic: Int
    let isfriend: Int
    let isfamily:Int
    
    func imageURLString() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
}
