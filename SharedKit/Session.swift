//
//  Session.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

class SessionManager: NSObject, URLSessionDataDelegate
{
    static let shared = SessionManager()
    private var session = URLSession()
    private var requests = [Int: Request]()
    private let lock = NSLock()
    
    subscript(task: URLSessionTask) -> Request? {
        get
        {
            lock.lock()
            defer { lock.unlock() }
            return requests[task.taskIdentifier]
        }
        set
        {
            lock.lock()
            defer { lock.unlock() }
            requests[task.taskIdentifier] = newValue
        }
    }
    
    private override init()
    {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    deinit
    {
        session.invalidateAndCancel()
    }
    
    func request(_ url: String,
                 method: HTTPMethod = .get,
                 parameters: [String: String]? = nil,
                 headers: [String: String]? = nil) -> Request
    {
        do {
            let urlRequest = try URLRequest(url: url, method: method, headers: headers)
            let encodedUrlRequest = try urlRequest.encode(with: parameters)
            return request(with: encodedUrlRequest)
        } catch {
            return request(with: error)
        }
    }
    
    private func request(with urlRequest: URLRequest) -> Request
    {
        let task = session.dataTask(with: urlRequest)
        let request = Request(session: session, task: task)
        self[task] = request
        request.resume()
        return request
    }
    
    private func request(with error: Error) -> Request
    {
        let request = Request(session: session, task: nil, error: error)
        request.resume()
        return request
    }
    
    // MARK: - URLSessionDataDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let request = self[task]
        {
            request.didComplete(withError: error)
        }
        self[task] = nil
    }
    
    // MARK: - URLSessionDataDelegate
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        if let request = self[dataTask]
        {
            request.didReceive(data: data)
        }
    }
    
}

