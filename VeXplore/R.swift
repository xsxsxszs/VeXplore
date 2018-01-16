//
//  R.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


struct R
{
    struct Array
    {
        static let AllTabsTitle = [
            "技术",
            "创意",
            "好玩",
            "Apple",
            "酷工作",
            "交易",
            "城市",
            "问与答",
            "最热",
            "全部",
            "R2"
        ]
        
        static let FontSettingScales = ["0.7", "0.8", "0.9", "1.0", "1.1", "1.2", "1.3"]
        
    }
    
    struct Dict
    {
        static let TabsRequestMapping = [
            "技术": "tech",
            "创意": "creative",
            "好玩": "play",
            "Apple": "apple",
            "酷工作": "jobs",
            "交易": "deals",
            "城市": "city",
            "问与答": "qna",
            "最热": "hot",
            "全部": "all",
            "R2": "r2"
        ]
        static let PersonInfoIcons: [PersonInfoType: UIImage] = [
            .homepage : Image.Homepage,
            .twitter : Image.Twitter,
            .location : Image.Location,
            .github : Image.Github,
            .twitch : Image.Twitch,
            .psn : Image.Psn
        ]
    }
    
    struct Key
    {
        static let Username = "vexplore.userDefaults.key.username"
        static let ShowedTabs = "vexplore.userDefaults.key.showedTabs"
        static let HiddenTabs = "vexplore.userDefaults.key.hiddenTabs"
        static let CurrentTab = "vexplore.userDefaults.key.currentTab"
        static let EnableShake = "vexplore.userDefaults.key.enableShake"
        static let EnablePullReply = "vexplore.userDefaults.key.enablePullReply"
        static let EnableTabBarHidden = "vexplore.userDefaults.key.enableTabBarHidden"
        static let EnableHighlightOwnerReplies = "vexplore.userDefaults.key.EnableHighlightOwnerReplies"
        static let DynamicTitleFontScale = "vexplore.userDefaults.key.dynamicTitleFontScale"
        static let AllNodesEtag = "vexplore.userDefaults.key.allNodesEtag"
        static let HomePageTopicList = "vexplore.topicList.homePage.key.%@"
        static let LastCacheVersion = "vexplore.userDefaults.key.lastCacheVersion"
    }
    
