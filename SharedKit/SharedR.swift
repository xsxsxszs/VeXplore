//
//  SharedR.swift
//  VeXplore
//
//  Copyright © 2017 Jimmy. All rights reserved.
//


public struct SharedR
{
    public struct Dict
    {
        public static let MobileClientHeaders = ["user-agent": String.MobileUserAgent]
        public static let DesktopClientHeaders = ["user-agent": String.DesktopUserAgent]
    }
    
    struct String
    {
        static let MobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
        static let DesktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36"
    }
}
