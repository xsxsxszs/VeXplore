//
//  Request.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

public class Request
{
    let session: URLSession
    var data = Data()
    var error: Error?
    
    var task: URLSessionDataTask? {
        didSet
        {
            error = nil
            data = Data()
        }
    }
    
    var request: URLRequest? {
        return task?.originalRequest
    }
    
    public var response: HTTPURLResponse? {
        return task?.response as? HTTPURLResponse
    }
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.isSuspended = true
        queue.qualityOfService = .utility
        return queue
    }()
    
    init(session: URLSession, task: URLSessionDataTask?, error: Error? = nil)
    {
        self.session = session
        self.task = task
        self.error = error
    }
    
    func resume()
    {
        guard let task = task else {
            queue.isSuspended = false
            return
        }
        task.resume()
    }
    
    public func cancel()
    {
        guard let task = task else { return }
        task.cancel()
    }
    
    func didComplete(withError error: Error?)
    {
        self.error = error
        queue.isSuspended = false
    }
    
    func didReceive(data: Data)
    {
        self.data.append(data)
    }
    
}

private let NoContentStatusCodes: Set<Int> = [204, 205]

extension Request
{
    @discardableResult
    public func response<T>(responseSerializer: DataResponseSerializer<T>, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self
    {
        queue.addOperation {
            let result = responseSerializer.serializeResponse(self.request,
                                                              self.response,
                                                              self.data,
                                                              self.error)
            
            let dataResponse = DataResponse<T>(request: self.request,
                                               response: self.response,
                                               data: self.data,
                                               result: result)
            
            DispatchQueue.main.async { completionHandler(dataResponse) }
        }
        
        return self
    }
    
    // MARK: - String Response
    @discardableResult
    public func responseString(completionHandler: @escaping (DataResponse<String>) -> Void) -> Self
    {
        return response(responseSerializer: stringResponseSerializer(), completionHandler: completionHandler)
    }
    
    private func serializeResponseString(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<String>
    {
        guard error == nil else {
            return .failure(error!)
        }
        
        if let response = response, NoContentStatusCodes.contains(response.statusCode) { return .success("") }
        
        guard let validData = data else {
            return .failure(nil)
        }
        
        var convertedEncoding: String.Encoding?
        
        if let encodingName = response?.textEncodingName as CFString!
        {
            convertedEncoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName)))
        }
        let actualEncoding = convertedEncoding ?? String.Encoding.isoLatin1
        
        if let string = String(data: validData, encoding: actualEncoding)
        {
            return .success(string)
        }
        else
        {
            return .failure(nil)
        }
    }
    
    private func stringResponseSerializer() -> DataResponseSerializer<String>
    {
        return DataResponseSerializer { _, response, data, error in
            return self.serializeResponseString(response: response, data: data, error: error)
        }
    }
    
    // MARK: - Json Response
    @discardableResult
    public func responseJSON(completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self
    {
        return response(responseSerializer: jsonResponseSerializer(), completionHandler: completionHandler)
    }
    
    private func serializeResponseJSON(response: HTTPURLResponse?,
                                       data: Data?,
                                       error: Error?) -> Result<Any>
    {
        guard error == nil else {
            return .failure(error!)
        }
        
        if let response = response, NoContentStatusCodes.contains(response.statusCode)
        {
            return .success(NSNull())
        }
        
        guard let validData = data, validData.count > 0 else {
            return .failure(nil)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: validData, options: .allowFragments)
            return .success(json)
        } catch {
            return .failure(nil)
        }
    }
    
    private func jsonResponseSerializer() -> DataResponseSerializer<Any>
    {
        return DataResponseSerializer { _, response, data, error in
            return self.serializeResponseJSON(response: response, data: data, error: error)
        }
    }
    
}