    struct String
    {
        static let AllRepliesZero = "所有回复（0)"
        static let AllTopicsZero = "所有主题（0)"
        static let AllTopicsHidden = "主题列表被隐藏"
        static let NeedLoginToViewTopics = "主题列表被设置为登录可见"
        static let AllTopicsMoreThan = "所有主题（>= %d)"
        static let AllRepliesMoreThan = "所有回复（>= %d)"
        static let PersonalInfo = "个人信息"
        static let ForumActivity = "社区动态"
        static let PersonalBio = "个人简介"
        static let NotLogin = "未登录"
        static let UnableToViewThisNode = "您尚未登录或无权限查看该节点"
        static let UnableToViewThisTopic = "您尚未登录或无权限查看该主题"
        static let SwipeToDoMore = "左滑执行更多操作"
        static let NoRepliesNow = "暂无任何评论"
        static let ConversationContext = "对话上下文"
        static let ViewConversationContext = "查看对话上下文"
        static let ViewUserAllReplies = "查看用户全部回复"
        static let CopyReplyText = "复制评论文字"
        static let Cancel = "取消"
        static let PullToReplyTopic = "下拉回复主题"
        static let ShakeToRepleyTopic = "摇一摇直接回复主题"
        static let ChooseNode = "选择节点"
        static let TabsSorting = "标签排序"
        static let ShowedTabsTitle = "显示的标签"
        static let HiddenTabsTitle = "隐藏的标签"
        static let DragTabToSort = "长按标签拖动排序"
        static let Placeholder = "Placeholder"
        static let IgnoreTopic = "忽略主题"
        static let ReplyTopic = "回复主题"
        static let FavoriteTopic = "收藏／取消"
        static let ReportTopic = "报告主题"
        static let OpenInSafari = "Safari打开"
        static let OwnerViewSwitch = "开关只看楼主"
        static let User = "用户"
        static let Topic = "主题"
        static let NoFavorite = "0 人收藏"
        static let Zero = "0"
        static let Owner = "楼主"
        static let Content = "正文"
        static let Comment = "评论"
        static let ViewDetail = "查看详情"
        static let PersonalTagline = "个人签名："
        static let FavoriteNodes = "节点收藏"
        static let FavoriteTopics = "主题收藏"
        static let Followings = "特别关注"
        static let PublicDate = "%@ 发布"
        static let MyFavoriteTopics = "我收藏的主题"
        static let MyFavoriteNodes = "我收藏的节点"
        static let MyFollowings = "我关注的人"
        static let MemberAllTopics = "%@ 的所有主题"
        static let MemberAllReplies = "%@ 的所有回复"
        static let CreateNewTopic = "创作新主题"
        static let Reply = "回复"
        static let ReplyPlaceholder = "请尽量让自己的回复能够对别人有帮助"
        static let Notification = "通知"
        static let NeedLoginToViewNotifications = "需要登录才能查看通知"
        static let NoNotificationNow = "暂无任何通知"
        static let Nodes = "节点"
        static let NodeChoose = "节点选择"
        static let Recent = "最近"
        static let Homepage = "主页"
        static let TitleCharactersLessThan = "标题(<=%d)"
        static let ContentCharactersLessThan = "正文(<=%d)"
        static let Username = "用户名"
        static let Password = "密码"
        static let Login = "登录"
        static let Setting = "设置"
        static let Profile = "资料"
        static let CopyUrlAfterUploadingImage = "上传图片后复制地址"
        static let CurrentPage = "当前页："
        static let PageNumer = "Page %d"
        static let MemberAndTopicsSearch = "用户与主题搜索"
        static let SiteSearchPlaceholder = "搜索结果来自 Bing 和 Google"
        static let Confirm = "确定"
        static let EmailNotSetAlert = "您尚未启用系统邮箱服务，点击 “确定” 复制邮箱地址至剪贴板。"
        static let ImageCacheCleaning = "图片缓存清理中..."
        static let ImageCacheCleaningCompleted = "图片缓存清理完毕"
        static let NotSupportedForFreeVersion = "免费版暂不能使用此功能"
        static let MyGmail = "wmywbyt.cj@gmail.com"
        static let GeneralSetting = "通用设置"
        static let CleanImageCache = "清理图片缓存"
        static let ShakeToCallInputView = "摇一摇发帖或回复"
        static let PullToReplyInTopicView = "主题页面下拉回复"
        static let HighlightOwnerReplies = "楼主回复高亮"
        static let HomepageHideTabBarWhenScroll = "首页滚动隐藏底部菜单"
        static let ShowReplyIndex = "回复他人时显示楼层"
        static let NightMode = "夜间模式"
        static let AlwaysEnable = "始终开启"
        static let ScheduleEnable = "定时开启"
        static let ScheduleNightMode = "定时夜览"
        static let Schedule = "定时"
        static let TurnOnAt = "打开："
        static let TurnOffAt = "关闭："
        static let TurnedOff = "关闭"
        static let ScheduledTime = "%@\n%@"
        static let TopicTitleFont = "主题列表标题字体"
        static let FontSettingTitle = "标题字体放大比例"
        static let Sccale = "x %@"
        static let Feedback = "意见反馈"
        static let ContactDeveloper = "联系作者"
        static let RatingApp = "评价App"
        static let OpenSource = "开源地址"
        static let AtSomeone = "@%@ "
        static let AtSomeoneWithIndex = "@%@ #%@ "
        static let CommentIndex = "%@ 楼"
        static let IndexNumber = "No. "
        static let NoTitle = "无标题"
        static let HashKey = "#"
        static let WangXizhi = "王羲之"
        static let PrefaceOfLantingPublicTime = "永和九年三月初發布"
        static let PrefaceOfLanting = "蘭亭集序"
        static let PrefaceOfLantingExcerpt = "夫人之相與，俯仰一世，或取諸懷抱，晤言一室之內；或因寄所託，放浪形骸之外。"
        
