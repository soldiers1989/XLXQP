local Time = CS.UnityEngine.Time

local mBtnVisitor = nil         -- 游客登录
local mBtnWX = nil              -- 微信登录

-- 请求渠道ID
function OnReqChannelCode()
    -- 该阶段请求一下渠道ID
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_TOURISTS, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKCODE, '参数:请求渠道ID')
end

-- 自动登录
function AutoLogin()
    -- 正式版本 不允许选择服务器
    NetMsgHandler.TryConnectHubServer(true)
end

-- 游客登录
function OnVisitorBtnClick()
    local tAccount = CS.UnityEngine.SystemInfo.deviceUniqueIdentifier
    LoginMgr:HandleCacheLoginData(LOGIN_TYPE.VISITOR, tAccount, "")
    AutoLogin()
end

-- 微信登录
function OnWXBtnClick()
    if LoginMgr.isInstallationWX == 0 then
        CS.BubblePrompt.Show('请先安装微信...', "WXLogin")
        return
    end

    CS.LoadingDataUI.Show(5)
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_LOGIN, tostring(LoginMgr.isChangeAccount))
end

-- 平台信息初始化
function PlatformInit()
    local tRunPlatform = CS.Utility.GetCurrentPlatform()
    LoginMgr.RunningPlatformID = tRunPlatform
    GameData.RoleInfo.IPLocation = LBSMgr:RandomLocation()
    if tRunPlatform == 2 or tRunPlatform == 3 then
        if LoginMgr.isInstallationWX ~= 1 then
            -- 微信安装检查
            LoginMgr.isInstallationWX = PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_INSTALLED, "WX SDK Install")
        end
    end
end

-- 登录按钮显示检查
function CheckLoginBtns()
    if LoginMgr.RunningPlatformID == 1 then
        GameObjectSetActive(mBtnVisitor,true)
    else
        GameObjectSetActive(mBtnVisitor,GameConfig.CanVisitorLogin)
    end

    if GameConfig.IsShenHeiVision then
        if LoginMgr.isInstallationWX ~= 1 then
            -- 审核版本 微信登录按钮 需要根据是否安装微信来显示按钮
            GameObjectSetActive(mBtnWX, false)
        else
            GameObjectSetActive(mBtnWX, true)
        end
    end
end

-- 微信自动登录检查
function WXAutoLoginCheck()
    if not GameData.IsFirstLogin then
        print("=====WX Auto login 0")
        return
    end
    if LoginMgr.isInstallationWX ~= 1 then
        -- 未安装微信
        print("=====WX Auto login 1")
        return
    end
    local canAutoLogin = PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_AUTO_LOGIN_CHECK, "WX SDK Auto login")
    print("=====WX Auto login 2:", canAutoLogin)
    if canAutoLogin == 1 then
        CS.LoadingDataUI.Show(5)
        PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_LOGIN, tostring(LoginMgr.isChangeAccount))
    end
end

function Awake()
    local mMyTransform = this.transform
    mBtnVisitor = mMyTransform:Find("Canvas/VisitorBtn").gameObject
    mBtnWX = mMyTransform:Find("Canvas/WXBtn").gameObject

    mMyTransform:Find('Canvas/VisitorBtn'):GetComponent("Button").onClick:AddListener(OnVisitorBtnClick)
    mMyTransform:Find('Canvas/WXBtn'):GetComponent("Button").onClick:AddListener(OnWXBtnClick)

    local versionValue = CS.Utility.GetAppVersion()
    if versionValue ~= nil then
        mMyTransform:Find('Canvas/VersionText'):GetComponent("Text").text = "V " .. versionValue
    end
end

function Start()
    PlatformInit()
    CheckLoginBtns()
    WXAutoLoginCheck()
    OnReqChannelCode()

    MusicMgr:PlayBackMusic('BG_HALL')
end

function Update()

end

function OnDestroy()
    
end