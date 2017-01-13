//
//  V2Request.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

struct V2Request
{
    struct Topic
    {
        /////////////////
        ////// Tab //////
        /////////////////
        static func getTabList(withTabId tabId: String? = nil, completionHandler: @escaping (ValueResponse<[TopicItemModel]>) -> Void) -> Void
        {
            var params = [String: String]()
            if let tabId = tabId
            {
                params["tab"] = tabId
            }
            else
            {
                params["tab"] = "tech"
            }
            let url = R.String.BaseUrl
            Networking.request(url, parameters: params, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                var resultArray: [TopicItemModel] = []
                if let htmlDoc = response.result.value
                {
                    if let aRootNode = htmlDoc.xPath(".//div[@class='cell item']")
                    {
                        for aNode in aRootNode
                        {
                            let topic = TopicItemModel(rootNode: aNode)
                            resultArray.append(topic)
                        }
                        User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                    }
                    if let aRootNode = htmlDoc.xPath(".//a[@href='/mission/daily']")?.first, aRootNode.content == "领取今日的登录奖励"
                    {
                        Account.dailyRedeem()
                    }
                }
                let response = ValueResponse<[TopicItemModel]>(value:resultArray, success: response.result.isSuccess)
                completionHandler(response)
            }
        }
        
        //////////////////////////
        ////// Topic Detail //////
        //////////////////////////
        static func getDetail(withTopicId topicId: String, completionHandler: @escaping (ValueResponse<TopicDetailModel?>) -> Void )->Void
        {
            let url = R.String.BaseUrl + "/t/" + topicId
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<TopicDetailModel?>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var topicModel: TopicDetailModel?
                if let htmlDoc = response.result.value
                {
                    if let aRootNode = htmlDoc.xPath(".//*[@id='Wrapper']/div[@class='content']/div[@class='box'][1]")?.first
                    {
                        topicModel = TopicDetailModel(id: topicId, rootNode: aRootNode)
                    }

                    User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                }
                
                let handler = ValueResponse<TopicDetailModel?>(value: topicModel, success: response.result.isSuccess)
                completionHandler(handler)
            }
        }
        
