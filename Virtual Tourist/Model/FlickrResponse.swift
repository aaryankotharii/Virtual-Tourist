//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 14/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation


struct flickr : Codable{
    let id:Int
    let secret:String
    let server:String
    let farm:Int
}

//{"page":1,"pages":0,"perpage":250,"total":"0","photo":[]}

struct PhotosResponse:Codable {
    let photos: PhotosInfo
    let stat: String
}

struct PhotosInfo: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickerPhoto]
}
struct FlickerPhoto:Codable {
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
