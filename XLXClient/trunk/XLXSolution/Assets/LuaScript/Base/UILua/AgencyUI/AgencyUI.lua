local MyTransform = nil

local mToggleGroup = nil
local mToggle1 = nil
local mToggle2 = nil
local mToggle3 = nil

local mToggle1Label = nil
local mToggle2Label = nil
local mToggle3Label = nil
local mGuideNodeGameObject = nil
--=================[我的推广]节点 Begin========================================
local mMyNodeGameObject = nil
local mMyNodeNO1 = nil
local mMyNodeNO2 = nil
local mMyNodeOK1 = nil
local mHeadIcon = nil               -- 头像Icon
local mVIPLevel = nil               -- VIP等级
local mZRYJText = nil               -- 昨日业绩
local mZSYJText = nil               -- 直属会员业绩
local mQTYJText = nil               -- 其他会员业绩
local mZSMember = nil               -- 直属成员
local mQTMember = nil               -- 其他成员

local mMyNodeOK2 = nil
local mQRCodeRawImage = nil         -- 二维码Image
local mQRCodeRawHeadIcon = nil      -- 二维码上方头像
local mHelpGameObject = nil         -- 帮助说明

local mMyNodeOK3 = nil
local mHistoryText = nil            -- 历史总佣金
local mRewardText = nil             -- 可以提取佣金
local mReceiveGameObject = nil      -- 领取成功节点
local mReceiveText = nil            -- 佣金领取成功的钱
local mRewardBtn = nil              -- 佣金领取按钮
local mRewardBtnDis = nil           -- 佣金领取按钮灰色

--TUDOU
--提现
local mask_Window_Withdraw = nil;		--遮罩
local window_Withdraw = nil;			--提现弹窗
local zfbBtn = nil
local zfbFlag = nil
local zfbFlagBg = nil
local zfbText = nil
local zfbNameText = nil
local zfbAccountText = nil
local bankBtn = nil
local bankFlag = nil
local bankFlagBg = nil
local bankText = nil
local bankNameText = nil
local bankAccountText = nil
local button_Close = nil;				--关闭按钮
local text_Count_Withdraw = 0;			--提现金额
-- local text_Formula = "";				--提现公式
local button_Withdraw = nil;			--【确认提现】按钮
local button_Cancel = nil;				--【取消】按钮

