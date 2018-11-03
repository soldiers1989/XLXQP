local Time = CS.UnityEngine.Time
local mProgressBar = nil
local mProgressHandle = nil
local HandleAreaSize = 100
local QQ = nil
local WeChat = nil

-- 请求渠道ID
function ReqChannelCode()
    -- 该阶段请求一下渠道ID
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_TOURISTS, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKCODE, '参数:请求渠道ID')
end

-- 自动登录
function AutoLogin()
    print("=====AutoLogin Time:", CS.UnityEngine.Time.time)
    -- 正式版本 不允许选择服务器
    NetMsgHandler.TryConnectHubServer(true)
end

function BeginLogin()
    this:DelayInvoke(1.0,function() TryLogin() end)
end

function TryLogin()
    if GameConfig.IPHandle then
        -- 已经获取到IP地址
        AutoLogin()
    else
        -- 目前还未获取到IP地址,再次等1秒
        this:DelayInvoke(1.0,function() AutoLogin() end)
    end
end

function Awake()
    QQ = this.transform:Find('Canvas/QQ').gameObject
    WeChat = this.transform:Find('Canvas/Wechat').gameObject
    GameObjectSetActive(QQ,false)
    GameObjectSetActive(WeChat,false)
    mProgressBar = this.transform:Find("Canvas/ProgressBar/Value"):GetComponent("Image")
    mProgressHandle = this.transform:Find("Canvas/ProgressBar/HandleSlideArea/Handle")
    local  tRect = this.transform:Find("Canvas/ProgressBar/HandleSlideArea"):GetComponent("RectTransform")
    HandleAreaSize = tRect.rect.size.x;

    local versionValue = CS.Utility.GetAppVersion()
    if versionValue ~= nil then
        this.transform:Find('Canvas/VersionText'):GetComponent("Text").text = "V " .. versionValue
    end
    WeChatQQIsOpen()
end

function WeChatQQIsOpen()
    if GameConfig.IsShenHeiVision == false then
        --GameObjectSetActive(QQ,true)
        --GameObjectSetActive(WeChat,true)
    end
end

function Start()
    MusicMgr:PlayBackMusic('BG_HALL')
    ReqChannelCode()
    LoginMgr.RunningPlatformID = CS.Utility.GetCurrentPlatform()
    BeginLogin()

    GameData.RoleInfo.IPLocation = LBSMgr:RandomLocation()
end

local passTime = 0
local MaxTime = 10

function UpdateProgress()
    if mProgressBar == nil then
        return 
    end
    passTime = passTime + Time.deltaTime
    if passTime > 9 then
        passTime = 9 
    end
    mProgressBar.fillAmount =  passTime / MaxTime

    mProgressHandle.localPosition = CS.UnityEngine.Vector3(HandleAreaSize * (mProgressBar.fillAmount - 0.5), 0, 0);
end

function Update()
    UpdateProgress()
end

function OnDestroy()
    
end