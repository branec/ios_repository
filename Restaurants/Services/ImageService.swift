//
//  ImageService.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 08.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import Foundation
import UIKit

final class ImageService {
    
    fileprivate var imagesDirectory: URL {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        return URL(fileURLWithPath: documents)
    }
    
    func save(image: UIImage) -> String? {
        let data = UIImageJPEGRepresentation(image,0.8)
        
        let uniqueID = NSUUID().uuidString
        let imageURL = imagesDirectory.appendingPathComponent(uniqueID, isDirectory: false)
        
        do {
            try data?.write(to: imageURL, options: .atomicWrite)
            return uniqueID
        } catch(let error) {
            print(error)
            return nil
        }
    }
    
    func load(fileName name: String) -> UIImage? {
        let imageURL = imagesDirectory.appendingPathComponent(name, isDirectory: false)
        guard let data =  FileManager.default.contents(atPath: imageURL.path) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    func delete(fileName name: String) {
        let imageURL = imagesDirectory.appendingPathComponent(name, isDirectory: false)
        do {
            try FileManager.default.removeItem(atPath: imageURL.path)
        } catch (let error) {
            print(error)
        }
    }
}

