local mMyTransform = nil
-- 验证登录模块
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
    CS.WindowManager.Instance:CloseWindow('UserReturn', false)
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
        CS.BubblePrompt.Show('获取验证码太频繁,请稍等:'..(90 - passTime), "UserReturn")
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = (90 -passTime) * 1.0
        isUpdateCodeCountDown = true
        return
    elseif passTime < 3600 then
        -- 重复过滤 建议减少每小时发送数量
        if tLastErrorCode == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UserReturn")
            return
        end
    elseif passTime < 86400 then
        if tLastErrorCode == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UserReturn")
            return 
        end
    end

    local strAccount = mMobileInput.text
    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UserReturn")
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
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = 90
        if data.Code == "OK" then
            -- TODO 验证码发送成功
            CS.BubblePrompt.Show("登录验证码获取成功", "UserReturn")
        elseif data.Code == "isv.MOBILE_NUMBER_ILLEGAL" then
            -- 非法手机号 建议使用正确的手机号
        elseif data.Code == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UserReturn")
        elseif data.Code == "VALVE::H_MC" then
            -- 重复过滤 建议减少每小时发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UserReturn")
        elseif data.Code == "VALVE::M_MC" then
            -- 重复过滤 建议减少每分钟发送数量()
            CS.BubblePrompt.Show('获取验证码太频繁,请等90秒再获取', "UserReturn")
        else
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UserReturn")
        end
        CS.SMSManager.Instance().LastSendSMSErrorCode = data.Code
        print("Send SMS Code:", data.Code, data.Message)
        print("Send SMS BizId", data.BizId, data.RequestId)
    else
        CS.SMSManager.Instance().LastSendSMSErrorCode = "1"
        CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UserReturn")
    end

end

-- 验证模式登录
function OnLoginValidationClick()
    -- 手机号格式检查
    local accountText = mMobileInput.text
    local tmpLength = SubStringGetTotalCount(accountText)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UserReturn")
        return
    end
    
    -- TODO 验证码效验
    local codeText = mValidationInput.text
    tmpLength = SubStringGetTotalCount(codeText)
    if  codeText =="" or tmpLength ~= 6 or CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or CS.SMSManager.Instance().LastSMSCode ~= codeText then
        CS.BubblePrompt.Show('验证码无效!', "UserReturn")
        return
    end

    -- 当前号码是否是接受验证码的手机好吗
    if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
        CS.BubblePrompt.Show('前后输入的手机号不一致...', "UserReturn")
        return
    end
    NetMsgHandler.Send_CS_User_Return(accountText)
    mValidationInput.text = ""
end

function Awake()
    mMyTransform = this.transform

    mMobileInput = mMyTransform:Find("Canvas/MobileInputField"):GetComponent("InputField")
    mValidationInput = mMyTransform:Find("Canvas/ValidationInputField"):GetComponent("InputField")
    mValidationCD = mMyTransform:Find("Canvas/ValidationBtn/Text"):GetComponent("Text")
    mMyTransform:Find('Canvas/ValidationBtn'):GetComponent("Button").onClick:AddListener(OnValidationBtnClick)
    mMyTransform:Find('Canvas/LoginBtn'):GetComponent("Button").onClick:AddListener(OnLoginValidationClick)
    mMyTransform:Find('Canvas/back/CloseBtn'):GetComponent("Button").onClick:AddListener(OnCloseBtnClick)
    mValidationCD.text = ""
end

function Start()
    MusicMgr:PlayBackMusic('BG_HALL')
end

function Update()
    UpdateCodeCD()
end