function InitMyNodeUI()

    --提现
	local tempPath = "Canvas/Window/MyNode/Window_Withdraw"
	mask_Window_Withdraw = this.transform:Find("Canvas/Window/MyNode/Mask_Window_Withdraw")
	window_Withdraw = this.transform:Find(tempPath);

    zfbBtn = window_Withdraw:Find("Zhifubao"):GetComponent("Button")
    zfbFlag = window_Withdraw:Find("Zhifubao/Checkmark").gameObject
    zfbFlagBg = window_Withdraw:Find("Zhifubao/Background").gameObject
    zfbText = window_Withdraw:Find("Zhifubao/Text").gameObject
    zfbNameText = window_Withdraw:Find("Zhifubao/ZfbName"):GetComponent("Text")
    zfbAccountText = window_Withdraw:Find("Zhifubao/ZfbAccount"):GetComponent("Text")

    bankBtn = window_Withdraw:Find("Bank"):GetComponent("Button")
    bankFlag = window_Withdraw:Find("Bank/Checkmark").gameObject
    bankFlagBg = window_Withdraw:Find("Bank/Background").gameObject
    bankText = window_Withdraw:Find("Bank/Text").gameObject
    bankNameText = window_Withdraw:Find("Bank/BankName"):GetComponent("Text")
    bankAccountText = window_Withdraw:Find("Bank/BankAccount"):GetComponent("Text")

	button_Close = this.transform:Find(tempPath.."/Title/Button_Close"):GetComponent("Button");
	text_Count_Withdraw = this.transform:Find(tempPath.."/Center/Count_Withdraw"):GetComponent("Text");
	button_Withdraw = this.transform:Find(tempPath.."/Button/Button_Withdraw"):GetComponent("Button");
	button_Cancel = this.transform:Find(tempPath.."/Button/Button_Cancel"):GetComponent("Button");
	mask_Window_Withdraw.gameObject:SetActive(false);
    window_Withdraw.gameObject:SetActive(false);
    --TUDOU(提现)
	mask_Window_Withdraw:GetComponent("Button").onClick:AddListener(function()
		CloseWithdrawWindow();
	end)
	button_Close.onClick:AddListener(function()
		CloseWithdrawWindow();
	end)
	button_Withdraw.onClick:AddListener(function()
		WithdrawWindowOk();
	end)
	button_Cancel.onClick:AddListener(function()
		WithdrawWindowCancel();
	end)

    zfbBtn.onClick:AddListener(function()
        selectZfb();
    end)
    bankBtn.onClick:AddListener(function()
        selectBank();
    end)

    local tTransform = MyTransform:Find("Canvas/Window/MyNode")
    mMyNodeGameObject = tTransform.gameObject
    
    mMyNodeNO1 = tTransform:Find("ContentNO1").gameObject
    mMyNodeNO2 = tTransform:Find("ContentNO2").gameObject

    mMyNodeOK1 = tTransform:Find("ContentOK1").gameObject
    mHeadIcon = tTransform:Find("ContentOK1/BgLeft/Icon"):GetComponent("Image")
    mVIPLevel = tTransform:Find("ContentOK1/BgLeft/Text"):GetComponent("Text")
    mZRYJText = tTransform:Find("ContentOK1/BgRight1/Num"):GetComponent("Text")
    mZSYJText = tTransform:Find("ContentOK1/BgRight2/Num"):GetComponent("Text")
    mQTYJText = tTransform:Find("ContentOK1/BgRight3/Num"):GetComponent("Text")
    mZSMember = tTransform:Find("ContentOK1/BgBotttom1/Num"):GetComponent("Text")
    mQTMember = tTransform:Find("ContentOK1/BgBotttom2/Num"):GetComponent("Text")
    
    mMyNodeOK2 = tTransform:Find("ContentOK2").gameObject
    mQRCodeRawImage = tTransform:Find("ContentOK2/QRCode/Icon"):GetComponent("RawImage")
    mQRCodeRawHeadIcon = tTransform:Find("ContentOK2/QRCode/Head"):GetComponent("Image")
    mHelpGameObject = tTransform:Find("Help").gameObject
    tTransform:Find("ContentOK2/ButtonQuestion"):GetComponent("Button").onClick:AddListener(function () GameObjectSetActive(mHelpGameObject, true) end)
    tTransform:Find("Help/Title/CloseBtn"):GetComponent("Button").onClick:AddListener(function () GameObjectSetActive(mHelpGameObject, false) end)
    tTransform:Find("ContentOK2/Buttons/ButtonSave1"):GetComponent("Button").onClick:AddListener(ButtonSaveOnClick)
    tTransform:Find("ContentOK2/Buttons/ButtonSave2"):GetComponent("Button").onClick:AddListener(ShareOfficialNetwork)
    this.transform:Find('Canvas/Window/MyNode/ContentNO1/QQ/Image'):GetComponent('Button').onClick:AddListener(OpenCaiFuQQ)
    this.transform:Find('Canvas/Window/GuideNode/ContentNO2/QQ/Image'):GetComponent('Button').onClick:AddListener(OpenCaiFuQQ)

    this.transform:Find('Canvas/Window/MyNode/ContentNO1/ShareButton'):GetComponent("Button").onClick:AddListener(ShareOfficialNetwork)

    mMyNodeOK3 = tTransform:Find("ContentOK3").gameObject
    mHistoryText = tTransform:Find("ContentOK3/HistoryText"):GetComponent("Text")
    mRewardText = tTransform:Find("ContentOK3/RewardText"):GetComponent("Text")
    mReceiveGameObject = tTransform:Find("Receive").gameObject
    mReceiveText = tTransform:Find("Receive/ReceiveText"):GetComponent("Text")
    tTransform:Find("Receive/KOButton"):GetComponent("Button").onClick:AddListener(function () GameObjectSetActive(mReceiveGameObject, false) end)

    tTransform:Find("ContentOK3/BtnRecord"):GetComponent("Button").onClick:AddListener(BtnRecordOnClick)
    tTransform:Find("ContentOK3/BtnTuiGuang"):GetComponent("Button").onClick:AddListener(BtnTuiGuangOnClick)
    mRewardBtnDis = tTransform:Find("ContentOK3/ButtonReward/DisableImage").gameObject
    mRewardBtn = tTransform:Find("ContentOK3/ButtonReward"):GetComponent("Button")
    mRewardBtn.onClick:AddListener(ButtonRewardOnClick)

    GameObjectSetActive(mHelpGameObject, false)
    GameObjectSetActive(mReceiveGameObject, false)
    GameObjectSetActive(mRewardBtnDis, false)

    GameObjectSetActive(zfbFlag, false)
    GameObjectSetActive(bankFlag, false)

    if GameData.RoleInfo.IsBindZhifubao then
        GameObjectSetActive(zfbFlagBg, true)
        GameObjectSetActive(zfbText, false)
    else
        GameObjectSetActive(zfbFlagBg, false)
        GameObjectSetActive(zfbText, true)
    end

    if GameData.RoleInfo.IsBindBank then
        GameObjectSetActive(bankFlagBg, true)
        GameObjectSetActive(bankText, false)
    else
        GameObjectSetActive(bankFlagBg, false)
        GameObjectSetActive(bankText, true)
    end
    --RefreshQRCode()