        static let ImagePlaceholder = "Image_Placeholder.png"
        static let ImageUploadUrl = "http://image.jimmyis.in"
        static let NotAuthorizedError = "vexplore.message.notAuthorizedError"
        static let BaseUrl = "https://www.v2ex.com"
        static let Https = "https:"
        static let ErrorDomain = "in.jimmyis.vexplore.Error"
        static let AppStoreUrl = "itms-apps://itunes.apple.com/app/id1119508407?action=write-review"
        static let OpenSourceUrl = "https://github.com/xsxsxszs/VeXplore"
    }
    
    struct Constant
    {
        static let TopicTitleCharactersMax = 120
        static let TopicContentCharactersMax = 20000
        static let TopicPageMax = 9999
        static let EstimatedRowHeight: CGFloat = 44.0
        static let EstimatedSectionHeaderHeight: CGFloat = 20.0
        static let DataPickerCellHeight: CGFloat = 30.0
        static let DataPickerHeight: CGFloat = 150.0
        static let LoadingViewHeight: CGFloat = 44.0
        static let defaulViewtSize: CGFloat = 44.0
        static let CommentImageSize: CGFloat = 40.0
        static let AvatarSize: CGFloat = 40.0
        static let InputViewHeightMax: CGFloat = 350.0
        static let InputViewWidthMax: CGFloat = 700.0
        static let InputViewTitleHeight: CGFloat = 50.0
        static let InsetAnimationDuration: TimeInterval = 0.15
        static let SliderCircleRadius:CGFloat = 20.0
    }
    
