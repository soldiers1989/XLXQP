local selectStoreConfig = nil

function Awake()
    AddButtonHandlers()
end

function WindowOpened()
    ResetStoreUI()
    ResetStoreContentPart()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptStoreVIP_Lv, UpgradeVIP_Lv)
    NetMsgHandler.RegisterGameParser(ProtrocolID.CS_Buy_Goods, Received_CS_Buy_Goods)
    NetMsgHandler.Send_CS_Store_VIP_Info()
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptStoreVIP_Lv, UpgradeVIP_Lv)
    NetMsgHandler.RemoveGameParser(ProtrocolID.CS_Buy_Goods, Received_CS_Buy_Goods)
end

function ResetStoreUI()
    this.transform:Find('Canvas/StoreWindow').gameObject:SetActive(true)
    this.transform:Find('Canvas/CloseStore').gameObject:SetActive(true)
    this.transform:Find('Canvas/ChargeWindow').gameObject:SetActive(false)

end

-- 按钮响应事件绑定
function AddButtonHandlers()
    this.transform:Find('Canvas/CloseStore'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
    this.transform:Find('Canvas/StoreWindow/Title/CloseButton'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
    this.transform:Find('Canvas/ChargeWindow/Title/CloseButton'):GetComponent("Button").onClick:AddListener(CloseChargeButtonOnClick)
    this.transform:Find('Canvas/ChargeWindow/Content/ChargeWay/zhifubao'):GetComponent("Button").onClick:AddListener(ChargeTypeOfZhiFuBaoOnClick)
    this.transform:Find('Canvas/ChargeWindow/Content/ChargeWay/weixin'):GetComponent("Button").onClick:AddListener(ChargeTypeOfWeiXinOnClick)
    this.transform:Find('Canvas/ChargeWindow/Content/ChargeWay/pingguo'):GetComponent("Button").onClick:AddListener(ChargeTypeOfAppleOnClick)
    this.transform:Find('Canvas/ChargeWindow/Content/ChargeWayOf2/dianka'):GetComponent("Button").onClick:AddListener(ChargeTypeOfDianKaOnClick)

end

-----------------------------------------------------------------------------------
-----------------------------------商城界面部分------------------------------------
function ResetStoreContentPart()
    local count = 0
    local storeItem = this.transform:Find('Canvas/StoreWindow/Content/StorePart/Viewport/Content/StoreItem')
    storeItem.gameObject:SetActive(false)
    --this.transform:Find('Canvas/StoreWindow/Content/StorePart/Viewport/Content/StoreItem/Gift').gameObject:SetActive(true)
    local storeItemParent = this.transform:Find('Canvas/StoreWindow/Content/StorePart/Viewport/Content')
    lua_Transform_ClearChildren(storeItemParent, true)
    local dataItemIndex = 0
    local newStoreItem = nil
    for key, value in ipairs(data.StoreConfig) do
        if value ~= nil then
            
            if CS.AppDefine.IsOpenSFT == 0 and value.Payment == 2 then --跳过此项
                
            else
                if GameData.RoleInfo.VipLevel >= 7 then
                    
                    if GameConfig.IsSpecial() and count >= 6 then
                        return
                    end

                    if count % 2 == 0 then
                    -- 创建一个新的storeItem
                    newStoreItem = CS.UnityEngine.Object.Instantiate(storeItem)
                    CS.Utility.ReSetTransform(newStoreItem, storeItemParent)
                    newStoreItem.gameObject:SetActive(true)
                    ResetStoreContentData(newStoreItem, key, value, 1)
                    ResetStoreContentData(newStoreItem, nil, nil, 2)
                    else
                        ResetStoreContentData(newStoreItem, key, value, 2)
                    end
                    count  = count + 1
                elseif GameData.RoleInfo.VipLevel < 7 and count < 6 then
                    if count % 2 == 0 then
                    -- 创建一个新的storeItem
                    newStoreItem = CS.UnityEngine.Object.Instantiate(storeItem)
                    CS.Utility.ReSetTransform(newStoreItem, storeItemParent)
                    newStoreItem.gameObject:SetActive(true)
                    ResetStoreContentData(newStoreItem, key, value, 1)
                    ResetStoreContentData(newStoreItem, nil, nil, 2)
                    else
                        ResetStoreContentData(newStoreItem, key, value, 2)
                    end
                    count  = count + 1
                end
            end
        end
    end
    
    if count < 6 then
        for index = count, 5, 1 do
            if count % 2 == 0 then
                -- 创建一个新的storeItem
                newStoreItem = CS.UnityEngine.Object.Instantiate(storeItem)
                CS.Utility.ReSetTransform(newStoreItem, storeItemParent)
                newStoreItem.gameObject:SetActive(true)
                ResetStoreContentData(newStoreItem, nil, nil, 1)
            else
                ResetStoreContentData(newStoreItem, nil, nil, 2)
            end
            count  = count + 1
        end
    end

end

function UpgradeVIP_Lv()
    local GOLD=GameData.RoleInfo.PlayerNeedRechargeGold
    local LV=GameData.RoleInfo.PlayerUpgradeVip_LV
    if LV < 8 then
        LV=LV+1
        this.transform:Find('Canvas/StoreWindow/Title/Touuop'):GetComponent("Text").text=string.format(data.GetString("Topup_Upgrade_VIP"),GOLD,LV)
    else
        this.transform:Find('Canvas/StoreWindow/Title/Touuop'):GetComponent("Text").text=string.format(data.GetString("Topup_Upgrade_VIP_Max"),LV)
    end
end

function ResetStoreContentData(storeItem, key, storeConfig, index)
    local dataItem = storeItem:Find("Data"..index)
    if storeConfig ~= nil then
        dataItem.gameObject:SetActive(true)
        dataItem:Find("Name"):GetComponent("Text").text = storeConfig.Name
        local itemCountText = dataItem:Find("Item/ItemCount"):GetComponent("Text")
        itemCountText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(storeConfig.AddDiamond))
        itemCountText.rectTransform.sizeDelta = CS.UnityEngine.Vector2(itemCountText.preferredWidth, itemCountText.rectTransform.sizeDelta.y)
        if storeConfig.ID ~= 7 and storeConfig.ID ~= 8 then
            local giveGold=math.floor(GameConfig.GetFormatColdNumber(storeConfig.PresentAdd))
            local GiveText=dataItem:Find("Give"):GetComponent("Text")
            local GiveNumberText=dataItem:Find("Give/Number"):GetComponent("Text")
            GiveText.text=(data.GetString("VIP_Topup_Give"))
            GiveNumberText.text=""..giveGold
        else
            dataItem:Find("Give").gameObject:SetActive(false)
        end
        dataItem:Find("Gift").gameObject:SetActive(storeConfig.GiftRate ~= 0) 
        if storeConfig.GiftRate == 1 then 
            print("首冲双倍")
            dataItem:Find("Gift/Value1").gameObject:SetActive(true)
            dataItem:Find("Gift/Value").gameObject:SetActive(false)
        end
        --dataItem:Find("Gift/Value1").gameObject:SetActive(false)
        dataItem:Find("Gift/Value"):GetComponent("Text").text ="+" .. tostring(storeConfig.GiftRate) .. "%"
        dataItem:Find("Price/Value"):GetComponent("Text").text = string.format("￥%.2f", storeConfig.Price)
        dataItem:Find("Icon"):GetComponent("Image"):ResetSpriteByName(storeConfig.ItemIcon)
        dataItem:GetComponent("Button").onClick:AddListener(function () StoreItemButtonOnClick(storeConfig) end)
    else
        dataItem.gameObject:SetActive(false)
    end
end

function StoreItemButtonOnClick(storeConfig)
    if GameData.IsOpenApplePay == 1 and LoginMgr.RunningPlatformID == 3 then--直接走苹果支付流程
        print("苹果 支付")
        --调用platformbridge支付接口,打开loading界面
        CS.LoadingDataUI.Show(20)
        --构建信息json
        infoTable = {}
        infoTable["accountID"] = GameData.RoleInfo.AccountID
        infoTable["goodsID"] = storeConfig.ID
        infoTable["serverID"] = tostring(GameData.ServerID)
        infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
        PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_APP_STORE, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, infoJSON)
        
    else--打开支付界面
        --[[
        -- 小棍支付 直接开启支付界面
        if storeConfig.ID == 7 and storeConfig.Payment == 2 then
            -- 盛付通支付
            this.transform:Find('Canvas/ChargeWindow').gameObject:SetActive(true)
            ResetChargeContentPart(storeConfig)
        else
            selectStoreConfig = storeConfig
            XiaoGunPayReq()
        end
        ]]
        -- 有氧支付
        this.transform:Find('Canvas/ChargeWindow').gameObject:SetActive(true)
        ResetChargeContentPart(storeConfig)

    end