end

function selectZfb()
    if GameData.RoleInfo.IsBindZhifubao then
        GameObjectSetActive(zfbFlag, true)
        GameObjectSetActive(bankFlag, false)
    end
end

function selectBank()
    if GameData.RoleInfo.IsBindBank then
        GameObjectSetActive(zfbFlag, false)
        GameObjectSetActive(bankFlag, true)
    end
end

--TUDOU
function CloseWithdrawWindow()			--关闭提现提示界面
	mask_Window_Withdraw.gameObject:SetActive(false);
	window_Withdraw.gameObject:SetActive(false);
end
function OpenWithdrawWindow()
	text_Count_Withdraw.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.PayableCommission));
	mask_Window_Withdraw.gameObject:SetActive(true);
	window_Withdraw.gameObject:SetActive(true);
end
function WithdrawWindowOk()
    if zfbFlag.activeSelf or bankFlag.activeSelf then
        if zfbFlag.activeSelf then
            NetMsgHandler.Send_CS_Get_AgencyCommission(2, 2);
        else
            NetMsgHandler.Send_CS_Get_AgencyCommission(2, 1);
        end
    else
        CS.BubblePrompt.Show(data.GetString("请选择提现方式" ), "UIExtract")
    end
end
function WithdrawWindowCancel()
	CloseWithdrawWindow(); 
end


-- 二维码刷新设置
function RefreshQRCode()
    if GameConfig.TGSharedUrl == "" then
        GameConfig.TGSharedUrl = "http://www."..GameConfig.KFUrl
    end
    local url = string.format("%s?GameID=%d&referralsID=%d&referralsChannel=%d", GameConfig.TGSharedUrl, CS.AppDefine.GameID, GameData.RoleInfo.AccountID, GameData.ChannelCode)
    CS.Utility.CreateBarcode(mQRCodeRawImage, url, 256, 256)
end

-- 保存图片到手机
function ButtonSaveOnClick()
    this:DelayInvoke(0.6 , function()
        CS.BubblePrompt.Show("个人二维码已保存至系统相册！", "QRCCodeUI")
    end)
    CS.Utility.SaveImg()
end

-- 提取记录call
function BtnRecordOnClick()
    CS.WindowManager.Instance:OpenWindow("AgencyExtractUI")
end

-- 推广明细call
function BtnTuiGuangOnClick()
    CS.WindowManager.Instance:OpenWindow("AgencyMemberUI")
end

-- 提取佣金call
function ButtonRewardOnClick()

    if GameData.RoleInfo.IsBindBank == false and GameData.RoleInfo.IsBindZhifubao == false then
		CS.BubblePrompt.Show(data.GetString("请绑定支付宝或银行卡" ), "AgencyUI")
		return
    end
    local tempData = GameConfig.GetFormatColdNumber(GameData.AgencyInfo.PayableCommission);
    if tempData < 50 then
        CS.BubblePrompt.Show(data.GetString("提现金额必须>=50" ), "AgencyUI")
        return;
    end
    if GameData.RoleInfo.IsBindBank or GameData.RoleInfo.IsBindZhifubao then
        NetMsgHandler.Send_CS_Get_AgencyCommission(1, 1);
    end
    
end

local tempCharge = 0;
--TUDOU
-- 佣金领取成功
function ON_NotifyAgencyCommissionEvent(commissionParam)
    if GameData.AgencyInfo.isGetData == 1 then
        tempCharge = GameData.AgencyInfo.PayableCommission;
        OpenWithdrawWindow();
    elseif GameData.AgencyInfo.isGetData == 2 then
		CloseWithdrawWindow();
        local tempstr = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tempCharge))
        CS.BubblePrompt.Show(string.format(data.GetString("Player_Extract_Erro_0"), tempstr),"AgencyUI")
        -- GameObjectSetActive(mReceiveGameObject, true)
        mReceiveText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(commissionParam))
        mRewardText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.PayableCommission))
        mRewardBtn.interactable = false
        -- GameObjectSetActive(mRewardBtnDis, true)
    end
    -- GameObjectSetActive(mReceiveGameObject, true)
    -- mReceiveText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(commissionParam))
    -- mRewardText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.PayableCommission))
    -- mRewardBtn.interactable = false
    -- GameObjectSetActive(mRewardBtnDis, true)
