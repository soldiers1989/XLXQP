if PlatformBridge == nil then
    PlatformBridge = 
    {
        unityScript = nil,
        currentPlatformID = 0, --此处的值是PLATFORM_TYPE枚举
        currentfunctionEnum = 0,
    }
end

function PlatformBridge:Init()
    self.unityScript = CS.PlatformBridge.Init()
    --print('lua 平台桥接器初始化完成', self.unityScript)
end

function PlatformBridge:CallFunc(platformID, functionEnum, param)
    --print('lua调用平台接口 PlatformBridge.CallFunc', platformID, functionEnum, param)
    self.currentPlatformID = platformID
    self.currentfunctionEnum = functionEnum
    return self.unityScript:UnityCallPlatform(platformID, functionEnum, param)
end

function PlatformBridge.CallBackFunc(paramTable)
    --print('平台代码处理完毕通知回lua PlatformBridge.CallBackFunc paramTable = ', paramTable)
    local platformID = paramTable["platformID"]
    local functionEnum = paramTable["functionEnum"]
    
    if functionEnum == PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKREG then
        -- OpenInstallSDK 注册反馈

    elseif functionEnum == PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKCODE then
        -- OpenInstallSDK 渠道ID 反馈
        local channelCode = paramTable["channelCode"]
        local tChannelCode = channelCode == nil and -1 or tonumber(channelCode)
        print('OpenInstallSDK  数据反馈[1] ID =', channelCode, tChannelCode)
        if GameData.ConfirmChannelCode == false and  tChannelCode > 0 then
            GameData.ChannelCode = tChannelCode
        end
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKINVITE then
        -- OpenInstallSDK 反馈：邀请者推荐ID
        local tReferralsID = paramTable["referralsID"]
        local tReferralsChannel = paramTable["referralsChannel"]
        local tGameID = paramTable["GameID"]
        tReferralsID = tReferralsID == nil and -1 or tonumber(tReferralsID)
        tReferralsChannel = tReferralsChannel == nil and -1 or tonumber(tReferralsChannel)
        tGameID = tGameID == nil and -1 or tonumber(tGameID)
        GameData.OpenInstallReferralsID = tReferralsID
        GameData.OpenInstallReferralsChannel = tReferralsChannel
        GameData.OpenInstallReferralsGameID = tGameID

        print('OpenInstallSDK  数据反馈[2] ID:', tReferralsID, tReferralsChannel, tGameID)
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY then--支付
        -- 支付结果反馈
        LoginMgr:RecvPayResult(platformID, paramTable)

    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_INSTALLED then
        -- 微信安装检查结果
        -- 注意该接口是调用返回 因此不会调用回调到此处
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_SHARE then
        -- 微信分享结果
        local errcode = paramTable['errcode']
        print("=====WX Share PY:", errcode)
        if errcode ~= 0 then
            CS.BubblePrompt.Show('用户取消了操作...', "WXLogin")
        else
            print("===1==微信PY分享成功...")
        end
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_SHARE_PYQ then
        -- 微信朋友圈分享结果
        local errcode = paramTable['errcode']
        print("=====WX Share PYQ:", errcode)
        if errcode ~= 0 then
            CS.BubblePrompt.Show('用户取消了操作...', "WXLogin")
        else
            GameData.RoleInfo.IsSharePYQ = 1
        end
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_LOGIN then
        -- WX 登录结果
        LoginMgr:RecvLoginResult(platformID, paramTable)
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_BIND then
        -- 微信账号绑定
    elseif functionEnum == PLATFORM_FUNCTION_ENUM.FUNCTION_WX_AUTO_LOGIN_CHECK then
        -- 微信自动登录检查
        -- 注意该接口结果同步返回这里无需处理
    else
        print("=====未处理的函数回调")
    end
end

