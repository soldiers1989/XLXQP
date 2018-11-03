local MyTransform = nil
local mNameInput = nil
local mAccountInput = nil
local mValidationInput = nil
local mPasswordInput = nil
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
        CS.BubblePrompt.Show('获取验证码太频繁,请稍等:'..(90 - passTime), "RegisterUI")
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = (90 -passTime) * 1.0
        isUpdateCodeCountDown = true
        return
    elseif passTime < 3600 then
        -- 重复过滤 建议减少每小时发送数量
        if tLastErrorCode == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "RegisterUI")
            return
        end
    elseif passTime < 86400 then
        if tLastErrorCode == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "RegisterUI")
            return
        end
    end

    local strAccount = mAccountInput.text
    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "RegisterUI")
        return
    end

    -- TODO 验证码
    local tCode = CS.SMSManager.Instance():SMSRandomCode()

    CS.SMSManager.Instance().LastSendSMSTime = tostring(tNowTime)
    CS.SMSManager.Instance().LastSMSCode = tostring(tCode)
    CS.SMSManager.Instance().LastPhoneNumber = strAccount
    isUpdateCodeCountDown = true

    local code = string.format("{\"code\":\"%s\"}", tostring(tCode))
    
    local data = CS.SMSManager.SendSms(strAccount, "SMS_135027712", code,"")
    if data ~= nil then

        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = 90
        if data.Code == "OK" then
            -- TODO 验证码发送成功
            CS.BubblePrompt.Show("注册验证码获取成功", "RegisterUI")
        elseif data.Code == "isv.MOBILE_NUMBER_ILLEGAL" then
            -- 非法手机号 建议使用正确的手机号
            CS.BubblePrompt.Show("非法手机号,建议使用正确的手机号", "RegisterUI")
        elseif data.Code == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "RegisterUI")
        elseif data.Code == "VALVE::H_MC" then
            -- 重复过滤 建议减少每小时发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "RegisterUI")
        
        elseif data.Code == "VALVE::M_MC" then
            -- 重复过滤 建议减少每分钟发送数量()
            CS.BubblePrompt.Show('获取验证码太频繁,请等90秒再获取', "RegisterUI")
        elseif data.Code == "isv.SMS_SIGNATURE_ILLEGAL" then
            CS.BubblePrompt.Show(data.Message, "RegisterUI")
        elseif data.Code == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show(data.Message, "RegisterUI")
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "RegisterUI")
        else
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "RegisterUI")
        end
        CS.SMSManager.Instance().LastSendSMSErrorCode = data.Code
        print("Send SMS Code:", data.Code, data.Message)
        print("Send SMS BizId", data.BizId, data.RequestId)
    else
        CS.SMSManager.Instance().LastSMSCode = "99999999"
        CS.SMSManager.Instance().LastSendSMSErrorCode = "1"
        CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "RegisterUI")
    end
end

-- 确认登录
function OnConfirmBtnClick()
    local accountText = ''
    local tmpLength = 0
    -- TODO 手机号码是否有效
    accountText = mAccountInput.text
    tmpLength = SubStringGetTotalCount(accountText)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "RegisterUI")
        return
    end

    -- TODO 验证码效验
    local codeText = mValidationInput.text
    tmpLength = SubStringGetTotalCount(codeText)
    if  codeText =="" or tmpLength ~= 6 or CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or CS.SMSManager.Instance().LastSMSCode ~= codeText then
        CS.BubblePrompt.Show('验证码无效!', "RegisterUI")
        return
    end

    -- TODO 再次验证手机号码是否一致
    if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
        CS.BubblePrompt.Show('手机号码不一致,请输入正确的手机号码', "RegisterUI")
        return
    end

    -- 密码验证
    local strPassword = mPasswordInput.text
    tmpLength = SubStringGetTotalCount(strPassword)
    if  strPassword =="" or (tmpLength < 8  or tmpLength > 12)then
        CS.BubblePrompt.Show('请输入正确密码:8~12个字母+数字!', "RegisterUI")
        return
    end

    mValidationInput.text = ""
    -- 未绑定 走绑定账号流程
    NetMsgHandler.SendBindAccount(accountText, strPassword)
    -- 重置验证码无效值
    CS.SMSManager.Instance().LastSMSCode = "99999999"

end

function OnCloseBtnClick()
    CS.WindowManager.Instance:CloseWindow('RegisterUI', false)
end


function Awake()
    MyTransform = this.transform
    mAccountInput = MyTransform:Find("Canvas/AccountInputField"):GetComponent("InputField")
    mValidationInput = MyTransform:Find("Canvas/ValidationInputField"):GetComponent("InputField")
    mPasswordInput = MyTransform:Find("Canvas/PasswordInputField"):GetComponent("InputField")
    mValidationCD = MyTransform:Find("Canvas/ValidationBtn/Text"):GetComponent("Text")

    MyTransform:Find('Canvas/ValidationBtn'):GetComponent("Button").onClick:AddListener(OnValidationBtnClick)
    MyTransform:Find('Canvas/ConfirmBtn'):GetComponent("Button").onClick:AddListener(OnConfirmBtnClick)
    MyTransform:Find('Canvas/Image/CloseBtn'):GetComponent("Button").onClick:AddListener(OnCloseBtnClick)
    
    mValidationCD.text = ""

end

function Start()

end

function Update()
    UpdateCodeCD()
end

function OnDestroy()
    
end
