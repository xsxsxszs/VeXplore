//
//  ImageCache.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation
import SharedKit

class ImageCache
{
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let ioQueue: DispatchQueue
    private var fileManager = FileManager.default
    let diskCachePath: String
    var cacheExpiredInSecond: TimeInterval = 60 * 60 * 24 * 7 // cache will expired after one week
    static let `default` = ImageCache()
    
    private init()
    {
        let cacheName = "in.jimmyis.vexplore.WebImage.ImageCache"
        let sysCacheDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        diskCachePath = (sysCacheDirPath as NSString).appendingPathComponent(cacheName)
        let ioQueueName = "in.jimmyis.vexplore.WebImage.ioQueue"
        ioQueue = DispatchQueue(label: ioQueueName)
        NotificationCenter.default.addObserver(self, selector: #selector(clearMemoryCache), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Publics
    func cache(image: UIImage,
               originalData: Data? = nil,
               forKey key: String,
               toDisk: Bool = true,
               completionHandler: (() -> Void)? = nil)
    {
        memoryCache.setObject(image, forKey: key as NSString)
        
        func callHandlerInMainQueue()
        {
            if let handler = completionHandler
            {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
        
        if toDisk
        {
            ioQueue.async {
                let imageData = originalData != nil ? originalData : UIImagePNGRepresentation(image)
                if let data = imageData
                {
                    if self.fileManager.fileExists(atPath: self.diskCachePath) == false
                    {
                        do {
                            try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch {}
                    }
                    self.fileManager.createFile(atPath: self.cachePath(forKey: key), contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
            }
        }
        else
        {
            callHandlerInMainQueue()
        }
    }
    
    func retrieveImage(forKey key: String, completionHandler: @escaping ((UIImage?) -> Void))
    {
        if let image = retrieveImageInMemoryCache(forKey: key)
        {
            dispatch_async_safely_to_main_queue {
                completionHandler(image)
            }
        }
        else
        {
            ioQueue.async {
                let image = self.diskImage(forKey: key)
                if let image = image
                {
                    // cache image in memmory
                    self.cache(image: image, forKey: key, toDisk: false, completionHandler: nil)
                }
                dispatch_async_safely_to_main_queue {
                    completionHandler(image)
                }
            }
            
        }
        
    }
    
    func retrieveImageData(forKey key: String, completionHandler: @escaping ((Data?) -> Void))
    {
        ioQueue.async {
            let imageData = self.diskImageData(forKey: key)
            dispatch_async_safely_to_main_queue {
                completionHandler(imageData)
            }
        }
    }
    
    func cleanExpiredDiskCache()
    {
        ioQueue.async {
            for fileUrl in self.expiredCacheUrls()
            {
                do {
                    try self.fileManager.removeItem(at: fileUrl)
                } catch { }
            }
        }
    }
    
    func clearDiskCache(completionHandler: (() -> Void)? = nil)
    {
        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.diskCachePath)
                try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch { }
            
            if let completionHandler = completionHandler
            {
                dispatch_async_safely_to_main_queue {
                    completionHandler()
                }
            }
        }
    }
    
    func isImageCachedInDisk(forKey key: String) -> Bool
    {
        let filePath = cachePath(forKey: key)
        var diskCached = false
        ioQueue.sync {
            diskCached = fileManager.fileExists(atPath: filePath)
        }
        return diskCached
    }
    
    func cachePath(forKey key: String) -> String
    {
        let fileName = key.md5
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    func calculateDiskCacheSize(completionHandler: @escaping (_ size: UInt) -> Void)
    {
        ioQueue.async {
            let diskCacheSize = self.diskCacheSize()
            dispatch_async_safely_to_main_queue {
                completionHandler(diskCacheSize)
            }
        }
    }
    
    // MARK: - Privates
    @objc
    func clearMemoryCache()
    {
        memoryCache.removeAllObjects()
    }
    
    private func retrieveImageInMemoryCache(forKey key: String) -> UIImage?
    {
        return memoryCache.object(forKey: key as NSString) as? UIImage
    }

    private func diskImage(forKey key: String) -> UIImage?
    {
        if let data = diskImageData(forKey: key)
        {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func diskImageData(forKey key: String) -> Data?
    {
        let filePath = cachePath(forKey: key)
        let fileUrl = URL(fileURLWithPath: filePath)
        return try? Data(contentsOf: fileUrl)
    }
    
    private func diskCacheSize() -> UInt
    {
        let diskCacheUrl = URL(fileURLWithPath: diskCachePath)
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        var diskCacheSize: UInt = 0
        
        if let fileEnumerator = self.fileManager.enumerator(at: diskCacheUrl, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles, errorHandler: nil),
            let fileUrls = fileEnumerator.allObjects as? [URL]
        {
            for fileUrl in fileUrls
            {
                do {
                    let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                    if resourceValues.isDirectory == true
                    {
                        continue
                    }
                    if let fileSize = resourceValues.totalFileAllocatedSize
                    {
                        diskCacheSize += UInt(fileSize)
                    }
                } catch { }
            }
        }
        
        return diskCacheSize
    }
    
    private func expiredCacheUrls() -> [URL]
    {
        let diskCacheUrl = URL(fileURLWithPath: diskCachePath)
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expiredDate = Date(timeIntervalSinceNow: -cacheExpiredInSecond)
        var expiredCacheUrls = [URL]()
        
        if let fileEnumerator = self.fileManager.enumerator(at: diskCacheUrl, includingPropertiesForKeys: Array(resourceKeys), options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, errorHandler: nil),
            let fileUrls = fileEnumerator.allObjects as? [URL]
        {
            for fileUrl in fileUrls
            {
                do {
                    let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                    if resourceValues.isDirectory == true
                    {
                        continue
                    }
                    if let lastAccessData = resourceValues.contentAccessDate
                    {
                        if (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                        {
                            expiredCacheUrls.append(fileUrl)
                            continue
                        }
                    }
                } catch { }
            }
        }
        return expiredCacheUrls
    }
    
}
