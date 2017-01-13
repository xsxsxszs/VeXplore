//
//  WebImageUtils.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

extension String
{
    var md5: String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest
        {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
}


extension Data
{
    static var gifHeader: [UInt8] = [0x47, 0x49, 0x46]
    
    var isGifFormat: Bool {
        var buffer = [UInt8](repeating: 0, count: 3)
        (self as NSData).getBytes(&buffer, length: 3)
        if buffer == Data.gifHeader
        {
            return true
        }
        return false
    }
    
}

extension Int
{
    func isValidStatusCode() -> Bool
    {
        return (200..<400).contains(self)
    }
}
