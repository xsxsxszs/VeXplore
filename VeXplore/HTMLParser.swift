//
//  HTMLParser.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//
//  Reference: http://xmlsoft.org/html/

import Foundation

class HTMLDoc
{
    lazy var rootNode: HTMLNode? = {
        guard let rootNodePointer = xmlDocGetRootElement(self.htmlDoc) else {
            return nil
        }
        return HTMLNode(xmlNode: rootNodePointer, htmlDocument: self)
    }()
    
    fileprivate(set) var htmlDoc: xmlDocPtr
    
    required init?(data: Data?, encoding: String.Encoding = .utf8)
    {
        if let data = data, data.count > 0
        {
            let cBuffer = (data as NSData).bytes.bindMemory(to: CChar.self, capacity: data.count)
            let cSize = CInt(data.count)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
            let cfEncodingAsString: CFString = CFStringConvertEncodingToIANACharSetName(cfEncoding)
            let cEncoding = CFStringGetCStringPtr(cfEncodingAsString, 0)
            let options = CInt(HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue)
            /**
             * parse an XML in-memory document and build a tree.
             *
             * buffer:	a pointer to a char array
             * size:	the size of the array
             * URL:	the base URL to use for the document
             * encoding:	the document encoding, or NULL
             * options:	a combination of htmlParserOption(s)
             * Returns:	the resulting document tree
             */
            htmlDoc = htmlReadMemory(cBuffer, cSize, nil, cEncoding, options)
        }
        else
        {
            return nil
        }
    }
    
    convenience init?(htmlData: Data)
    {
        self.init(data: htmlData)
    }
    
    convenience init?(htmlString: String)
    {
        let data = htmlString.data(using: .utf8, allowLossyConversion: false)
        self.init(data: data)
    }
    
    deinit
    {
        xmlFreeDoc(htmlDoc)
    }
    
    func xPath(_ xPath: String) -> [HTMLNode]?
    {
        return self.rootNode?.xPath(xPath)
    }
    
}

extension HTMLDoc: CustomStringConvertible
{
    public var description: String {
        return rootNode?.rawContent ?? "nil"
    }
}

extension String
{
    init?(xmlChar: UnsafePointer<xmlChar>?)
    {
        if let charPtr = xmlChar
        {
            self.init(cString: charPtr)
        }
        else
        {
            return nil
        }
    }
}



class HTMLNode
{
    let xmlNode: xmlNodePtr
    unowned let document: HTMLDoc
    
    // HTML string, children and tags are kept, can be used to render a web view.
    var rawContent: String? {
        let buffer = xmlBufferCreate()
        /**
         * Dump an HTML node, recursive behaviour,children are printed too, and formatting returns are added.
         
         * buf:	the HTML buffer output
         * doc:	the document
         * cur:	the current node
         * Returns:	the number of byte written or -1 in case of error
         */
        htmlNodeDump(buffer, self.document.htmlDoc, self.xmlNode)
        let result = String(xmlChar: buffer?.pointee.content)
        xmlBufferFree(buffer)
        return result
    }
    
    // Content text. Tags are removed, white spaces and new lines are kept.
    var content: String? {
        guard let contentChars = xmlNodeGetContent(self.xmlNode) else {
            return nil
        }
        let contentString = String(xmlChar: contentChars)
        free(contentChars)
        return contentString
    }
    
    var tag: String? {
        return String(xmlChar: xmlNode.pointee.name)
    }
    
    var attributes: [String: String] {
        var result = [String: String]()
        var attribute: xmlAttrPtr? = self.xmlNode.pointee.properties
        while attribute != nil
        {
            if let key = String(xmlChar: attribute!.pointee.name),
                let valueChars = xmlNodeGetContent(attribute!.pointee.children),
                let value = String(xmlChar: valueChars)
            {
                free(valueChars)
                result[key] = value
            }
            attribute = attribute!.pointee.next
        }
        return result
    }
    
    var nextSibling: HTMLNode? {
        guard var next = xmlNode.pointee.next else {
            return nil
        }
        while xmlNodeIsText(next) != 0
        {
            next = next.pointee.next
        }
        return HTMLNode(xmlNode: next, htmlDocument: document)
    }
    
    init(xmlNode: xmlNodePtr, htmlDocument: HTMLDoc)
    {
        self.xmlNode = xmlNode
        document = htmlDocument
    }
    
    subscript(key: String) -> String? {
        get
        {
            var attribute: xmlAttrPtr? = self.xmlNode.pointee.properties
            while attribute != nil
            {
                if key == String(xmlChar: attribute!.pointee.name)
                {
                    guard let contentChars = xmlNodeGetContent(attribute!.pointee.children) else {
                        return nil
                    }
                    let contentString = String(xmlChar: contentChars)
                    free(contentChars)
                    return contentString
                }
                attribute = attribute!.pointee.next
            }
            return nil
        }
    }
    
    func xPath(_ xPath: String) -> [HTMLNode]
    {
        guard let xPathContext = xmlXPathNewContext(document.htmlDoc) else {
            return []
        }
        xPathContext.pointee.node = xmlNode
        let xPathObject = xmlXPathEvalExpression(xPath, xPathContext)
        xmlXPathFreeContext(xPathContext)
        guard  xPathObject != nil else {
            return []
        }
        
        guard let nodeSet = xPathObject!.pointee.nodesetval, nodeSet.pointee.nodeNr > 0, nodeSet.pointee.nodeTab != nil else {
            xmlXPathFreeObject(xPathObject)
            return []
        }
        var resultNodes = [HTMLNode]()
        for i in 0 ..< Int(nodeSet.pointee.nodeNr)
        {
            if let node = nodeSet.pointee.nodeTab[i]
            {
                let node = HTMLNode(xmlNode: node, htmlDocument: document)
                resultNodes.append(node)
            }
        }
        xmlXPathFreeObject(xPathObject)
        return resultNodes
    }
    
}

extension HTMLNode: CustomStringConvertible
{
    var description: String {
        return rawContent ?? "nil"
    }
}
