//
//  ImageViewCacheExtension.swift
//  Memer
//
//  Created by Nuri Chun on 6/23/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

var cachedImage = [String : UIImage]()

class ImageViewCache: UIImageView {
    
    var previousUrlString: String?
    
    func loadImage(urlString: String) {
        
        print("Loading Image...")
        
        // resets the image to have white background and not flicker between images when scrolled.
        
        previousUrlString = urlString
        
        self.image = nil
        
        if let cachedImage = cachedImage[urlString] {
            self.image = cachedImage
            return
        }
        // 1. convert String URL to URL
        // 2. Download imageURL by using URLSession.shared.dataTask
        // 3. Convert the image data to image and assign it.
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Image could not be downloaded", error ?? "") 
                return
            }
            
            if url.absoluteString != self.previousUrlString {
                return
            }
            
            // If this data exists... then..
            if let imageData = data {
    
                let image = UIImage(data: imageData)
                
                // put the downloaded image into the cache object
                
                cachedImage[url.absoluteString] = image
                
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
