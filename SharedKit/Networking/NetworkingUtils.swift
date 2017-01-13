//
//  NetworkingUtils.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

public enum HTTPMethod: String
{
    case get = "GET"
    case post = "POST"
}


extension String
{
    func toURL() throws -> URL
    {
        guard let url = URL(string: self) else {
            throw NSError()
        }
        return url
    }
}


extension URLRequest
{
    init(url: String, method: HTTPMethod, headers: [String: String]? = nil) throws
    {
        let url = try url.toURL()
        self.init(url: url)
        httpMethod = method.rawValue
        if let headers = headers
        {
            for (field, value) in headers
            {
                setValue(value, forHTTPHeaderField: field)
            }
        }
    }
    
    func encode(with parameters: [String: String]?) throws -> URLRequest
    {
        guard let parameters = parameters, parameters.isEmpty == false else {
            return self
        }
        
        var urlRequest = self
        if urlRequest.httpMethod == "GET"
        {
            guard let url = urlRequest.url else {
                throw NSError()
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            }
        }
        else
        {
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil
            {
                urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            urlRequest.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
        }
        return urlRequest
    }
    
    private func query(_ parameters: [String: String]) -> String
    {
        let escapedParameters = parameters.map { (escape($0.key), escape($0.value)) }
        let result = escapedParameters.map { "\($0)=\($1)" }.joined(separator: "&")
        return result
    }
    
    private func escape(_ string: String) -> String
    {
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "!*'();:@&=+$,#[]") // remove reserved characters
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
    
}


public struct Networking
{
    @discardableResult
    public static func request(_ url: String,
                        method: HTTPMethod = .get,
                        parameters: [String: String]? = nil,
                        headers: [String: String]? = nil) -> Request
    {
        return SessionManager.shared.request(url, method: method, parameters: parameters, headers: headers)
    }
}
