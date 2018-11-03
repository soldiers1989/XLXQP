local mMyTransform = nil
-- 登录模块
local mLoginNodeGameObject = nil
local mAccountInput = nil
local mPasswordInput = nil

-- 验证登录模块
local mValidationNodeGameObject = nil
local mValidationCD = nil

local isUpdateCodeCountDown = false
local mValidationCountDown = 0

function UpdateCodeCD()
    if not isUpdateCodeCountDown then
        return
    end
    if mValidationCD == nil then
        return
    end
    if CS.SMSManager.Instance().IsSMSCD == false then
        GameObjectSetActive(mValidationCD.gameObject, false)
        return
    end
    GameObjectSetActive(mValidationCD.gameObject, true)
    local tCountDown = math.ceil(CS.SMSManager.Instance().SMSCDTime)
    if tCountDown < 0 then
        tCountDown = 0
        isUpdateCodeCountDown = false
    end
    if mValidationCountDown ~= tCountDown then
        mValidationCountDown = tCountDown
        mValidationCD.text = lua_FormatToCountdownStyle(mValidationCountDown)
        if tCountDown == 0 then
            mValidationCD.text = ""
        end
    end
end

-- 关闭UI
function OnCloseBtnClick()
    CS.WindowManager.Instance:CloseWindow('UILogin', false)
end

-- 登录 账号+密码
function OnLoginBtnClick()

    if GameData.IsAgreement == false then
        CS.BubblePrompt.Show('你还未同意隐私政策', "UILogin")
        return
    end

    local strAccount = mAccountInput.text
    local strPassword = mPasswordInput.text

    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UILogin")
        return
    end

    tmpLength = SubStringGetTotalCount(strPassword)
    print("密码长度:",tmpLength)
    if  strPassword =="" or (tmpLength < 8  or tmpLength > 12)then
        CS.BubblePrompt.Show('请输入正确密码:8~12个字母+数字!', "UILogin")
        return
    end

    -- 缓存登陆信息
    LoginMgr:HandleCacheLoginData(LOGIN_TYPE.MobilePassword, strAccount, strPassword)
    NetMsgHandler.TryConnectHubServer(true)
end

-- 登录 快速登录(原始登录)
function OnFastBtnClick()
    -- TODO 玩家先账号密码登陆失败,然后选择快速登陆
    LoginMgr:HandleCacheLoginData(LoginMgr.mLastLoginType, LoginMgr.mLastLoginAccount, LoginMgr.mLastLoginPassword)
    NetMsgHandler.TryConnectHubServer(true)
end

-- 登录 账号+验证码
function OnMobileBtnClick()
    GameObjectSetActive(mLoginNodeGameObject, false)
    GameObjectSetActive(mValidationNodeGameObject, true)
    mMyTransform:Find('Canvas/ValidationNode/Agreement'):GetComponent("Toggle").isOn = GameData.IsAgreement == true
end


local mMobileInput = nil
local mValidationInput = nil
local mValidationCode = "123456"

-- 获取验证码
function OnValidationBtnClick()
    -- 首先检查90秒限制
    -- 最后发送短信时间
    local tLastErrorCode = CS.SMSManager.Instance().LastSendSMSErrorCode
    local tLastTime = CS.SMSManager.Instance().LastSendSMSTime
    tLastTime = tonumber(tLastTime)

    -- 当前时间 秒
    local tNowTime = os.time()
    local passTime = tNowTime - tLastTime
    if passTime <= 0 then
       passTime = 0 
    end
    print("===time:", tNowTime, tLastTime, passTime)
    if passTime < 90 then
        CS.BubblePrompt.Show('获取验证码太频繁,请稍等:'..(90 - passTime), "UILogin")
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = (90 -passTime) * 1.0
        isUpdateCodeCountDown = true
        return
    elseif passTime < 3600 then
        -- 重复过滤 建议减少每小时发送数量
        if tLastErrorCode == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UILogin")
            return
        end
    elseif passTime < 86400 then
        if tLastErrorCode == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UILogin")
            return 
        end
    end

    local strAccount = mMobileInput.text
    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UILogin")
        return
    end

    local tCode = CS.SMSManager.Instance():SMSRandomCode()

    CS.SMSManager.Instance().LastSendSMSTime = tostring(tNowTime)
    CS.SMSManager.Instance().LastSMSCode = tostring(tCode)
    CS.SMSManager.Instance().LastPhoneNumber = strAccount
    isUpdateCodeCountDown = true

    local code = string.format("{\"code\":\"%s\"}", tostring(tCode))

    local data = CS.SMSManager.SendSms(strAccount, "SMS_135270123", code,"")
    if data ~= nil then
        if data.Code == "OK" then
            -- TODO 验证码发送成功
            CS.BubblePrompt.Show("登录验证码获取成功", "UILogin")
        elseif data.Code == "isv.MOBILE_NUMBER_ILLEGAL" then
            -- 非法手机号 建议使用正确的手机号
        elseif data.Code == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UILogin")
        elseif data.Code == "VALVE::H_MC" then
            -- 重复过滤 建议减少每小时发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UILogin")
        elseif data.Code == "VALVE::M_MC" then
            -- 重复过滤 建议减少每分钟发送数量()
            CS.BubblePrompt.Show('获取验证码太频繁,请等90秒再获取', "UILogin")
        else
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UILogin")
        end
        CS.SMSManager.Instance().LastSendSMSErrorCode = data.Code
        print("Send SMS Code:", data.Code, data.Message)
        print("Send SMS BizId", data.BizId, data.RequestId)
    else
        CS.SMSManager.Instance().LastSendSMSErrorCode = "1"
        CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UILogin")
    end