        static func favoriteTopic(_ favorite: Bool, topicId: String, token: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = favorite ? (R.String.BaseUrl + "/favorite/topic/" + topicId + "?t=" + token) : (R.String.BaseUrl + "/unfavorite/topic/" + topicId + "?t=" + token)
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                if response.result.isSuccess
                {
                    completionHandler(CommonResponse(success: true))
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                }
            })
        }
        
        static func ignoreTopic(withTopicId topicId: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Account.getOnce(completion: { (response) -> Void in
                if response.success ,let once = User.shared.once
                {
                    let url  = R.String.BaseUrl + "/ignore/topic/" + topicId + "?once=" + once
                    Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                        if response.result.isSuccess
                        {
                            completionHandler(CommonResponse(success: true))
                        }
                        else
                        {
                            completionHandler(CommonResponse(success: false))
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
        
        static func reportTopic(withURL url: String, completionHandler:@escaping (CommonResponse) -> Void)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let url  = R.String.BaseUrl + "/report/topic/" + url
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                if response.result.isSuccess
                {
                    completionHandler(CommonResponse(success: true))
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
        
        static func fakeRequest()
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Account.getOnce(completion: { (response) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
        
        //////////////////////////
        ////// Topic Comment /////
        //////////////////////////
        static func getComments(withTopicId topicId: String, page: Int, completionHandler: @escaping (ValueResponse<([TopicCommentModel], Int)>) -> Void)
        {
            let url = R.String.BaseUrl + "/t/" + topicId + "?p=\(page)"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<([TopicCommentModel], Int)>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var topicCommentsArray : [TopicCommentModel] = []
                var totalCommentPage: Int = 1
                if let htmlDoc = response.result.value
                {
                    if let aRootNode = htmlDoc.xPath(".//div[@class='box']/div[attribute::id]")
                    {
                        for aNode in aRootNode
                        {
                            topicCommentsArray.append(TopicCommentModel(rootNode: aNode))
                        }
                    }
                    
                    if let totalCommentPageText = htmlDoc.xPath(".//a[@class='page_normal']")?.last?.content
                    {
                        totalCommentPage = Int(totalCommentPageText) ?? 1
                    }
                }
                let handler = ValueResponse(value: (topicCommentsArray, totalCommentPage), success: response.result.isSuccess)
                completionHandler(handler)
            }
        }
        
        static func ignoreReply(withReplyId replyId:String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Account.getOnce(completion: { (response) -> Void in
                if response.success ,let once = User.shared.once
                {
                    let url  = R.String.BaseUrl + "/ignore/reply/" + replyId + "?once=" + once
                    Networking.request(url, method: .post, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                        if response.result.isSuccess
                        {
                            completionHandler(CommonResponse(success: true))
                        }
                        else
                        {
                            completionHandler(CommonResponse(success: false))
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
        
        static func thankReply(withReplyId replyId:String, token: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = R.String.BaseUrl + "/thank/reply/" + replyId + "?t=" + token
            Networking.request(url, method: .post, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                if response.result.isSuccess
                {
                    completionHandler(CommonResponse(success: true))
                    return
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                }
            })
        }
        
        static func reply(withTopicId topicId: String, content: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = R.String.BaseUrl + "/t/" + topicId
            Account.getOnce(completion: { (response) -> Void in
                if response.success, let once = User.shared.once
                {
                    let parameters = [
                        "content": content,
                        "once": once
                    ]
                    Networking.request(url, method: .post, parameters: parameters, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                        if let location = response.response?.allHeaderFields["Etag"] as? String
                        {
                            // reply success
                            if location.isEmpty == false
                            {
                                completionHandler(CommonResponse(success: true))
                            }
                            else
                            {
                                completionHandler(CommonResponse(success: false))
                            }
                            return
                        }
                        //可能错误 你回复过于频繁了，请稍等1800 秒之后再试
                        completionHandler(CommonResponse(success: false))
                    }
                    return
                }
                completionHandler(CommonResponse(success: false, message: ["获取once失败，请重试"]))
            })
        }
        
        ////////////////////
        ////// Recent //////
        ////////////////////
        static func getRecentList(withPage page: Int, completionHandler: @escaping (ValueResponse<([TopicItemModel])>) -> Void) -> Request
        {
            let url = R.String.BaseUrl + "/recent?p=\(page)"
            let request = Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                var resultArray: [TopicItemModel] = []
                if let htmlDoc = response.result.value
                {
                    if let aRootNode = htmlDoc.xPath(".//div[@class='cell item']")
                    {
                        for aNode in aRootNode
                        {
                            let topic = TopicItemModel(rootNode: aNode)
                            resultArray.append(topic)
                        }
                    }
                }
                
                let response = ValueResponse<[TopicItemModel]>(value:resultArray, success: response.result.isSuccess)
                completionHandler(response)
            }
            return request
        }
        
        ////////////////////////
        ////// Post Topic //////
        ////////////////////////
        static func postTopic(withNodeId nodeId: String, title: String, content: String?, completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = R.String.BaseUrl + "/new/" + nodeId
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml{ (response) in
                if let htmlDoc = response.result.value, let once = htmlDoc.xPath(".//*[@name='once']")?.first?["value"]
                {
                    var dict = SharedR.Dict.MobileClientHeaders
                    dict["Referer"] = url
                    
                    let parameters = [
                        "title": title,
                        "content": content ?? R.String.Empty,
                        "once": once,
                        "syntax": "0"
                    ]
                    
                    Networking.request(url, method: .post, parameters: parameters, headers: dict).responseString { (response: DataResponse<String>) -> Void in
                        if response.result.isSuccess
                        {
                            completionHandler(CommonResponse(success: true))
                        }
                        else
                        {
                            completionHandler(CommonResponse(success: false))
                        }
                    }
                    return
                }
                completionHandler(CommonResponse(success: false))
            }
        }
    }
    
    
    struct Node
    {
        static func getTopicList(withNodeId nodeId: String, page: Int, completionHandler: @escaping (ValueResponse<([TopicItemModel], Bool, Int, String?, String?)>) -> Void) -> Void
        {
            let url =  R.String.BaseUrl + "/go/" + nodeId + "?p=" + "\(page)"
            
            Networking.request(url, headers: SharedR.Dict.DesktopClientHeaders).responseParsableHtml { (response) in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<([TopicItemModel], Bool, Int, String?, String?)>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var resultArray: [TopicItemModel] = []
                var isFavorite = false
                var totalPageNum = 1
                var favoriteActionUrl: String?
                var nodeName: String?
                if let htmlDoc = response.result.value
                {
                    nodeName = htmlDoc.xPath(".//title")?.first?.content?.replacingOccurrences(of: "V2EX › ", with: R.String.Empty)
                    if let node = htmlDoc.xPath(".//a[text()='取消收藏']")?.first
                    {
                        isFavorite = true
                        favoriteActionUrl = node.xPath("../a").first?["href"]
                    }
                    else if let node = htmlDoc.xPath(".//a[text()='加入收藏']")?.first
                    {
                        favoriteActionUrl = node.xPath("../a").first?["href"]
                    }
                    
                    if let pageNumString = htmlDoc.xPath(".//input[@max]")?.first?["max"]
                    {
                        totalPageNum = Int(pageNumString) ?? 1
                    }
                    
                    if let aRootNode = htmlDoc.xPath(".//div[@id='TopicsNode']/div")
                    {
                        for aNode in aRootNode
                        {
                            let topic = TopicItemModel(nodeRootNode: aNode)
                            resultArray.append(topic)
                        }
                        User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                    }
                }
                
                let response = ValueResponse<([TopicItemModel], Bool, Int, String?, String?)>(value:(resultArray, isFavorite, totalPageNum, favoriteActionUrl, nodeName), success: response.result.isSuccess)
                completionHandler(response)
            }
        }
        
        static func getDefaultNodes(completion completionHandler: ((ValueResponse<[NodeGroupModel]>) -> Void)?)
        {
            let url = R.String.BaseUrl
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                // Etag always change
                var groupArray = [NodeGroupModel]()
                if let htmlDoc = response.result.value
                {
                    if let nodes = htmlDoc.xPath(".//div[@class='box'][last()]/div/table/tr")
                    {
                        for rootNode in nodes
                        {
                            let group = NodeGroupModel(rootNode: rootNode)
                            groupArray.append(group)
                        }
                    }
                    completionHandler?(ValueResponse(value: groupArray, success: true))
                    return
                }
                completionHandler?(ValueResponse(success: false))
            }
        }
        
        static func getAllNodes(completion completionHandler: ((ValueResponse<[NodeModel]>) -> Void)?)
        {
            let url = R.String.BaseUrl + "/api/nodes/all.json"
            var nodes = [NodeModel]()
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseJSON { (response) in
                let savedEtag = UserDefaults.standard[R.Key.AllNodesEtag]
                if let etag = response.response?.allHeaderFields["Etag"] as? String
                {
                    if savedEtag == etag
                    {
                        completionHandler?(ValueResponse(success: false))
                        return
                    }
                    else
                    {
                        UserDefaults.standard[R.Key.AllNodesEtag] = etag
                    }
                }
                
                if response.result.isSuccess, let value = response.result.value
                {
                    let json = JSON(object: value)
                    for (_, subJson) in json
                    {
                        let node = NodeModel(json: subJson)
                        nodes.append(node)
                    }
                    completionHandler?(ValueResponse(value: nodes, success: true))
                    return
                }
                completionHandler?(ValueResponse(success: false))
            }
        }
        
        static func favoriteNode(withURL url: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = R.String.BaseUrl + url
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                completionHandler(CommonResponse(success: response.result.isSuccess))
            }
        }
        
    }
    
    
    struct Notification
    {
        static func getNotifications(withPage page: Int = 1, completionHandler: @escaping (ValueResponse<([NotificationModel], Int)>) -> Void)
        {
            let url = R.String.BaseUrl + "/notifications?p=\(page)"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                if response.result.isSuccess, response.response?.url?.absoluteString.contains("v2ex.com/signin") == true
                {
                    let response = ValueResponse<([NotificationModel], Int)>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                var resultArray = [NotificationModel]()
                var notificationsPage = 1
                if let htmlDoc = response.result.value
                {
                    if var notificationsPageText = htmlDoc.xPath(".//td[@align='center']/strong")?.first?.content, let range = notificationsPageText.range(of: "/")
                    {
                        notificationsPageText = notificationsPageText.substring(from: range.upperBound)
                        notificationsPage = Int(notificationsPageText) ?? 1
                    }
                    if page <= notificationsPage, let aRootNode = htmlDoc.xPath(".//div[@class='cell'][attribute::id]")
                    {
                        for aNode in aRootNode
                        {
                            let notice = NotificationModel(rootNode:aNode)
                            resultArray.append(notice)
                        }
                        User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                    }
                }
                let handler = ValueResponse<([NotificationModel], Int)>(value: (resultArray, notificationsPage), success: response.result.isSuccess)
                completionHandler(handler)
            }
        }
        
        static func deleteNotification(withId notificationId: String, completionHandler: @escaping (CommonResponse) -> Void)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Account.getOnce(completion: { (response) -> Void in
                if response.success ,let once = User.shared.once
                {
                    let url  = R.String.BaseUrl + "/delete/notification/" + notificationId + "?once=" + once
                    Networking.request(url, method: .post, headers: SharedR.Dict.MobileClientHeaders).responseString(completionHandler: { (response) in
                        if response.result.isSuccess
                        {
                            completionHandler(CommonResponse(success: true))
                        }
                        else
                        {
                            completionHandler(CommonResponse(success: false))
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
                else
                {
                    completionHandler(CommonResponse(success: false))
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
        
    }
    
    
    struct Search
    {
        enum SearchType: Int
        {
            case google = 0
            case bing
        }
        
        static func getResults(withKey key: String, searchType: SearchType, completionHandler: @escaping (ValueResponse<[TopicItemModel]>) -> Void) -> Request?
        {
            var urlString: String!
            switch searchType
            {
            case .google:
                urlString = "https://www.google.com/search?q=site:v2ex.com/t " + key
                break
            case .bing:
                urlString = "http://cn.bing.com/search?q=site:v2ex.com/t " + key
            }
            guard let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
                return nil
            }
            let request = Networking.request(url, headers: SharedR.Dict.DesktopClientHeaders).responseParsableHtml { (response) in
                var searchResults = [TopicItemModel]()
                if let htmlDoc = response.result.value, let topics = htmlDoc.xPath(".//a[starts-with(@href,'https://www.v2ex.com/t')]")
                {
                    for topic in topics
                    {
                        if let topicTitle = topic.content, let topicUrlWithPage = topic["href"], let topicUrl = topicUrlWithPage.components(separatedBy: "?").first
                        {
                            let topicId = topicUrl.replacingOccurrences(of: "https://www.v2ex.com/t/", with: R.String.Empty)
                            let topicItemModel = TopicItemModel(id: topicId, title: topicTitle)
                            if searchResults.contains(where: {$0.topicId == topicItemModel.topicId}) == false
                            {
                                searchResults.append(topicItemModel)
                            }
                        }
                    }
                }
                let response = ValueResponse<[TopicItemModel]>(value:searchResults, success: response.result.isSuccess)
                completionHandler(response)
            }
            return request
        }
        
    }
    
    
    struct Profile
    {
        @discardableResult
        static func getMemberInfo(withUsername username: String, completionHandler: ((ValueResponse<ProfileModel>) -> Void)? = nil) -> Request?
        {
            let url = R.String.BaseUrl + "/member/" + username
            let request = Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                if let htmlDoc = response.result.value, let aRootNode = htmlDoc.xPath(".//*[@id='Wrapper']/div")?.first
                {
                    let member = ProfileModel(rootNode: aRootNode)
                    User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                    completionHandler?(ValueResponse(value: member, success: true))
                }
                completionHandler?(ValueResponse(success: false))
            }
            return request
        }
        
        static func getFavoriteTopics(withPage page: Int = 1, completionHandler: @escaping (ValueResponse<([TopicItemModel], String, String, String, Int)>) -> Void)
        {
            let url = R.String.BaseUrl + "/my/topics?p=\(page)"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<([TopicItemModel], String, String, String, Int)>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var resultArray:[TopicItemModel] = []
                var maxPage = 1
                var favoriteNodesNum = R.String.Zero
                var favoriteTopicsNum = R.String.Zero
                var followingsNum = R.String.Zero
                if let htmlDoc = response.result.value
                {
                    favoriteNodesNum = htmlDoc.xPath(".//a[@href='/my/nodes']/span[@class='bigger']")?.first?.content ?? R.String.Zero
                    favoriteTopicsNum = htmlDoc.xPath(".//a[@href='/my/topics']/span[@class='bigger']")?.first?.content ?? R.String.Zero
                    followingsNum = htmlDoc.xPath(".//a[@href='/my/following']/span[@class='bigger']")?.first?.content ?? R.String.Zero
                    
                    if let aRootNode = htmlDoc.xPath(".//*[@id='Main']/div[@class='box']/div[@class='cell item']")
                    {
                        for aNode in aRootNode
                        {
                            let topic = TopicItemModel(favoritesRootNode: aNode)
                            resultArray.append(topic)
                        }
                    }
                    
                    User.shared.getNotificationsNum(withNode: htmlDoc.rootNode!)
                    
                    if page <= 1, let pageText = htmlDoc.xPath(".//a[@class='page_normal']")?.last?.content, let pageInt = Int(pageText)
                    {
                        maxPage = pageInt
                    }
                }
                
                let response = ValueResponse<([TopicItemModel], String, String, String, Int)>(value: (resultArray, favoriteNodesNum, favoriteTopicsNum, followingsNum, maxPage), success: response.result.isSuccess)
                completionHandler(response)
            }
        }
        
        static func getFavoriteNodes(completion completionHandler: @escaping (ValueResponse<[NodeModel]>) -> Void)
        {
            let url = R.String.BaseUrl + "/my/nodes"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<[NodeModel]>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var resultArray = [NodeModel]()
                if let htmlDoc = response.result.value
                {
                    let nodesArray = htmlDoc.xPath(".//a[@class='grid_item']")
                    if let nodesArray = nodesArray
                    {
                        for aNode in nodesArray
                        {
                            let node = NodeModel(rootNode: aNode)
                            resultArray.append(node)
                        }
                    }
                    
                }
                let response = ValueResponse<[NodeModel]> (value: resultArray, success: response.result.isSuccess)
                completionHandler(response)
            }
        }
        
        static func getFollowings(completion completionHandler: @escaping (ValueResponse<[(String, String)]>) -> Void)
        {
            let url = R.String.BaseUrl + "/my/following"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                if response.result.isSuccess, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    let response = ValueResponse<[(String, String)]>(success: false, message: [R.String.NeedLoginError])
                    completionHandler(response)
                    return
                }
                
                var resultArray = [(String, String)]()
                if let htmlDoc = response.result.value
                {
                    let followingsArray = htmlDoc.xPath(".//div[@class='cell']/span[text()='我关注的人']/../../node() ")
                    if var followingsArrayUnwrap = followingsArray, followingsArrayUnwrap.count > 0
                    {
                        followingsArrayUnwrap.removeFirst()
                        for aNode in followingsArrayUnwrap
                        {
                            let url = aNode.xPath("./a[1]/img").first?["src"]
                            let username = aNode.xPath("./a[2]").first?.content
                            if let url = url, let username = username
                            {
                                resultArray.append((url, username))
                            }
                        }
                    }
                }
                let response = ValueResponse<[(String, String)]> (value: resultArray, success: response.result.isSuccess)
                completionHandler(response)
            }
        }
        
        static func getMemberTopics(withUsername username: String, page: Int, completionHandler: ((ValueResponse<([MemberTopicItemModel], Int, String)>) -> Void)? = nil )
        {
            let url = R.String.BaseUrl + "/member/" + username + "/topics?p=\(page)"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                var topicArray: [MemberTopicItemModel] = []
                if let htmlDoc = response.result.value
                {
                    var topicsPage: Int = 1
                    if var topicsPageText = htmlDoc.xPath(".//td[@align='center']/strong")?.first?.content, let range = topicsPageText.range(of: "/")
                    {
                        topicsPageText = topicsPageText.substring(from: range.upperBound)
                        topicsPage = Int(topicsPageText) ?? 1
                    }
                    
                    let topicsNum = htmlDoc.xPath(".//span[contains(text(), '主题总数 ')]/following-sibling::strong")?.first?.content ?? R.String.Zero
                    if let nodes = htmlDoc.xPath(".//div[@class='cell item']")
                    {
                        for rootNode in nodes
                        {
                            let item = MemberTopicItemModel(rootNode: rootNode)
                            topicArray.append(item)
                        }
                    }
                    completionHandler?(ValueResponse(value: (topicArray, topicsPage, topicsNum), success: true))
                    return
                }
                completionHandler?(ValueResponse(success: false))
            }
        }
        
        static func getMemberReplies(withUsername username: String, page: Int, completionHandler: ((ValueResponse<([MemberReplyModel], Int, String)>) -> Void)? = nil )
        {
            let url = R.String.BaseUrl + "/member/" + username + "/replies?p=\(page)"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                var repliesArray: [MemberReplyModel] = []
                if let htmlDoc = response.result.value
                {
                    var repliesPage: Int = 1
                    if var repliesPageText = htmlDoc.xPath(".//td[@align='center']/strong")?.first?.content, let range = repliesPageText.range(of: "/")
                    {
                        repliesPageText = repliesPageText.substring(from: range.upperBound)
                        repliesPage = Int(repliesPageText) ?? 1
                    }
                    let repliesNum = htmlDoc.xPath(".//span[contains(text(), '回复总数 ')]/following-sibling::strong")?.first?.content ?? R.String.Zero
                    if let nodes = htmlDoc.xPath(".//div[@class='dock_area']")
                    {
                        for node in nodes
                        {
                            let replyModel = MemberReplyModel(rootNode: node)
                            repliesArray.append(replyModel)
                        }
                    }
                    completionHandler?(ValueResponse(value: (repliesArray, repliesPage, repliesNum), success: true))
                    return
                }
                completionHandler?(ValueResponse(success: false))
            }
        }
        
        static func followOrBlockMember(withUsername username: String, urlText: String, completionHandler: ((CommonResponse) -> Void)? = nil )
        {
            let url = R.String.BaseUrl + urlText
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) in
                if response.result.isSuccess
                {
                    let response = CommonResponse(success: true)
                    completionHandler?(response)
                    return
                }
                completionHandler?(CommonResponse(success: false))
            }
        }
        
    }
    
    
    struct Account
    {
        static func Login(withUsername username: String,
                         password: String,
                         completionHandler: @escaping (ValueResponse<String>) -> Void) -> Request
        {
            User.shared.removeAllCookies()
            let url = R.String.BaseUrl + "/signin"
            let request = Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml { (response) -> Void in
                if let htmlDoc = response.result.value,
                    let onceStr = htmlDoc.xPath(".//*[@name='once'][1]")?.first?["value"],
                    let usernameFieldName = htmlDoc.xPath(".//input[@class='sl' and @type='text']")?.first?["name"],
                    let passwordFieldName = htmlDoc.xPath(".//input[@class='sl' and @type='password']")?.first?["name"]
                {
                    Account.Login(withUsername: username, password: password, once: onceStr, usernameFieldName: usernameFieldName, passwordFieldName: passwordFieldName, completionHandler: completionHandler)
                    return
                }
                completionHandler(ValueResponse(success: false))
            }
            return request
        }
        
        static func Login(withUsername username: String,
                         password: String,
                         once: String,
                         usernameFieldName: String,
                         passwordFieldName: String,
                         completionHandler: @escaping (ValueResponse<String>) -> Void)
        {
            let parameters = [
                "once": once,
                "next": "/",
                passwordFieldName: password,
                usernameFieldName: username
            ]
            var dict = SharedR.Dict.MobileClientHeaders
            dict["Referer"] = "https://v2ex.com/signin"
            let url = R.String.BaseUrl + "/signin"
            Networking.request(url, method: .post, parameters: parameters, headers: dict).responseParsableHtml{ (response) -> Void in
                if let htmlDoc = response.result.value
                {
                    if let memberNode = htmlDoc.xPath(".//*[@id='Top']//a[contains(@href,'/member/')]")?.first, var username = memberNode["href"], username.hasPrefix("/member/")
                    {
                        username = username.replacingOccurrences(of: "/member/", with: R.String.Empty)
                        completionHandler(ValueResponse(value: username, success: true))
                        return
                    }
                }
                completionHandler(ValueResponse(success: false))
            }
        }
        
        static func dailyRedeem()
        {
            Account.getOnce(completion: { (response) -> Void in
                if response.success
                {
                    let url = R.String.BaseUrl + "/mission/daily/redeem?once=" + User.shared.once!
                    Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml{ (response) in
                        if let htmlDoc = response.result.value
                        {
                            if let aRootNode = htmlDoc.xPath(".//*[@id='Wrapper']/div/div/div[@class='message']")?.first
                            {
                                if aRootNode.content == "已成功领取每日登录奖励"
                                {
                                    print("自动签到完成")
                                }
                            }
                        }
                    }
                }
            })
        }
        
        // verify if logged in or overdue
        static func verifyLoginStatus()
        {
            // if logged in, https://www.v2ex.com/new will not be redirected
            let url = R.String.BaseUrl + "/new"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseString() { (response) -> Void in
                if response.response?.statusCode == 200, response.request?.url?.absoluteString != response.response?.url?.absoluteString
                {
                    dispatch_async_safely_to_main_queue {
                        User.shared.logout()
                    }
                }
            }
        }
        
        // get once for some usage
        static func getOnce(completion completionHandler: @escaping (CommonResponse) -> Void)
        {
            let url = R.String.BaseUrl + "/signin"
            Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseParsableHtml {(response) -> Void in
                if let htmlDoc = response.result.value, let once = htmlDoc.xPath(".//*[@name='once']")?.first?["value"]
                {
                    User.shared.once = once
                    completionHandler(CommonResponse(success: true))
                    return
                }
                completionHandler(CommonResponse(success: false))
            }
        }
        
    }
    
}