end

-- 关闭商城界面
function CloseStoreButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('UIStore', false)
end

-----------------------------------------------------------------------------------
-----------------------------------充值界面部分------------------------------------
function ResetChargeContentPart(storeConfig)
    selectStoreConfig = storeConfig
    if storeConfig ~= nil then		
        this.transform:Find('Canvas/ChargeWindow/Content/PayValue'):GetComponent("Text").text = string.format("￥%.2f", storeConfig.Price)
        if GameData.RoleInfo.VipLevel > 2 then
            this.transform:Find('Canvas/ChargeWindow/Content/ItemCount'):GetComponent("Text").text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(storeConfig.AddDiamond+storeConfig.PresentAdd))
        else
            this.transform:Find('Canvas/ChargeWindow/Content/ItemCount'):GetComponent("Text").text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(storeConfig.AddDiamond))
        end
        if storeConfig.Payment == 2 then
            this.transform:Find('Canvas/ChargeWindow/Content/ChargeWay').gameObject:SetActive(false)
            this.transform:Find('Canvas/ChargeWindow/Content/ChargeWayOf2').gameObject:SetActive(true)
        else
            this.transform:Find('Canvas/ChargeWindow/Content/ChargeWay').gameObject:SetActive(true)
            this.transform:Find('Canvas/ChargeWindow/Content/ChargeWayOf2').gameObject:SetActive(false)
        end
    else
        ResetStoreUI()
    end
