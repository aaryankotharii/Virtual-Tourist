//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 12/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

class FlickrClient {
    private static let flickrEndpoint  = "https://api.flickr.com/services/rest/"
    private static let flickrAPIKey    = "6631798c498928174b419c82dcbeccb8"
    private static let flickrSearch    = "flickr.photos.search"
    private static let format          = "json"
    private static let searchRangeKM   = 10
    
    
    //MARK:- GET REQUEST
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let range = Range(uncheckedBounds: (14, data.count - 1))
                let newData = data.subdata(in: range)
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
               
                    DispatchQueue.main.async {
                        completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (Bool,[FlickrImage]?,Error?) -> Void) {
        
            let request = URL(string: "\(flickrEndpoint)?method=\(flickrSearch)&format=\(format)&api_key=\(flickrAPIKey)&lat=\(lat)&lon=\(lng)&radius=\(searchRangeKM)")!
        
        taskForGETRequest(url: request, responseType: PhotosResponse.self) { (result, error) in
            if let error = error {
                completion(false,[],error)
                return
            }
            let photos = result?.photos.photo
            completion(true,photos,nil)
        }
    }
}
