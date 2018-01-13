
//
//  TopicDetailContentView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class TopicDetailContentView: BaseView
{
    lazy var contentWebView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.allowsLinkPreview = true // enable link 3D touch
        
        return webView
    }()
    
    var imgSrcArray = [String]()
    var contentHeight = CGFloat.leastNormalMagnitude // could not be 0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(contentWebView)
        let bindings = ["contentWebView": contentWebView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentWebView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentWebView]|", metrics: nil, views: bindings))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func load(with model: TopicDetailModel?)
    {
        if var html = model?.topicContent
        {
            html = customizeHtml(html)
            if let htmlDoc = HTMLDoc(htmlString: html)
            {
                // If there is no image in this topic, just load the content.
                // Otherwise, write the content to a file. Grant the webView to access image cache.
                guard let imageNodes = htmlDoc.xPath(".//img"), imageNodes.count > 0 else {
                    contentWebView.loadHTMLString(html, baseURL: nil)
                    return
                }
                
                // add "https:" for "src" attribute starts with "//" in img nodes
                let originalSrcArray = imageNodes.map { $0["src"] }
                for originalSrc in originalSrcArray
                {
                    if let originalSrc = originalSrc, originalSrc.isEmpty == false
                    {
                        let httpsSrc = originalSrc.hasPrefix("//") ? R.String.Https + originalSrc : originalSrc
                        imgSrcArray.append(httpsSrc)
                        let keyString = " image_cache_key=\"" + httpsSrc
                        let cachedSrc = Bundle.main.resourcePath! + "/" + R.String.ImagePlaceholder + "\"" + keyString
                        html = html.replacingOccurrences(of: originalSrc, with: cachedSrc)
                    }
                }
                
                // excluding img nodes
                if let allNodes = htmlDoc.xPath(".//*[not(name()='img')]")
                {
                    // add "https:" for all "src" attribute starts with "//"
                    let originalSrcArray = allNodes.map { $0["src"] }
                    for originalSrc in originalSrcArray
                    {
                        if let originalSrc = originalSrc, originalSrc.hasPrefix("//")
                        {
                            let resultSrc = R.String.Https + originalSrc
                            html = html.replacingOccurrences(of: originalSrc, with: resultSrc)
                        }
                    }
                    
                    // add "https://" for all "href" attribute starts with "/"
                    let originalHrefArray = allNodes.map { $0["href"] }
                    for originalHref in originalHrefArray
                    {
                        if let originalHref = originalHref, originalHref.hasPrefix("/")
                        {
                            let originlHrefToReplace = "href=\"" + originalHref + "\""
                            let resultSrc = "href=\"https://" + originalHref + "\""
                            html = html.replacingOccurrences(of: originlHrefToReplace, with: resultSrc)
                        }
                    }
                }

                /**
                 * WebView needs permission to read image from cache.
                 * Solution:
                 * Write html string to a html file,
                 * save html file to Library folder(image cache is in Library).
                 * WebView load content from file URL,
                 * and replace image placeholder with image from cache.
                 */
                if let dir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
                {
                    let file = "topic.html"
                    let path = dir.appendingPathComponent(file)
                    do {
                        try html.write(to: path, atomically: false, encoding: String.Encoding.unicode)
                        contentWebView.loadFileURL(path, allowingReadAccessTo: dir)
                    } catch {}
                }
            }
        }
    }
    
    private func customizeHtml(_ html: String) -> String
    {
        let htmlHeader = "<html><head><title>VeXplore_Customize_Title</title><meta content='width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0' name='viewport'>"
        let script = try! String(contentsOfFile: Bundle.main.path(forResource: "ImageClick", ofType: "js")!, encoding: .utf8)
        let style = "<style>" + CSSStyle.default + "</style><script>" + script + "</script></head>"
        let customizedHtml =  htmlHeader + style  + html + "</html>"
        return customizedHtml
    }

}
