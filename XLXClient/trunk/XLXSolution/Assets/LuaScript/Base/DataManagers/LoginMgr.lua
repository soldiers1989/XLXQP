
if LoginMgr == nil then
    LoginMgr = 
    {
        RunningPlatformID = 1, 			-- 1 windows 2 android 3 ios 4 macos
        -- 成功登陆信息
        mLastLoginType = 1,				-- 登录类型
        mLastLoginAccount = "",			-- 登录账号
        mLastLoginPassword = "",		-- 登录密码
        -- 预期登陆信息(玩家主动登陆时,出现多种登陆方式，便于登陆管理)
        mCacheLoginType = 1,			-- 登录类型(缓存)
        mCacheLoginAccount = "",		-- 登录账号(缓存)
        mCacheLoginPassword = "",		-- 登录密码(缓存)


        isRegisterWX = 0,               -- 是否注册微信SDK(0 未注册 1注册)
        isInstallationWX = 0,           -- 是否安装微信(0 未安装 1安装)
        -- 是否切换账号标志，只有当玩家点击了切换账号按钮后，此值才为1，其他情况下都为0
        isChangeAccount = 0,
    }
end

function LoginMgr:Init()
    --读取本地数据
    self:LoadFromLocal()
end

function LoginMgr:IsAutoLogin()
    
    return false
end

-- 加载本地登录信息
function LoginMgr:LoadFromLocal()
    if GameConfig.IsDebug and not GameConfig.IsShenHeiVision then
        CS.UnityEngine.PlayerPrefs.DeleteAll()
    end

    local tLoginType = CS.UnityEngine.PlayerPrefs.GetString("Game_Login_Type","1")
    local tLoginAccount = CS.UnityEngine.PlayerPrefs.GetString("Game_Login_Account","0")
    local tLoginPassword = CS.UnityEngine.PlayerPrefs.GetString("Game_Login_Password","0")
    if tonumber(tLoginType) == 1 then
        tLoginAccount = CS.UnityEngine.SystemInfo.deviceUniqueIdentifier
        tLoginPassword = ""
    end

    self.mLastLoginType = tonumber(tLoginType) 
    self.mLastLoginAccount = tLoginAccount
    self.mLastLoginPassword = tLoginPassword

    self.mCacheLoginType = tonumber(tLoginType)
    self.mCacheLoginAccount = tLoginAccount
    self.mCacheLoginPassword = tLoginPassword

    print("-----Local AccountInfo:",tLoginType, tLoginAccount, tLoginPassword)
end

-- 登录方式本地存储
function LoginMgr:SaveToLocal()

    CS.UnityEngine.PlayerPrefs.SetString("Game_Login_Type", tostring(self.mLastLoginType))
    CS.UnityEngine.PlayerPrefs.SetString("Game_Login_Account", tostring(self.mLastLoginAccount))
    CS.UnityEngine.PlayerPrefs.SetString("Game_Login_Password", tostring(self.mLastLoginPassword))

    GameData.LoginInfo.LoginType = self.mLastLoginType
    GameData.LoginInfo.Account = self.mLastLoginAccount
    GameData.LoginInfo.Password = self.mLastLoginPassword

    print("保存本地登录信息:", self.mLastLoginType, self.mLastLoginAccount, self.mLastLoginPassword)
end

-- 登录信息更新
function LoginMgr:UpdateLoginData(longTypeParam, accountParam, passwordParam)
    self.mLastLoginType = longTypeParam
    self.mLastLoginAccount = accountParam
    self.mLastLoginPassword = passwordParam
end

-- 缓存登陆信息
function LoginMgr:HandleCacheLoginData(longTypeParam, accountParam, passwordParam)
    self.mCacheLoginType = longTypeParam
    self.mCacheLoginAccount = accountParam
    self.mCacheLoginPassword = passwordParam
end

-- 微信登录结果反馈
function LoginMgr:RecvLoginResult(platformID, paramTable)
    CS.LoadingDataUI.Hide()
    if platformID == PLATFORM_TYPE.PLATFORM_WEIXIN then
        local errcode = paramTable['errcode']
        print('=====WX登录结果 errcode = '..errcode)
        if errcode ~= 0 then
            print('===1==微信授权登陆失败 errcode = ', errcode)
            -- CS.BubblePromptUI.Show("微信授权登陆失败", "WXLogin")
            -- 继续使用微信方式登录 但是微信号为空 
            -- 服务器会使用设备码去查找该设备绑定的账号列表
            -- 1 多个账号 选其中钱最多的账号进行登录
            -- 2 无账号 反馈给客户端
            if errcode == 1 or errcode == -1 then
                -- 用户取消了授权
                print("用户取消了授权...")
                CS.BubblePrompt.Show('用户取消了操作...', "WXLogin")
                return
            end
            print("===2==微信登录授权失败...")
            LoginMgr:HandleCacheLoginData(LOGIN_TYPE.WeChat, "", "")
            NetMsgHandler.TryConnectHubServer(true)
        else
            print("微信授权成功，即将向服务器发送登录信息")
            local tOpenid = paramTable['openid']
            local tNickname = paramTable['nickname']
            GameData.LoginInfo.NickName = tNickname
            LoginMgr:HandleCacheLoginData(LOGIN_TYPE.WeChat, tOpenid, "")
            -- 保存本次登录方式
            NetMsgHandler.TryConnectHubServer(true)
        end
    end
end


function LoginMgr:RecvPayResult(platformID, paramTable)
    CS.LoadingDataUI.Hide()
    if platformID == PLATFORM_TYPE.PLATFORM_APP_STORE then
        local errcode = paramTable['errcode']
        if errcode ~= 0 then
            CS.BubblePrompt.Show("支付失败", "LoginMgr")
        else
            --CS.BubblePrompt.Show("支付成功", "LoginMgr")
        end
    end
end