end

-- 微信支付
function ChargeTypeOfWeiXinOnClick()
    CS.LoadingDataUI.Show(5)
    print('微信支付')
    KuaijiePayReq(PLATFORM_TYPE.PLATFORM_WEIXIN)
    
end

-- 支付宝支付
function ChargeTypeOfZhiFuBaoOnClick()
    CS.LoadingDataUI.Show(5)
    print('支付宝支付')
    KuaijiePayReq(PLATFORM_TYPE.PLATFORM_ALIPAY)
    
end

-- 号诺支付请求
function  H5PayBy99epay( platform )
    -- body
    --local payUrl = CS.AppDefine.HNPayUrl
    local payUrl = 'http://www.pay.changlaith.com/Pay/xiaogun/CreateOrder.php'
    paramTable = {}
    paramTable['aid'] = tostring(GameData.RoleInfo.AccountID)
    paramTable['sid'] = tostring(GameData.ServerID)
    paramTable['pid'] = tostring(platform)
    paramTable['cid'] = tostring(selectStoreConfig.ID)
    -- 平台标识
    paramTable['tid'] = "android"
    -- 1 windows 2 android 3 ios 4 macos
    if LoginMgr.RunningPlatformID == 3 then
        paramTable['tid'] = "ios"
    end
    print('url'..payUrl)
    -- 开始请求数据
    CS.LuaAsynFuncMgr.Instance:HttpPost(payUrl, paramTable, Http99epayCallBack)

end

