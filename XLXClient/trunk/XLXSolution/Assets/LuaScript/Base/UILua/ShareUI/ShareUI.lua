

function Awake()
    this.transform:Find('Canvas/Window/Title/Close'):GetComponent('Button').onClick:AddListener(CloseShareUI)
    this.transform:Find('Canvas/Window/Button/PYQ'):GetComponent('Button').onClick:AddListener(SharePYQ)
    this.transform:Find('Canvas/Window/Button/PY'):GetComponent('Button').onClick:AddListener(SharePY)
    this.transform:Find('Canvas/Window/Button/IOS'):GetComponent('Button').onClick:AddListener(IOS_Share)
    local currentPlatform = CS.Utility.GetCurrentPlatform();
    if currentPlatform == 3 then
        --this.transform:Find('Canvas/Window/Button/IOS').gameObject:SetActive(true)
    end
end

-- 微信分享好友
function SharePY()
    GameData.LoginInfo.WechatIsInstall = PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_INSTALLED, "参数：微信软件安装状态")
    if GameData.LoginInfo.WechatIsInstall ~= 1 then
        CS.BubblePrompt.Show("请安装微信！", "HallUI")
        return
    end
    -- 构建信息json
    local infoTable = { }
    if GameData.AgencyInfo.IsAgent == SALESMAN.NULL then
        infoTable = FTG_Share_PY()
    else
        infoTable = TG_Share_PY()
    end
    local infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_SHARE, infoJSON)
end

-- 微信分享朋友圈
function SharePYQ()
    GameData.LoginInfo.WechatIsInstall = PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_INSTALLED, "参数：微信软件安装状态")
    if GameData.LoginInfo.WechatIsInstall ~= 1 then
        CS.BubblePrompt.Show("请安装微信！", "HallUI")
    end
    -- 构建信息json
    local infoTable = { }
    if GameData.AgencyInfo.IsAgent == SALESMAN.NULL then
        infoTable = FTG_Share_PYQ()
    else
        infoTable = TG_Share_PYQ()
    end
    local infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
    
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_SHARE_PYQ, infoJSON)
end

-- IOS 原生分享
function IOS_Share()
    local info = "" 
    if GameData.AgencyInfo.IsAgent == SALESMAN.NULL then
        info = IOS_FTG_Share_PYQ()
    else
        info = IOS_TG_Share_PYQ()
    end
    --print("====================",info)
    CS.GJCNativeShare.Instance:NativeShare(info,nil)
end

-- 非推广员分享好友
function FTG_Share_PY()
    -- 构建信息json
    local infoTable = { }
    infoTable["title"] = string.format(data.GetString("WeChatShareTitle"))
    infoTable["content"] = string.format(data.GetString("WeChatShareContent"))
    if GameConfig.WXSharedUrl == "" then
        GameConfig.WXSharedUrl = "http://www."..GameConfig.KFUrl
    end
    infoTable["url"] = string.format(GameConfig.WXSharedUrl)
    return infoTable
end

-- 推广员分享好友
function TG_Share_PY()
    -- 构建信息json
    local infoTable = { }
    infoTable["title"] = string.format(data.GetString("WeChatShareTitle"))
    infoTable["content"] = string.format(data.GetString("WeChatShareContent"))
    if GameConfig.TGSharedUrl == "" then
        GameConfig.TGSharedUrl = "http://www."..GameConfig.KFUrl
    end
    -- 代理员推广号
    local InviteID = GameData.RoleInfo.AccountID
    infoTable["url"] = string.format("%s?GameID=%d&referralsID=%d&referralsChannel=%s", GameConfig.TGSharedUrl, CS.AppDefine.GameID, InviteID, GameData.ChannelCode)
    print('shareurl=' .. infoTable["url"])
    return infoTable
end

-- 非推广员分享朋友圈
function FTG_Share_PYQ()
    -- 构建信息json
    local infoTable = { }
    infoTable["title"] = string.format(data.GetString("WeChatSharePYQTitle"))
    infoTable["content"] = string.format(data.GetString("WeChatSharePYQContent"))
    if GameConfig.WXSharedUrl == "" then
        GameConfig.WXSharedUrl = "http://www."..GameConfig.KFUrl
    end
    infoTable["url"] = string.format(GameConfig.WXSharedUrl)
    return infoTable
end

-- 推广员分享朋友圈
function TG_Share_PYQ()
    -- 构建信息json
    local infoTable = { }
    infoTable["title"] = string.format(data.GetString("WeChatSharePYQTitle"))
    infoTable["content"] = string.format(data.GetString("WeChatSharePYQContent"))
    if GameConfig.TGSharedUrl == "" then
        GameConfig.TGSharedUrl = "http://www."..GameConfig.KFUrl
    end
    local InviteID = GameData.RoleInfo.AccountID
    infoTable["url"] = string.format("%s?GameID=%d&referralsID=%d&referralsChannel=%s", GameConfig.TGSharedUrl, CS.AppDefine.GameID, InviteID, GameData.ChannelCode)
    print('shareurl=' .. infoTable["url"])
    return infoTable
end

-- IOS 非推广员分享朋友圈
function IOS_FTG_Share_PYQ()
    if GameConfig.WXSharedUrl == "" then
        GameConfig.WXSharedUrl = "http://www."..GameConfig.KFUrl
    end
    local Url = string.format(GameConfig.WXSharedUrl)
    local content = string.format(data.GetString("WeChatSharePYQContent"))
    local info = content..Url
    return info
end
-- IOS 推广员分享朋友圈
function IOS_TG_Share_PYQ()
    if GameConfig.TGSharedUrl == "" then
        GameConfig.TGSharedUrl = "http://www."..GameConfig.KFUrl
    end
    local InviteID = GameData.RoleInfo.AccountID
    local Url = string.format("%s?GameID=%d&referralsID=%d&referralsChannel=%s", GameConfig.TGSharedUrl, CS.AppDefine.GameID, InviteID, GameData.ChannelCode)
    local content = string.format(data.GetString("WeChatSharePYQContent"))
    local info = content..Url
    return info
end

function CloseShareUI()
    CS.WindowManager.Instance:CloseWindow('ShareUI', false)
end
