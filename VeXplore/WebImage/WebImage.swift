//
//  WebImage.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

typealias ImageRetrieveCompletionHandler = ((_ image: UIImage?, _ originalData: Data?, _ error: NSError?) -> Void)

struct WebImage
{
    static func retrieveImage(with url: URL, completionHandler: ImageRetrieveCompletionHandler?)
    {
        ImageCache.default.retrieveImageData(forKey: url.cacheKey, completionHandler: { originalData in
            if originalData != nil
            {
                completionHandler?(nil, originalData, nil)
            }
            else
            {
                WebImage.downloadAndCacheImage(with: url, forKey: url.cacheKey, completionHandler: completionHandler)
            }
        })
    }
    
    private static func downloadAndCacheImage(with url: URL,
                                              forKey key: String,
                                              completionHandler: ImageRetrieveCompletionHandler?)
    {
        ImageDownloader.default.downloadImage(with: url, completionHandler: { image, originalData, error in
            if let image = image, let originalData = originalData
            {
                ImageCache.default.cache(image: image, originalData: originalData, forKey: key)
            }
            completionHandler?(image, originalData, error)
        })
    }
    
}

extension URL
{
    var cacheKey: String {
        return absoluteString
    }
    
}