-- H5支付第一次握手请求反馈
function Http99epayCallBack( paramResult )
    -- body
    CS.LoadingDataUI.Hide()
    

    if nil == paramResult then
        print('号诺支付失败1: paramResult nil')
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
        return
    end
    print(string.format("=====号诺支付请求反馈 Count[%d] Result:[%s]", #paramResult, paramResult))
    
    local index1 = string.find(paramResult, 'paycode=')
    local code = string.sub(paramResult, index1+8, index1+10)
    print('paycode = '..code)
    
    if code == "600" then
        local index2 = string.find(paramResult, 'payurl=')
        local url = string.sub(paramResult, index2+7)
        print ('payurl = '..url)
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        if 3 == currentPlatform then
            -- ios 平台
            CS.UnityEngine.Application.OpenURL(url)
        elseif 2 == currentPlatform then
            -- android 平台
            PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
        else
            --window平台测试用
            print("当前平台是window，走直接加钱流程")
            Send_CS_Buy_Goods()
        end
        CS.LoadingDataUI.Show(3)
    else
        -- 601 失败
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
    end
end

-- 小棍支付请求
function XiaoGunPayReq()
    CS.LoadingDataUI.Show(5)
    local payUrl = CS.AppDefine.XiaoGunPayUrl
    paramTable = {}
    paramTable['aid'] = tostring(GameData.RoleInfo.AccountID)
    paramTable['sid'] = tostring(GameData.ServerID)
    paramTable['cid'] = tostring(selectStoreConfig.ID)
    paramTable['account'] = GameData.LoginInfo.Account
    -- 平台标识
    paramTable['tid'] = "android"
    -- 1 windows 2 android 3 ios 4 macos
    if LoginMgr.RunningPlatformID == 3 then
        paramTable['tid'] = "ios"
    end

    -- 开始请求数据
    CS.LuaAsynFuncMgr.Instance:HttpPost(payUrl, paramTable, XiaoGunPayCallBack)

end

function XiaoGunPayCallBack(paramResult)

    CS.LoadingDataUI.Hide()
    
    if nil == paramResult then
        print('小棍支付失败1: paramResult nil')
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
        return
    end
    print(string.format("=====小棍支付请求反馈 Count[%d] Result:[%s]", #paramResult, paramResult))
    
    local index1 = string.find(paramResult, 'paycode=')
    local code = string.sub(paramResult, index1+8, index1+10)
    print('paycode = '..code)
    
    if code == "600" then
        local index2 = string.find(paramResult, 'payurl=')
        local url = string.sub(paramResult, index2+7)
        print ('payurl = '..url)
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        if 3 == currentPlatform then
            -- ios 平台
            print('=====ios===1===')
            url = url..'&channelCode=1'
            print('ios payurl= '..url)
            --CS.UnityEngine.Application.OpenURL(url)
            --CS.Utility.OpenEscapeURL(url)
            PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
            print('=====ios===2===')
        elseif 2 == currentPlatform then
            -- android 平台
            PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
        else
            --window平台测试用
            print("当前平台是window，走直接加钱流程")
            --CS.Utility.OpenEscapeURL(url)
            CS.Utility.OpenURL(url)
            Send_CS_Buy_Goods()
        end
        CS.LoadingDataUI.Show(3)
    else
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
    end
end

--全民金服支付请求
function QuanminPayReq(platform)
    local payUrl = CS.AppDefine.QuanMinPayUrl
    paramTable = {}
    paramTable['id'] = tostring(GameData.RoleInfo.AccountID)
    paramTable['serverId'] = tostring(GameData.ServerID)
    paramTable['commodityId'] = tostring(selectStoreConfig.ID)
    paramTable['notifyUrl'] = CS.AppDefine.QuanMinNotifyUrl
    paramTable['payMoney'] = tostring(selectStoreConfig.Price)
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    if 3 == currentPlatform then
        -- ios 平台
        paramTable['appType'] = '2'
    elseif 2 == currentPlatform then
        -- android 平台
        paramTable['appType'] = '1'
    else
        --测试用
        paramTable['appType'] = '1'
        --window平台测试用
        --print("当前平台是window，走直接加钱流程")
        Send_CS_Buy_Goods()
    end
    paramTable['payPlatform'] = tostring(platform)

    --开始请求数据
    CS.LuaAsynFuncMgr.Instance:HttpPost(payUrl, paramTable, QuanMinPayCallBack)
end

--全民金服服务器回调
function QuanMinPayCallBack(paramResult)
    CS.LoadingDataUI.Hide()
    if nil == paramResult then
        print('全民金服支付失败: paramResult nil')
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
        return
    end
    print(string.format("=====全民金服支付请求反馈 Count[%d] Result:[%s]", #paramResult, paramResult))

    local index1 = string.find(paramResult, 'paycode=')
    local code = string.sub(paramResult, index1+8, index1+10)
    print('paycode = '..code)
    
    if code == "600" then
        local index2 = string.find(paramResult, 'payurl=')
        local url = string.sub(paramResult, index2+7)
        print ('payurl = '..url)
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        if 3 == currentPlatform then
            -- ios 平台
            CS.UnityEngine.Application.OpenURL(url)
        elseif 2 == currentPlatform then
            -- android 平台
            CS.Utility.OpenURL(url)
            --PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
        else
            --window平台测试用
            print("当前平台是window，走直接加钱流程")
            CS.Utility.OpenURL(url)
        end
        CS.LoadingDataUI.Show(3)
    else
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
    end
end

-- 快接支付请求
function KuaijiePayReq(platform)
    local payUrl = 0
    if platform == PLATFORM_TYPE.PLATFORM_ALIPAY then
        payUrl = CS.AppDefine.KuaijieZhifubaoPayUrl
    elseif platform == PLATFORM_TYPE.PLATFORM_WEIXIN then
        payUrl = CS.AppDefine.KuaijieWeixinPayUrl
    end
    
    paramTable = {}
    paramTable['id'] = tostring(GameData.RoleInfo.AccountID)
    paramTable['goods_name'] = tostring(selectStoreConfig.Name)
    paramTable['goods_desc'] = tostring(selectStoreConfig.Name)
    paramTable['trade_amount'] = tostring(selectStoreConfig.Price)
    paramTable['serverId'] = tostring(GameData.ServerID)
    paramTable['commodityId'] = tostring(selectStoreConfig.ID)
    
    if platform == PLATFORM_TYPE.PLATFORM_WEIXIN then
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        if 3 == currentPlatform then
            -- ios 平台
            paramTable['appType'] = '1'
        elseif 2 == currentPlatform then
            -- android 平台
            paramTable['appType'] = '2'
        else
            -- windows平台
            paramTable['appType'] = '3'
        end
    end

    --开始请求数据
    CS.LuaAsynFuncMgr.Instance:HttpPost(payUrl, paramTable, KuaijiePayCallBack)
end

-- 快接支付服务器回调
function KuaijiePayCallBack(paramResult)
    CS.LoadingDataUI.Hide()
    if nil == paramResult then
        print('快接支付失败: paramResult nil')
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
        return
    end
    print ("...........", paramResult)
    local index1 = string.find(paramResult, 'paycode=')
    local code = string.sub(paramResult, index1+8, index1+10)
    
    if code == "600" then
        local index2 = string.find(paramResult, 'payurl=')
        local url = string.sub(paramResult, index2+7)
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        if 3 == currentPlatform then
            -- ios 平台
            CS.UnityEngine.Application.OpenURL(url)
        elseif 2 == currentPlatform then
            -- android 平台
            CS.Utility.OpenURL(url)
            --PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
        else
            --window平台测试用
            print("当前平台是window，走直接加钱流程")
            CS.Utility.OpenURL(url)
        end
        CS.LoadingDataUI.Show(3)
    else
        CS.BubblePrompt.Show("支付请求失败", "UIStore")
    end
end

-- 苹果充值响应
function ChargeTypeOfAppleOnClick()
    -- 苹果支付
end

-- SFT 点卡支付响应
function ChargeTypeOfDianKaOnClick()	
    
    local cardID = this.transform:Find('Canvas/ChargeWindow/Content/ChargeWayOf2/CardID'):GetComponent("InputField").text
    local password = this.transform:Find('Canvas/ChargeWindow/Content/ChargeWayOf2/Password'):GetComponent("InputField").text
    if cardID == nil or #cardID == 0 then
        return
    end
    
    if password == nil or #password == 0 then
        return
    end
    
    

    --print('盛付通支付')
    CS.LoadingDataUI.Show(5)
    url = CS.AppDefine.SFTPayUrl
    
    paramTable = {}
    paramTable['aid'] = tostring(GameData.RoleInfo.AccountID)
    paramTable['sid'] = tostring(GameData.ServerID)
    paramTable['pid'] = tostring(PLATFORM_TYPE.PLATFORM_SDO)
    paramTable['cid'] = tostring(selectStoreConfig.ID)
    paramTable['card'] = string.format('%s_%s', cardID, password)
    
    CS.LuaAsynFuncMgr.Instance:HttpPost(url, paramTable, SFTHttpPayCallBack)
end

-- SFT 支付Http回调
function SFTHttpPayCallBack(paramStr)
    CS.LoadingDataUI.Hide()
    print('盛付通支付 http post 回调 paramStr = '..paramStr)
    print("string.len="..string.len(paramStr))
    if string.len(paramStr) < 3 then
        print("返回的字符串长度小于3，这非常奇怪")
        return
    end
    
    
    local index1 = string.find(paramStr, 'paycode=')
    local code = string.sub(paramStr, index1+8, index1+10)
    
    --local result = string.sub(paramStr, 1, 3)
    if code == "600" then
        print('盛付通支付成功')
        --CS.BubblePrompt.Show("支付成功!","UIStore")
    elseif code == "601" then
        print('盛付通支付失败')
        CS.BubblePrompt.Show("支付失败!","UIStore")
    elseif code == "602" then
        local index2 = string.find(paramStr, 'errorcode=')
        errorReason = string.sub(paramStr, index2 + 10)
        print("错误原因:"..errorReason)
        tipsStr = data.GetString(errorReason)
        CS.BubblePrompt.Show(tipsStr,"UIStore")
    else
        print('盛付通支付失败')
        CS.BubblePrompt.Show("支付失败!","UIStore")
    end
end

-- 充值选择页面关闭响应
function CloseChargeButtonOnClick()
    ResetStoreUI()
end

---------------------------------------------------------------------------
------------------------CS_Buy_Goods  900----------------------------------
function Send_CS_Buy_Goods()
    if selectStoreConfig ~= nil then
        local message = CS.Net.PushMessage()
        message:PushUInt32(GameData.RoleInfo.AccountID)
        message:PushByte(selectStoreConfig.ID)
        NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Buy_Goods, message, true)
    end
end

function Received_CS_Buy_Goods(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        ResetStoreUI()
        CS.BubblePrompt.Show("购买成功", "UIStore")
    end
end