    static var Image: RImage { return RImage() }
    struct RImage
    {
        fileprivate init(){}
        var ImagePlaceholder: UIImage! { return #imageLiteral(resourceName: "Image_Placeholder.png") }
        var LoginBackground: UIImage! { return #imageLiteral(resourceName: "Login_Background") }
        var Eye: UIImage! { return #imageLiteral(resourceName: "Owner_View") }
        var Safari: UIImage! { return #imageLiteral(resourceName: "Safari") }
        var ThumbDown: UIImage! { return #imageLiteral(resourceName: "Report_Activity") }
        var ReplyArrow: UIImage! { return #imageLiteral(resourceName: "Reply_Activity") }
        var Trash: UIImage! { return #imageLiteral(resourceName: "Ignore") }
        var WangXizhi: UIImage! { return #imageLiteral(resourceName: "Wang_Xizhi") }
        var Close: UIImage! { return #imageLiteral(resourceName: "Cross").withRenderingMode(.alwaysTemplate) }
        var Confirm: UIImage! { return #imageLiteral(resourceName: "Tick").withRenderingMode(.alwaysTemplate) }
        var ArrowRight: UIImage! { return #imageLiteral(resourceName: "Arrow_Right").withRenderingMode(.alwaysTemplate) }
        var AvatarPlaceholder: UIImage! { return #imageLiteral(resourceName: "Avatar_Placeholder").withRenderingMode(.alwaysTemplate) }
        var RoundClose: UIImage! { return #imageLiteral(resourceName: "Close").withRenderingMode(.alwaysTemplate) }
        var Send: UIImage! { return #imageLiteral(resourceName: "Send").withRenderingMode(.alwaysTemplate) }
        var ImageIcon: UIImage! { return #imageLiteral(resourceName: "Image").withRenderingMode(.alwaysTemplate) }
        var Search: UIImage! { return #imageLiteral(resourceName: "Search").withRenderingMode(.alwaysTemplate) }
        var Onepassword: UIImage! { return #imageLiteral(resourceName: "Onepassword").withRenderingMode(.alwaysTemplate) }
        var Lock: UIImage! { return #imageLiteral(resourceName: "Lock").withRenderingMode(.alwaysTemplate) }
        var Invisible: UIImage! { return #imageLiteral(resourceName: "Invisible").withRenderingMode(.alwaysTemplate) }
        var Comment: UIImage! { return #imageLiteral(resourceName: "Comment").withRenderingMode(.alwaysTemplate) }
        var Like: UIImage! { return #imageLiteral(resourceName: "Like").withRenderingMode(.alwaysTemplate)  }
        var Write: UIImage! { return #imageLiteral(resourceName: "Write").withRenderingMode(.alwaysTemplate)  }
        var Topics: UIImage! { return #imageLiteral(resourceName: "Topics").withRenderingMode(.alwaysTemplate) }
        var Replies: UIImage! { return #imageLiteral(resourceName: "Replies").withRenderingMode(.alwaysTemplate) }
        var Delete: UIImage! { return #imageLiteral(resourceName: "Delete").withRenderingMode(.alwaysTemplate) }
        var Reply: UIImage! { return #imageLiteral(resourceName: "Reply").withRenderingMode(.alwaysTemplate) }
        var Hide: UIImage! { return #imageLiteral(resourceName: "Hide").withRenderingMode(.alwaysTemplate) }
        var Thank: UIImage! { return #imageLiteral(resourceName: "Thank").withRenderingMode(.alwaysTemplate) }
        var Homepage: UIImage! { return #imageLiteral(resourceName: "Homepage").withRenderingMode(.alwaysTemplate) }
        var Twitter: UIImage! { return #imageLiteral(resourceName: "Twitter").withRenderingMode(.alwaysTemplate) }
        var Location: UIImage! { return #imageLiteral(resourceName: "Location").withRenderingMode(.alwaysTemplate) }
        var Github: UIImage! { return #imageLiteral(resourceName: "Github").withRenderingMode(.alwaysTemplate) }
        var Twitch: UIImage! { return #imageLiteral(resourceName: "Twitch").withRenderingMode(.alwaysTemplate) }
        var Psn: UIImage! { return #imageLiteral(resourceName: "Psn").withRenderingMode(.alwaysTemplate) }
        var More: UIImage! { return #imageLiteral(resourceName: "More").withRenderingMode(.alwaysTemplate) }
        var Time: UIImage! { return #imageLiteral(resourceName: "Time").withRenderingMode(.alwaysTemplate) }
        var Sort: UIImage! { return #imageLiteral(resourceName: "Sort").withRenderingMode(.alwaysTemplate) }
        var Home: UIImage! { return #imageLiteral(resourceName: "Home").withRenderingMode(.alwaysTemplate) }
        var Nodes: UIImage! { return #imageLiteral(resourceName: "Nodes").withRenderingMode(.alwaysTemplate) }
        var TabarSearch: UIImage! { return #imageLiteral(resourceName: "Tabar_Search").withRenderingMode(.alwaysTemplate) }
        var Notification: UIImage! { return #imageLiteral(resourceName: "Notification").withRenderingMode(.alwaysTemplate) }
        var Profile: UIImage! { return #imageLiteral(resourceName: "Profile").withRenderingMode(.alwaysTemplate) }
        var Logout: UIImage! { return #imageLiteral(resourceName: "Logout").withRenderingMode(.alwaysTemplate) }
        var Setting: UIImage! { return #imageLiteral(resourceName: "Setting").withRenderingMode(.alwaysTemplate) }
        var Favorite: UIImage! { return #imageLiteral(resourceName: "Favorite").withRenderingMode(.alwaysTemplate) }
        var FavoriteActivity: UIImage! { return #imageLiteral(resourceName: "Favorite_Activity").withRenderingMode(.alwaysTemplate) }
    }
    
}