end

-- 代理数据刷新
function On_NotifyAgencyEvent()
    RefreshQRCode()
    GameObjectSetActive(mMyNodeGameObject, true)
    local tIsAgency = GameData.AgencyInfo.IsAgent == 1
    GameObjectSetActive(mMyNodeNO1, lua_NOT_BOLEAN(tIsAgency))
    GameObjectSetActive(mMyNodeNO2, lua_NOT_BOLEAN(tIsAgency))
    GameObjectSetActive(mMyNodeOK1, tIsAgency)
    GameObjectSetActive(mMyNodeOK2, tIsAgency)
    GameObjectSetActive(mMyNodeOK3, tIsAgency)
    if tIsAgency then
        --[[local currentPlatform = CS.Utility.GetCurrentPlatform();
        if currentPlatform ~= 3 then
            mMyNodeOK2.transform:Find('Buttons/GameObject').gameObject:SetActive(false)
            mMyNodeOK2.transform:Find('Buttons/ButtonSave2').gameObject:SetActive(false)
        end--]]
        mHeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon))
        --mQRCodeRawHeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon))
        mVIPLevel.text = "" .. GameData.RoleInfo.VipLevel
        mZRYJText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.ZRTotalCommission))
        mZSYJText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.ZRZSCommission))
        mQTYJText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.ZRQTCommission))
        mZSMember.text = tostring(GameData.AgencyInfo.ZSTotalMember)
        mQTMember.text = tostring(GameData.AgencyInfo.QTTotalMember)
        mHistoryText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.AgencyInfo.TotalCommission))
        local tPayableCommission = GameData.AgencyInfo.PayableCommission
        mRewardText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tPayableCommission))
        mRewardBtn.interactable = tPayableCommission > 0
        GameObjectSetActive(mRewardBtnDis, lua_NOT_BOLEAN(mRewardBtn.interactable))

        mToggle2.enabled = true
        mToggle3.enabled = true
    else
        mToggle2.enabled = false
        mToggle3.enabled = false
    end
    GameObjectSetActive(mToggleGroup, tIsAgency)
    if GameData.AgencyInfo.IsAgent ~= SALESMAN.NULL and GameData.RoleInfo.IsEnterTGFF == true then
        GameData.RoleInfo.IsEnterTGFF = false
        GameObjectSetActive(mMyNodeGameObject, false)
        GameObjectSetActive(mGuideNodeGameObject, true)
        OnTotalValueChanged(true,2)
        mToggle1.isOn = false
        mToggle2.isOn = true
    end
end

-- 分享官网
function ShareOfficialNetwork()
    local tNode= CS.WindowManager.Instance:FindWindowNodeByName("ShareUI")
    if tNode == nil then
        CS.WindowManager.Instance:OpenWindow("ShareUI")
    end
end

--=================[我的推广]节点   End========================================


--=================[推广教程]节点 Begin========================================

function InitGuideUI()
    mGuideNodeGameObject = MyTransform:Find("Canvas/Window/GuideNode").gameObject
end

--=================[推广教程]节点   End========================================

--=================[佣金提取榜]节点 Begin======================================
local mRankNodeGameObject = nil
local mDayRankText = nil            -- 日榜Text
local mWeekRankText = nil           -- 周榜Text
local mMonthRankText = nil          -- 月榜Text

local mRankItems = {}               -- 排行榜数据Items
-- 代理排行榜类型
local mGAME_RANK_TYPE = GAME_RANK_TYPE.DL_EXTRACT_WEEK