end

-- 验证模式登录
function OnLoginValidationClick()
    if GameData.IsAgreement == false then
        CS.BubblePrompt.Show('你还未同意隐私政策', "UILogin")
        return
    end

    -- 手机号格式检查
    local accountText = mMobileInput.text
    local tmpLength = SubStringGetTotalCount(accountText)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UILogin")
        return
    end
    
    -- TODO 验证码效验
    local codeText = mValidationInput.text
    tmpLength = SubStringGetTotalCount(codeText)
    if  codeText =="" or tmpLength ~= 6 or CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or CS.SMSManager.Instance().LastSMSCode ~= codeText then
        CS.BubblePrompt.Show('验证码无效!', "UILogin")
        return
    end

    -- 当前号码是否是接受验证码的手机好吗
    if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
        CS.BubblePrompt.Show('前后输入的手机号不一致...', "UILogin")
        return
    end
    -- 缓存登陆账号信息
    LoginMgr:HandleCacheLoginData(LOGIN_TYPE.MobileSMSCode, accountText, codeText)
    NetMsgHandler.TryConnectHubServer(true)
end

-- 验证方式回到密码登录
function OnReturnBtnClick()
    GameObjectSetActive(mLoginNodeGameObject, true)
    GameObjectSetActive(mValidationNodeGameObject, false)
end

function AgreementToggle_OnValueChanged(isOn)
    if GameData.IsAgreement ~= isOn then
        GameData.IsAgreement = isOn
    end
end

function AgreementButton_OnClick()
    CS.WindowManager.Instance:OpenWindow("UIAgreement")
end

-- 请求渠道ID
function ReqChannelCode()
    -- 该阶段请求一下渠道ID
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_TOURISTS, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKCODE, '参数:请求渠道ID')
end

function Awake()
    mMyTransform = this.transform

    mLoginNodeGameObject = mMyTransform:Find("Canvas/LoginNode").gameObject
    mMyTransform:Find('Canvas/LoginNode/LoginBtn'):GetComponent("Button").onClick:AddListener(OnLoginBtnClick)
    mMyTransform:Find('Canvas/LoginNode/ActionArea/FastBtn'):GetComponent("Button").onClick:AddListener(OnFastBtnClick)
    mMyTransform:Find('Canvas/LoginNode/ActionArea/MobileBtn'):GetComponent("Button").onClick:AddListener(OnMobileBtnClick)
    mAccountInput = mMyTransform:Find("Canvas/LoginNode/AccountInputField"):GetComponent("InputField")
    mPasswordInput = mMyTransform:Find("Canvas/LoginNode/PasswordInputField"):GetComponent("InputField")

    mValidationNodeGameObject = mMyTransform:Find("Canvas/ValidationNode").gameObject
    mMobileInput = mMyTransform:Find("Canvas/ValidationNode/MobileInputField"):GetComponent("InputField")
    mValidationInput = mMyTransform:Find("Canvas/ValidationNode/ValidationInputField"):GetComponent("InputField")
    mValidationCD = mMyTransform:Find("Canvas/ValidationNode/ValidationBtn/Text"):GetComponent("Text")
    mMyTransform:Find('Canvas/ValidationNode/ValidationBtn'):GetComponent("Button").onClick:AddListener(OnValidationBtnClick)
    mMyTransform:Find('Canvas/ValidationNode/LoginBtn1'):GetComponent("Button").onClick:AddListener(OnLoginValidationClick)
    

    mMyTransform:Find('Canvas/LoginNode/Agreement/AgreementButton'):GetComponent("Button").onClick:AddListener(AgreementButton_OnClick)
    mMyTransform:Find('Canvas/ValidationNode/Agreement/AgreementButton'):GetComponent("Button").onClick:AddListener(AgreementButton_OnClick)
    mMyTransform:Find('Canvas/LoginNode/Agreement'):GetComponent("Toggle").onValueChanged:AddListener(AgreementToggle_OnValueChanged)
    mMyTransform:Find('Canvas/ValidationNode/Agreement'):GetComponent("Toggle").onValueChanged:AddListener(AgreementToggle_OnValueChanged)

    mMyTransform:Find('Canvas/ValidationNode/back/CloseBtn'):GetComponent("Button").onClick:AddListener(OnReturnBtnClick)

    mValidationCD.text = ""

    if GameConfig.IsSpecial() then
        mMyTransform:Find('Canvas/LoginNode/ActionArea/MobileBtn').gameObject:SetActive(false)
        mMyTransform:Find("Canvas/LoginNode/AccountInputField/Placeholder"):GetComponent("Text").text = "请输入账号"
    end
end

function Start()
    MusicMgr:PlayBackMusic('BG_HALL')
    GameObjectSetActive(mLoginNodeGameObject, true)
    GameObjectSetActive(mValidationNodeGameObject, false)
    ReqChannelCode()
end

function RefreshWindowData(windowData)
    mMyTransform:Find('Canvas/LoginNode/Agreement'):GetComponent("Toggle").isOn = GameData.IsAgreement == true
end

function Update()
    UpdateCodeCD()
end

function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.ConnectGameServerFail, OnConnectGameServerFail)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.ConnectGameServerTimeOut, OnConnectGameServerTimeOut)
end

