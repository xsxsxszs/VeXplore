//
//  JSON.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


private enum Type :Int
{
    case string
    case array
    case dictionary
    case null
}

public struct JSON
{
    public var string: String? {
        switch type
        {
        case .string:
            return object as? String
        default:
            return nil
        }
    }
    
    private var object: Any {
        get
        {
            switch type
            {
            case .string:
                return rawString
            case .array:
                return rawArray
            case .dictionary:
                return rawDictionary
            default:
                return rawNull
            }
        }
        set
        {
            switch newValue
            {
            case let int as Int:
                type = .string
                self.rawString = String(int)
            case let string as String:
                type = .string
                self.rawString = string
            case let array as [Any]:
                type = .array
                self.rawArray = array
            case let dictionary as [String : Any]:
                type = .dictionary
                self.rawDictionary = dictionary
            case is NSNull:
                type = .null
            default:
                break
            }
        }
    }
    
    fileprivate var rawArray = [Any]()
    private var rawDictionary = [String : Any]()
    private var rawString = ""
    private let rawNull = NSNull()
    fileprivate var type: Type = .null
    public static let null = JSON(object: NSNull())
    
    public init(object: Any)
    {
        self.object = object
    }
    
    public subscript(key: String) -> JSON {
        var json = JSON.null
        if type == .dictionary, let value = rawDictionary[key]
        {
            json = JSON(object: value)
        }
        return json
    }
    
}

// using 'for...in' to access
extension JSON: Swift.Sequence
{
    public func makeIterator() -> JSONIterator
    {
        return JSON.Iterator(json: self)
    }
    
}

public struct JSONIterator: IteratorProtocol
{
    private var type: Type
    private var arrayIterator: IndexingIterator<[Any]>?
    private var arrayIndex = 0
    
    init(json: JSON)
    {
        type = json.type
        if type == .array
        {
            arrayIterator = json.rawArray.makeIterator()
        }
    }
    
    mutating public func next() -> (String, JSON)?
    {
        if type == .array, let next = arrayIterator?.next()
        {
            let i = arrayIndex
            arrayIndex += 1
            return (String(i), JSON(object: next))
        }
        return nil
    }
    
}

