//
//  ModelResponse.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class CommonResponse
{
    var success = false
    var message = [String]()
    
    init(success: Bool, message: [String] = [String]())
    {
        self.success = success
        self.message = message
    }

}

class ValueResponse<T>: CommonResponse
{
    var value: T?
    
    init(value: T? = nil, success: Bool, message: [String] = [String]())
    {
        super.init(success: success, message: message)
        self.value = value
    }
    
}