function InitRankNodeUI()
    local tTransform = MyTransform:Find("Canvas/Window/RankNode")
    mRankNodeGameObject = tTransform.gameObject

    mDayRankText = tTransform:Find("RankList/ToggleGroup/Toggle1/Label2").gameObject
    mWeekRankText = tTransform:Find("RankList/ToggleGroup/Toggle2/Label2").gameObject
    mMonthRankText = tTransform:Find("RankList/ToggleGroup/Toggle3/Label2").gameObject

    tTransform:Find("RankList/ToggleGroup/Toggle1"):GetComponent('Toggle').onValueChanged:AddListener( function(isOn) 
        OnRankValueChanged(isOn, GAME_RANK_TYPE.DL_EXTRACT_DAY) end)
    tTransform:Find("RankList/ToggleGroup/Toggle2"):GetComponent('Toggle').onValueChanged:AddListener( function(isOn) 
        OnRankValueChanged(isOn, GAME_RANK_TYPE.DL_EXTRACT_WEEK) end)
    tTransform:Find("RankList/ToggleGroup/Toggle3"):GetComponent('Toggle').onValueChanged:AddListener( function(isOn) 
        OnRankValueChanged(isOn, GAME_RANK_TYPE.DL_EXTRACT_MONTH) end)


    local tContent = tTransform:Find("RankList/Viewport/Content")
    for i = 1, 20 do
        local tItem = {}
        local tNode = tContent:Find("RankItem"..i)
        tItem.RootGameObject = tNode.gameObject
        tItem.Bg01 = tNode:Find("Bg01").gameObject
        tItem.Bg02 = tNode:Find("Bg02").gameObject
        tItem.RankFlag = tNode:Find("RankFlag"):GetComponent("Image")
        tItem.RankID = tNode:Find("RankID"):GetComponent("Text")
        tItem.HeadIcon = tNode:Find("HeadIcon"):GetComponent("Image")
        tItem.AccountName = tNode:Find("AccountName"):GetComponent("Text")
        tItem.RichValue = tNode:Find("RichValue"):GetComponent("Text")
        tItem.VIP = tNode:Find('HeadIcon/VipLevel/Value'):GetComponent("Text")
        mRankItems[i] = tItem
        GameObjectSetActive(tItem.RootGameObject, false)
    end

    GameObjectSetActive(mDayRankText, false)
end

-- 选择排行榜切换
function OnRankValueChanged(isOn, rankType)
    GameObjectSetActive(mDayRankText, true)
    GameObjectSetActive(mWeekRankText, true)
    GameObjectSetActive(mMonthRankText, true)
    if isOn then
        if rankType == GAME_RANK_TYPE.DL_EXTRACT_DAY then
            GameObjectSetActive(mDayRankText, false)
        elseif rankType == GAME_RANK_TYPE.DL_EXTRACT_WEEK then
            GameObjectSetActive(mWeekRankText, false)
        elseif rankType == GAME_RANK_TYPE.DL_EXTRACT_MONTH then
            GameObjectSetActive(mMonthRankText, false)
        end
        mGAME_RANK_TYPE = rankType
        TryGetRankData(rankType)
    end
end
-- 是否读取本地排行榜信息
function JudgmentTimeInterval(rankType)
    if rankType < 21 then
        rankType = rankType + 18
    end
    if rankType == 21 then
        if GameData.RankInfo.DaiLiRiBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiRiBangTime >= 60 then
            return true
        end
    elseif rankType == 22 then
        if GameData.RankInfo.DaiLiZhouBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiZhouBangTime >= 60 then
            return true
        end
    elseif rankType == 23 then
        if GameData.RankInfo.DaiLiYueBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiYueBangTime >= 60 then
            return true
        end
    end
    return false
end

-- 尝试获取排行榜数据
function TryGetRankData(rankType)
    if JudgmentTimeInterval(rankType) == true then
        NetMsgHandler.SendRequestRanks(mGAME_RANK_TYPE)
    else
        RefreshRankInfo(rankType)
    end
end

-- 排行榜数据信息
function RankTypeInfo(rankType)
    if rankType == 21 then
        return GameData.RankInfo.DaiLiRiBang
    elseif rankType == 22 then
        return GameData.RankInfo.DaiLiZhouBang
    elseif rankType == 23 then
        return GameData.RankInfo.DaiLiYueBang
    end
end

-- 排行榜数据刷新
function RefreshRankInfo(rankType)
    for i = 1, 20 do
        GameObjectSetActive(mRankItems[i].RootGameObject, false)
    end
    local RichList = RankTypeInfo(rankType)
    for i = 1, #RichList, 1 do
        local tUINode = mRankItems[i]
        if tUINode ~= nil then
            GameObjectSetActive(tUINode.RootGameObject, true)
            GameObjectSetActive(tUINode.Bg01, i % 2 == 1)
            GameObjectSetActive(tUINode.Bg02, i % 2 == 0)
            if i <= 3 then
                tUINode.RankFlag:ResetSpriteByName('sprite_Rank_Flag_'..i)
            else
                GameObjectSetActive(tUINode.RankFlag.gameObject, false)
            end
            RefreshDailiData(RichList[i], tUINode)
        end
    end
