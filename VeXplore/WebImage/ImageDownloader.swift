//
//  ImageDownloader.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

struct ImageDownloadId
{
    var url: URL
    var callbackKey: String
}

class ImageDownloader: NSObject, URLSessionDataDelegate
{
    class DownloadTask
    {
        var completionCallbacks = [String: ImageRetrieveCompletionHandler]()
        var responseData = NSMutableData()
        var downloadTaskCount = 0
        var dataTask: URLSessionDataTask!
    }
    
    private var tasks = [URL: DownloadTask]()
    private var session: URLSession!
    public static let `default` = ImageDownloader()
    
    private override init()
    {
        super.init()
        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
    }
    
    // MARK: - Publics
    @discardableResult
    func downloadImage(with url: URL, completionHandler: ImageRetrieveCompletionHandler?) -> ImageDownloadId?
    {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        guard let url = request.url, url.absoluteString.isEmpty == false else {
            completionHandler?(nil, nil, NSError())
            return nil
        }
        
        let task = tasks[url] ?? DownloadTask()
        tasks[url] = task
        let callbackKey = NSUUID().uuidString
        if let completionHandler = completionHandler
        {
            task.completionCallbacks[callbackKey] = completionHandler
        }
        
        if task.dataTask == nil
        {
            let dataTask = session.dataTask(with: request)
            task.dataTask = dataTask
            dataTask.resume()
        }
        task.downloadTaskCount += 1
        
        return ImageDownloadId(url: url, callbackKey: callbackKey)
    }
    
    func cancelImageDownloadTask(for id: ImageDownloadId)
    {
        if let downloadTask = tasks[id.url]
        {
            downloadTask.completionCallbacks.removeValue(forKey: id.callbackKey)
            downloadTask.downloadTaskCount -= 1
            if downloadTask.downloadTaskCount == 0
            {
                downloadTask.dataTask.cancel()
                cleanTask(for: id.url)
            }
        }
    }
    
    // MARK: - Privates
    private func cleanTask(for url: URL)
    {
        let _ = tasks.removeValue(forKey: url)
    }
    
    private func completionCallbacksWithFailure(error: NSError, url: URL)
    {
        guard let downloadTask = tasks[url] else {
            return
        }
        
        cleanTask(for: url)
        for (_, completionHandler) in downloadTask.completionCallbacks
        {
            dispatch_async_safely_to_main_queue {
                completionHandler(nil, nil, error)
            }
        }
    }
    
    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
            let url = dataTask.originalRequest?.url,
            statusCode.isValidStatusCode() == false
        {
            completionCallbacksWithFailure(error: NSError(), url: url)
        }
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        if let url = dataTask.originalRequest?.url, let downloadTask = tasks[url]
        {
            downloadTask.responseData.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        guard let url = task.originalRequest?.url else {
            return
        }
        
        guard error == nil else {
            completionCallbacksWithFailure(error: error as! NSError, url: url)
            return
        }
        
        guard let downloadTask = tasks[url] else {
            return
        }
        
        cleanTask(for: url)
        let data = downloadTask.responseData as Data
        for (_, completionHandler) in downloadTask.completionCallbacks
        {
            if let image = UIImage(data: data)
            {
                dispatch_async_safely_to_main_queue {
                    completionHandler(image, data, nil)
                }
            }
            else
            {
                dispatch_async_safely_to_main_queue {
                    completionHandler(nil, nil, NSError())
                }
            }
        }
    }

}
