//
//  Rest_api_download_service.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 05.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import Foundation
import CoreLocation

enum Result <T>{
    case Success(T)
    case Error(String)
}

class APIService: NSObject{
 
    lazy var endPoint: String = { return "http://www.mocky.io/v2/54ef80f5a11ac4d607752717" }()

    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        let urlString = endPoint
        
        guard let url = URL(string: urlString) else { return completion(.Error("Invalid URL, we can't update your feed")) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                    
                    DispatchQueue.main.async {
                        completion(.Success(json))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
    
    
    
}