end

--刷新数据
function RefreshDailiData(tData, tNode)
    tNode.RankID.text = tostring(tData.RankID)
    tNode.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(tData.HeadIcon))
    tNode.AccountName.text = tData.AccountName
    tNode.VIP.text = "V"..tData.VipLevel
    --tNode.RichValue.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tData.RichValue))
    tNode.RichValue.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(tData.RichValue),2))
end

-- 佣金排行榜数据更新
function ON_NotifyRankEvent(rankType)
    RefreshRankInfo(rankType)
end

function setBindInfo()
    zfbNameText.text = GameData.BankInformation.ZhiFuBaoName
    zfbAccountText.text = GameData.BankInformation.ZhiFuBaoAccount
    bankNameText.text = GameData.BankInformation.BankName
    --bankAccountText.text = tostring(GameData.BankInformation.BankCardNumber)
end

--=================[佣金提取榜]节点   End======================================

function ReturnButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('AgencyUI', false)
end

function OnTotalValueChanged(isOn, typeParam)
    GameObjectSetActive(mToggle1Label, true)
    GameObjectSetActive(mToggle2Label, true)
    GameObjectSetActive(mToggle3Label, true)
    if isOn then
        GameObjectSetActive(mMyNodeGameObject, typeParam == 1)
        GameObjectSetActive(mGuideNodeGameObject, typeParam == 2)
        GameObjectSetActive(mRankNodeGameObject, typeParam == 3)
        if typeParam == 1 then
            GameObjectSetActive(mToggle1Label, false)
        elseif typeParam == 2 then
            GameObjectSetActive(mToggle2Label, false)
        elseif typeParam == 3 then
            GameObjectSetActive(mToggle3Label, false)
            TryGetRankData(typeParam)
        end
    end
end

-- 复制并打开财富顾问QQ
function OpenCaiFuQQ()
    
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    if currentPlatform == 3 then
        local QQNumber = data.PublicConfig.WealthQQ
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, QQNumber)
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, QQNumber)
    elseif currentPlatform == 2 then
        local QQNumber = data.PublicConfig.WealthQQ
        local inputString = "mqqwpa://im/chat?chat_type=wpa&uin="..QQNumber
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, QQNumber)
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, inputString)
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    MyTransform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(ReturnButtonOnClick)
    
    mToggle1Label = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle1/Label2").gameObject
    mToggle1Label:SetActive(false)
    mToggle2Label = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle2/Label2").gameObject
    mToggle3Label = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle3/Label2").gameObject

    mToggleGroup = MyTransform:Find("Canvas/Window/ToggleGroup").gameObject
    mToggle1 = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle1"):GetComponent('Toggle')
    mToggle2 = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle2"):GetComponent('Toggle')
    mToggle3 = MyTransform:Find("Canvas/Window/ToggleGroup/Toggle3"):GetComponent('Toggle')
    mToggle1.onValueChanged:AddListener( function(isOn) OnTotalValueChanged(isOn, 1) end)
    mToggle2.onValueChanged:AddListener( function(isOn) OnTotalValueChanged(isOn, 2) end)
    mToggle3.onValueChanged:AddListener( function(isOn) OnTotalValueChanged(isOn, 3) end)

    InitGuideUI()
    InitMyNodeUI()
    InitRankNodeUI()
    GameObjectSetActive(mMyNodeGameObject, false)
    GameObjectSetActive(mGuideNodeGameObject, false)
    GameObjectSetActive(mRankNodeGameObject, false)
    GameObjectSetActive(mToggleGroup, false)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    NetMsgHandler.Send_CS_OpenMyAgency()
    local Index =math.random(2)
	local musicid = "OpenPromoters"..Index
	MusicMgr:PlaySoundEffect(musicid)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAgencyEvent, On_NotifyAgencyEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAgencyCommissionEvent, ON_NotifyAgencyCommissionEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRankEvent, ON_NotifyRankEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerPutForwardInfo, setBindInfo)

    NetMsgHandler.Send_CS_Player_ExtractInfo()
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAgencyEvent, On_NotifyAgencyEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAgencyCommissionEvent, ON_NotifyAgencyCommissionEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRankEvent, ON_NotifyRankEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerPutForwardInfo, setBindInfo)
end
