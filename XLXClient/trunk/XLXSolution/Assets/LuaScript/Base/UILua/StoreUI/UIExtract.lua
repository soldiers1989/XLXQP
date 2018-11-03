
local RechargeGameObject = nil				-- 充值界面
local BindingBankCardGameObject = nil		-- 绑定界面
local BindingBankTypeText = nil             -- 绑定类型
local NamePromptText = nil					-- 绑定名字提示
local AccountPromptText = nil				-- 绑定账号提示
local PromptText = nil 						-- 绑定界面温馨提示
local IsBindingBankCardGameObject = nil		-- 提现界面未绑定组件
local BillInfoTemplateGameObject = nil      -- 账单信息模板
local BillInfoTemplatePrintGameObject = nil -- 账单信息模板父节点
local BankNameSelect = nil					-- 银行名称选择界面
local BankNameImage1 = nil					-- 银行名称选择界面下拉图片
local BankNameImage2 = nil					-- 银行名称选择界面上拉图片
local QRButton1 = nil                       -- 复制收款人按钮
local QRButton2Text = nil                   -- 复制卡号文本
local RechargeInfoObject1 = nil             -- 银行充值描述Object
local RechargeInfoObject2 = nil             -- 非银行充值描述Object
local RechargeInfo1 = {}                    -- 银行充值描述文本
local RechargeInfo2 = {}                    -- 非银行充值描述文本
local OrderNumberText = nil                 -- 订单号
local OrderTimeText = nil                   -- 订单时间
local DuiHaoImage = {}                      -- 对号图片
local OfficePromptText = nil
local TypeObject = nil

local RechargeAmountValueMin = nil				-- 充值额度最低
local RechargeAmountValueMax = nil				-- 充值额度最高
local WithdrawMoneyValueMin = nil				-- 提现额度最低
local WithdrawMoneyValueMax = nil				-- 提现额度最大

local BankNameIntem = nil						-- 银行名称模板
local BankNamePater = nil						-- 银行名称父节点

--TUDOU
local RechargeMode = -1   -- 充值方式（1支付宝 2QQ钱包 3微信 4 银行卡 5支付宝扫码 6QQ扫码 7微信扫码 8支付宝定额 9微信定额 10点卡 0 VIP代理充值）
local WithdrawMoneyMode = 0 -- 提现方式(1银行卡 2支付宝)

local IsUpdateBankInfo = false --是否更改绑定信息（false更改 true不更改）

local BindingInfo = 1 --绑定类型(1银行卡 2支付宝 3 微信)

-- 充值额度
local RechargeAmountValue = nil
-- 提现额度
local WithdrawMoneyValue = nil
-- 绑定人名字（必填）
local BindingName = ""
-- 绑定人卡号（必填）
local BindingCardNumber = ""
-- 绑定人卡号名称（选填）
local BingdingCardName = ""
-- 绑定人开户省份（选填）
local BingdingOpenAnAccountProvince = ""
-- 绑定人开户城市（选填）
local BingdingOpenAnAccountCity = ""
-- 绑定人开户支行（选填）
local BindingOpenAnAccountSubbranch = ""
-- 充值人姓名
local RechargeName = ""
-- 充值人姓名 Input
local RechargeInPut = nil
-- 存款方式
local RechargeType = 0

-- 是否绑定银行卡
local IsBindingBankCard = 0
-- 最大充值金额
local MaxValue = 99999999999999999999999999999999999

-- 投诉代理信息
local ComplaintText = ""

--TUDOU
--弹窗遮罩
local mask;
--举报有奖【弹窗】
local window_Report;
--客服中心【弹窗】
local window_ServiceCenter;
--联系代理【弹窗】
local window_ContactAgency;

-- 代理父节点
local DaiLiItemParent = nil
-- 代理模板
local DaiLiItem = nil

-- 官方ContentObject
local OfficialContentObject = nil

-- 官方充值模板父节点
local OfficialItemParent = nil
-- 官方充值模板
local OfficialItem = {}

-- 代理索引
local DaiLiIndex = 0
-- 联系客服信息
local ContactCustomerText = ""

--TUDOU
--提现
local mask_Window_Withdraw = nil;		--遮罩
local window_Withdraw = nil;			--提现弹窗
local button_Close = nil;				--关闭按钮
local text_Count_Withdraw = 0;			--提现金额
local text_Count_Charge = 0;			--手续费用
-- local text_Formula = "";				--提现公式
local button_Withdraw = nil;			--【确认提现】按钮
local button_Cancel = nil;				--【取消】按钮

local BindError = nil

local isUpdateCodeCountDown = false
local VIPCenter = nil
local VIPTitle = nil
local RechargeTypeName = {}
local OrdinaryRecharge = nil
local RechargeButton = nil
local RechargeTypeButtonItemPrint = nil
local RechargeTypeButtonItem = nil
local RechargeInterface = nil
local MyIdText = nil
local ValueButtonObject = nil
local ValueButtonText = {}
local ValueButton = {}
local InputAmountObject = nil
local RechargePlaceholderText = nil
local RechargeInputFieldText = nil
local MobilePhoneObject = nil
local BindMobilePhoneText = nil
local BankNameButton = nil
local BindVerificationCode = nil
local mValidationCD = nil
local mValidationCountDown = 0
local VIPPress = nil

-- 官方充值类型
local OfficialType = 0

-- 官方充值金额
local OfficialGoldValue = 0

-- 当前官方充值索引
local OfficialIndex= 1

-- 官方充值弹窗
local OfficialInterface = 
{
    Object = nil,
    NameText = nil,
    QRCodeImage = {},
    QRCodeObject = {},
    GoldValueText = {},
    GoldValueObject = {},
    RechargeInputFieldText = nil,
    RechargePlaceholderText = nil,
    OKButton = nil,
}

--TUDOU
function GetObjects()
    mask = this.transform:Find("Canvas/StoreWindow/Mask").gameObject
    window_Report = this.transform:Find("Canvas/StoreWindow/Window_Report").gameObject
    window_ServiceCenter = this.transform:Find("Canvas/StoreWindow/Window_ServiceCenter").gameObject
    window_ContactAgency = this.transform:Find("Canvas/StoreWindow/Window_ContactAgency").gameObject

end

function Awake()
    RechargeAmountValueMin = data.PublicConfig.RECHARGE_AMOUNT_VALUE_MIN
    WithdrawMoneyValueMin = data.PublicConfig.WITHDRAW_MONEY_VALUE_MIN
    WithdrawMoneyValueMax = data.PublicConfig.WITHDRAW_MONEY_VALUE_MAX
    --TUDOU
    --获取物体
    GetObjects();
    ResetStoreUI()
    AddButtonHandlers()
    NetMsgHandler.Send_CS_Player_BindingBankCard()
end

function WindowOpened()
    
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyOrderInformation, Open9527Store)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyDaiLiRechargeInfo, OpenDaiLiRecharge)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRechargeInterfaceInfo, ReceivedPlayerRechargeInterfaceInfo)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyOrderInformation, Open9527Store)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyDaiLiRechargeInfo, OpenDaiLiRecharge)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRechargeInterfaceInfo, ReceivedPlayerRechargeInterfaceInfo)
end

function ResetStoreUI()
    RechargeInterface = this.transform:Find("Canvas/StoreWindow").gameObject
    VIPCenter = this.transform:Find('Canvas/StoreWindow/VIPCenter').gameObject
    VIPTitle = this.transform:Find('Canvas/StoreWindow/vipTitle').gameObject
    OrdinaryRecharge = this.transform:Find('Canvas/StoreWindow/OrdinaryRecharge').gameObject
    RechargeTypeButtonItemPrint = this.transform:Find('Canvas/StoreWindow/RechargeType/ButtonCenter/Viewport/Button').gameObject
    RechargeTypeButtonItem = this.transform:Find('Canvas/StoreWindow/RechargeType/ButtonCenter/Viewport/ButtonItem').gameObject
    MyIdText = VIPTitle.transform:Find('ID/Text'):GetComponent('Text')
    ValueButtonObject = OrdinaryRecharge.transform:Find('ValueButton').gameObject
    InputAmountObject = OrdinaryRecharge.transform:Find('InputAmount').gameObject
    RechargeInputFieldText = InputAmountObject.transform:Find('InputField'):GetComponent('InputField')
    RechargePlaceholderText = InputAmountObject.transform:Find('InputField/Placeholder'):GetComponent('Text')
	VIPPress = this.transform:Find('Canvas/StoreWindow/RechargeType/VIPButton/press').gameObject

    DaiLiItemParent = this.transform:Find('Canvas/StoreWindow/VIPCenter/Viewport/Content').gameObject
    DaiLiItem = this.transform:Find('Canvas/StoreWindow/VIPCenter/Viewport/Content/Item').gameObject
    
    OfficialContentObject = this.transform:Find('Canvas/StoreWindow/9527Center').gameObject
    OfficialItemParent = this.transform:Find('Canvas/StoreWindow/9527Center/Viewport/Content').gameObject
    for i = 1, 4 do
        OfficialItem[i] = this.transform:Find('Canvas/StoreWindow/9527Center/Viewport/Content/Item'..i).gameObject
    end
    QRButton1 = this.transform:Find('Canvas/StoreWindow/9527Info/back/Button/QRButton1').gameObject
    QRButton2Text = this.transform:Find('Canvas/StoreWindow/9527Info/back/Button/QRButton2/Text'):GetComponent('Text')
    RechargeInfoObject1 = this.transform:Find('Canvas/StoreWindow/9527Info/back/Info1').gameObject
    RechargeInfoObject2 = this.transform:Find('Canvas/StoreWindow/9527Info/back/Info2').gameObject
    OrderNumberText = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/OrderNumber/Text'):GetComponent('Text')
    OrderTimeText = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Time/Text'):GetComponent('Text')
    OfficePromptText = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Prompt'):GetComponent('Text')
    RechargeInPut = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/PlayerName/InputField'):GetComponent('InputField')
    TypeObject = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Type').gameObject
    for i = 1, 4 do
        RechargeInfo1[i] = RechargeInfoObject1.transform:Find('Info'..i):GetComponent('Text')
    end
    for i = 1, 3 do
        RechargeInfo2[i] = RechargeInfoObject2.transform:Find('Info'..i):GetComponent('Text')
    end
    for i = 1, 3 do
        DuiHaoImage[i] = this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Type/Rule/Count'..i..'/Checkmark').gameObject
    end
    if GameData.Exit_MoneyNotEnough == true then
        GameData.Exit_MoneyNotEnough = false;
        NetMsgHandler.Send_CS_Player_RechargeInterfaceInfo()
    else
        NetMsgHandler.Send_CS_Player_RechargeInterfaceInfo()
    end

    for Index = 1, 10, 1 do
        RechargeTypeName[Index] = this.transform:Find('Canvas/StoreWindow/OrdinaryRecharge/RechargeTypeName/Image'..Index).gameObject
    end
    for Index = 1, 8, 1 do
        ValueButtonText[Index] = ValueButtonObject.transform:Find('Button'..Index..'/Text'):GetComponent('Text')
        ValueButton[Index] =  ValueButtonObject.transform:Find('Button'..Index).gameObject
        ValueButton[Index].transform:GetComponent('Button').onClick:AddListener(function ()
            EightButtonOnClick(Index)
        end)
    end

    OfficialInterface.Object = this.transform:Find('Canvas/StoreWindow/9527Info').gameObject
    OfficialInterface.NameText = OfficialInterface.Object.transform:Find('back/Name'):GetComponent('Text')
    OfficialInterface.RechargeInputFieldText = OfficialInterface.Object.transform:Find('back/ValueButton/InputAmount/InputField'):GetComponent('InputField')
    OfficialInterface.RechargePlaceholderText = OfficialInterface.Object.transform:Find('back/ValueButton/InputAmount/InputField/Placeholder'):GetComponent('Text')
    OfficialInterface.OKButton = OfficialInterface.Object.transform:Find('back/SubmissionButton'):GetComponent('Button')
    for i = 1, 1 do
        OfficialInterface.QRCodeObject[i] = OfficialInterface.Object.transform:Find('back/QRback'..i).gameObject
        OfficialInterface.QRCodeImage[i] = OfficialInterface.QRCodeObject[i].transform:Find('QRCodeRawImage'):GetComponent("RawImage")
    end
    --[[for i = 1, 6 do
        OfficialInterface.GoldValueObject[i] = OfficialInterface.Object.transform:Find('back/ValueButton/Button'..i).gameObject
        OfficialInterface.GoldValueText[i] = OfficialInterface.Object.transform:Find('back/ValueButton/Button'..i..'/Text'):GetComponent('Text')
    end--]]
end

-- 按钮响应事件绑定
function AddButtonHandlers()

    this.transform:Find('Canvas/StoreWindow/Window_ContactAgency/Info/Center/Item1/Button'):GetComponent('Button').onClick:AddListener(function()ReplicatingShearPlate(1)end)
    this.transform:Find('Canvas/StoreWindow/Window_ContactAgency/Info/Center/Item2/Button'):GetComponent('Button').onClick:AddListener(function()ReplicatingShearPlate(2)end)

    this.transform:Find('Canvas/StoreWindow/OrdinaryRecharge/InputAmount/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetRechargeAmount)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/InputAmount/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetOfficialRechargeAmount)


    this.transform:Find('Canvas/StoreWindow/Window_Report/Close'):GetComponent('Button').onClick:AddListener(Window_Close)
    this.transform:Find('Canvas/StoreWindow/Window_ContactAgency/Title/Close'):GetComponent('Button').onClick:AddListener(Window_Close)
    this.transform:Find('Canvas/StoreWindow/Window_ServiceCenter/Title/Close'):GetComponent('Button').onClick:AddListener(Window_Close)
    this.transform:Find('Canvas/StoreWindow/Window_ContactAgency/Title/ComplaintDaiLi'):GetComponent('Button').onClick:AddListener(ComplaintDaiLiButtonOnClick)
    this.transform:Find('Canvas/StoreWindow/Window_ServiceCenter/Button_Reset'):GetComponent('Button').onClick:AddListener(ResetContactCustomerText)
    this.transform:Find('Canvas/StoreWindow/Window_ServiceCenter/Button_Submit'):GetComponent('Button').onClick:AddListener(SubmitCustomerText)
    this.transform:Find('Canvas/StoreWindow/Window_ServiceCenter/Center/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetContactCustomerText) -- 获取联系客服信息
    this.transform:Find('Canvas/StoreWindow/Window_Report/Content/Button'):GetComponent('Button').onClick:AddListener(Window_ServiceCenter)

    this.transform:Find('Canvas/StoreWindow/OrdinaryRecharge/Button'):GetComponent('Button').onClick:AddListener(ConfirmRechargeButtonOnClick)

    --TUDOU
    this.transform:Find("Canvas/StoreWindow/Mask"):GetComponent("Button").onClick:AddListener(Window_Close);
    this.transform:Find('Canvas/StoreWindow/Title/Close'):GetComponent('Button').onClick:AddListener(CloseStoreButtonOnClick)
    
    this.transform:Find('Canvas/StoreWindow/RechargeType/VIPButton'):GetComponent('Button').onClick:AddListener(VIPRechargeButtonOnClick)

	this.transform:Find("Canvas/StoreWindow/vipTitle/Report"):GetComponent("Button").onClick:AddListener(Window_Report);
	this.transform:Find('Canvas/StoreWindow/vipTitle/IDButon'):GetComponent('Button').onClick:AddListener(function() ReplicatingShearPlateIDandReportWeChat(1) end)
	this.transform:Find("Canvas/StoreWindow/vipTitle/Complaint"):GetComponent("Button").onClick:AddListener(Window_ServiceCenter);
    this.transform:Find("Canvas/StoreWindow/vipTitle/Refresh"):GetComponent("Button").onClick:AddListener(RefreshCenter);
    
    this.transform:Find('Canvas/StoreWindow/9527Info/back/Button/QRButton1'):GetComponent("Button").onClick:AddListener(CopyPayee)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/Button/QRButton2'):GetComponent("Button").onClick:AddListener(CopyContactInformation)

    this.transform:Find('Canvas/StoreWindow/9527Info/back/Close'):GetComponent("Button").onClick:AddListener(Close9527Store)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/SubmissionButton'):GetComponent("Button").onClick:AddListener(Order9527ButtonOnClick)
    --[[for i = 1, 6 do
        this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Button'..i):GetComponent("Button").onClick:AddListener(function()Click9527RecommendGold(i)end)
    end--]]
    RechargeInPut.onValueChanged:AddListener(GetOfficeRechargeName)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Type/Rule/Count1'):GetComponent('Button').onClick:AddListener(function() ChoiceOfDeposit(1) end)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Type/Rule/Count2'):GetComponent('Button').onClick:AddListener(function() ChoiceOfDeposit(4) end)
    this.transform:Find('Canvas/StoreWindow/9527Info/back/ValueButton/Type/Rule/Count3'):GetComponent('Button').onClick:AddListener(function() ChoiceOfDeposit(3) end)
    
    this.transform:Find('Canvas/StoreWindow/9527Center/Image11/btn_kefu'):GetComponent('Button').onClick:AddListener(Window_ServiceCenter)
end


--关闭小弹窗
function Window_Close()
    if window_Report.gameObject.activeSelf == true then
        window_Report.gameObject:SetActive(false);
    elseif window_ServiceCenter.gameObject.activeSelf == true then
        ResetContactCustomerText()
        window_ServiceCenter.gameObject:SetActive(false);
    elseif window_ContactAgency.gameObject.activeSelf == true then
        window_ContactAgency.gameObject:SetActive(false);
    end
    mask.gameObject:SetActive(false);
end

--举报界面
function Window_Report()
    mask.gameObject:SetActive(true);
    window_Report.gameObject:SetActive(true);
    window_Report.transform:Find('Content/Text3'):GetComponent("Text").text = ""..GameData.BankInformation.RegionalTwoText
end

--投诉/客服中心
function Window_ServiceCenter()
    mask.gameObject:SetActive(true);
    this.transform:Find('Canvas/StoreWindow/Window_Report').gameObject:SetActive(false)
    window_ServiceCenter.gameObject:SetActive(true);
end

-- 将数组部分打乱顺序
function table.random(tArray)
    local nRandCount = #tArray - 1
    if nRandCount > 1 then
        local nPos = 0
        for i = 1, nRandCount do
            nPos = math.random(1, nRandCount)
            local tTemp = tArray[nRandCount + 1]
            tArray[nRandCount + 1] = tArray[nPos]
            tArray[nPos] = tTemp
            nRandCount = nRandCount - 1
        end
    elseif nRandCount == 1 then
        --针对2个数据随机
        local nPos1 = math.random(1,2)
        local nPos2 = 3 - nPos1
        if nPos1 > nPos2 then
            tArray[nPos1],tArray[nPos2] = tArray[nPos2], tArray[nPos1]
        end
    end
    
end

--刷新
function RefreshCenter()
    window_ContactAgency.gameObject:SetActive(false);
    table.random(GameData.BankInformation.NoHotDaiLiInfo)
    
    for Index=1,#GameData.BankInformation.NoHotDaiLiInfo,1 do
        local num = #GameData.BankInformation.HotDaiLiInfo+Index
        GameData.BankInformation.DaiLiInfo[num] = GameData.BankInformation.NoHotDaiLiInfo[Index]
    end
    for Index=#GameData.BankInformation.HotDaiLiInfo+1,GameData.BankInformation.DaiLiCount,1 do
        DaiLiItemParent.transform:Find('DaiLiItem'..Index..'/Text1'):GetComponent('Text').text = GameData.BankInformation.DaiLiInfo[Index].ShopName
    end
end

-- 关闭商城界面
function CloseStoreButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('UIExtract', false)
end

-- 打开充值界面
function OpenRechargeInterface()
    PlayerRechargeInterfaceInfo()
end

-- 选择充值方式
function ChoiceRechargeModeOnClick_1(valueChange)
    if valueChange then
        RechargeMode = 1
        RechargePromptDisplay(true)
        GetRechargeAmount(RechargeAmountValue)
    end
end

-- 选择充值方式
function ChoiceRechargeModeOnClick_2(valueChange)
    if valueChange then
        RechargeMode = 3
        RechargePromptDisplay(true)
        GetRechargeAmount(RechargeAmountValue)
    end
end

-- 选择充值方式
function ChoiceRechargeModeOnClick_3(valueChange)
    if valueChange then
        RechargeMode = 4
        RechargePromptDisplay(true)
        GetRechargeAmount(RechargeAmountValue)
    end
end

-- 选择充值方式
function ChoiceRechargeModeOnClick_4(valueChange)
    if valueChange then
        RechargeMode = 2
        RechargePromptDisplay(true)
        GetRechargeAmount(RechargeAmountValue)
    end
end

-- 选择充值方式
function ChoiceRechargeModeOnClick_5(valueChange)
    if valueChange then
        RechargeMode = 5
        RechargePromptDisplay(true)
        GetRechargeAmount(RechargeAmountValue)
    end
end


-- 显示充值提示
function RechargePromptDisplay(mShow)
    if mShow == true then
        if RechargeMode == 0 then
            --TUDOU待处理
        elseif RechargeMode == 1 then
            MaxValue = data.PublicConfig.RECHARGE_AMOUNT_VALUE_MAX_0
        elseif RechargeMode == 2 then
            MaxValue = data.PublicConfig.RECHARGE_AMOUNT_VALUE_MAX_3
        elseif RechargeMode == 4 then
            MaxValue = data.PublicConfig.RECHARGE_AMOUNT_VALUE_MAX_2
        elseif RechargeMode == 3 then
            MaxValue = data.PublicConfig.RECHARGE_AMOUNT_VALUE_MAX_1
        end
    end
end

-- 打开代理充值界面
function OpenDaiLiRecharge()
    this.transform:Find("Canvas/StoreWindow/Recharge").gameObject:SetActive(false);
    this.transform:Find("Canvas/StoreWindow/Mask").gameObject:SetActive(false);
    this.transform:Find("Canvas/StoreWindow/Window_Report").gameObject:SetActive(false);
    this.transform:Find("Canvas/StoreWindow/Window_ServiceCenter").gameObject:SetActive(false);
    this.transform:Find("Canvas/StoreWindow/Window_ContactAgency").gameObject:SetActive(false);
    DaiLiRechargeInfoDisplay()
end

-- 确定充值
function ConfirmRechargeButtonOnClick()
    if RechargeAmountValue == nil or RechargeAmountValue == "" then
        CS.BubblePrompt.Show(data.GetString("请输入充值金额" ), "UIExtract")
        return
    end
    if tonumber(RechargeAmountValue) < tonumber(RechargeAmountValueMin) then
        CS.BubblePrompt.Show(data.GetString("充值金额不能低于"..RechargeAmountValueMin.."元" ), "UIExtract")
        return
    end
    if RechargeMode == -1 then
        CS.BubblePrompt.Show(data.GetString("请选择充值方式" ), "UIExtract")
        return
    end
    
    if RechargeMode ~= -1 and RechargeAmountValue ~= nil then
        RechargeAmountValue = tonumber(RechargeAmountValue)
        RechargeAmountValueMin = tonumber(RechargeAmountValueMin)
        if RechargeAmountValue >= RechargeAmountValueMin then
            if RechargeAmountValue < data.PublicConfig.PLAYER_GOLD_ALERT then
                GameData.BankInformation.RechargeMode = RechargeMode
				GameData.BankInformation.RechargeAmountValue = RechargeAmountValue
                Recharge()
            else
                CS.BubblePrompt.Show(data.GetString("金币已达携带上限，无需充值" ), "UIExtract")
            end
        end
    end
end

function Recharge()
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    local url = GameConfig.ZhiFuURL
    url = string.format( "%s?id=%d&pay_type=%d&amount=%d&apkid=%d&platform=%d&channel=%d", url, GameData.RoleInfo.AccountID, RechargeMode, RechargeAmountValue, CS.AppDefine.GameID, currentPlatform, GameData.ChannelCode)
    if 3 == currentPlatform then
        -- ios 平台
        CS.UnityEngine.Application.OpenURL(url)
    elseif 2 == currentPlatform then
        -- android 平台
        CS.Utility.OpenURL(url)
        --PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, url)
    else
        --window平台测试用
        CS.Utility.OpenURL(url)
    end
end

--TUDOU

function OnPromptClick( )
    -- body
    local tNode = this.transform:Find('Canvas/StoreWindow/PutForward/PromptInterface')
    GameObjectSetActive(tNode.gameObject, true)
end

function OnPromptInterfaceHide()
    -- body
    local tNode = this.transform:Find('Canvas/StoreWindow/PutForward/PromptInterface')
    GameObjectSetActive(tNode.gameObject, false)
end

-- 显示充值代理信息
function DaiLiRechargeInfoDisplay()
    if DaiLiItemParent.transform.childCount > 0 then
        local count=DaiLiItemParent.transform.childCount
        if count ~= 0 then
            count = count-1
        end
        for i=1,count,1 do
            if DaiLiItemParent.transform:Find("DaiLiItem"..i)~=nil then
                local copy= DaiLiItemParent.transform:Find("DaiLiItem"..i).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    table.random(GameData.BankInformation.NoHotDaiLiInfo)
    for Index=1,#GameData.BankInformation.HotDaiLiInfo,1 do
        table.insert( GameData.BankInformation.DaiLiInfo,GameData.BankInformation.HotDaiLiInfo[Index] )
    end
    for Index=1,#GameData.BankInformation.NoHotDaiLiInfo,1 do
        table.insert( GameData.BankInformation.DaiLiInfo,GameData.BankInformation.NoHotDaiLiInfo[Index] )
    end

    for Index=1,GameData.BankInformation.DaiLiCount,1 do
        local tNewNode = CS.UnityEngine.Object.Instantiate(DaiLiItem)
        CS.Utility.ReSetTransform(tNewNode.transform, DaiLiItemParent.transform)
        lua_Paste_Transform_Value(tNewNode.transform,DaiLiItemParent.transform)
        if GameData.BankInformation.DaiLiInfo[Index].Lable == 1 then
            tNewNode.transform:Find('Image_State').gameObject:SetActive(true)
        end
        tNewNode.transform:GetComponent('Button').onClick:AddListener(function() DaiLiRechargeButtonOnClick(Index) end)
        tNewNode.transform:Find('Text1'):GetComponent('Text').text = GameData.BankInformation.DaiLiInfo[Index].ShopName
        tNewNode.name="DaiLiItem"..Index
        tNewNode.gameObject:SetActive(true)
    end
end

-- 点击代理充值
function DaiLiRechargeButtonOnClick(mIndex)
    DaiLiIndex = mIndex
    GameObjectSetActive(window_ContactAgency,true)
    this.transform:Find('Canvas/StoreWindow/Mask').gameObject:SetActive(true)
    window_ContactAgency.transform:Find('Info/Text'):GetComponent('Text').text = GameData.BankInformation.DaiLiInfo[mIndex].ShopName
    if GameData.BankInformation.DaiLiInfo[mIndex].QQ == "" then
        window_ContactAgency.transform:Find('Info/Center/Item1').gameObject:SetActive(false)
    else
        window_ContactAgency.transform:Find('Info/Center/Item1').gameObject:SetActive(true)
        window_ContactAgency.transform:Find('Info/Center/Item1/Text2'):GetComponent('Text').text = GameData.BankInformation.DaiLiInfo[mIndex].QQ
    end
    if GameData.BankInformation.DaiLiInfo[mIndex].WeiXin == "" then
        window_ContactAgency.transform:Find('Info/Center/Item2').gameObject:SetActive(false)
    else
        window_ContactAgency.transform:Find('Info/Center/Item2').gameObject:SetActive(true)
        window_ContactAgency.transform:Find('Info/Center/Item2/Text2'):GetComponent('Text').text = GameData.BankInformation.DaiLiInfo[mIndex].WeiXin
    end
end

-- 点击投诉代理按钮
function ComplaintDaiLiButtonOnClick()
    GameObjectSetActive(window_ContactAgency,false)
    GameObjectSetActive(window_ServiceCenter,true)
    window_ServiceCenter.transform:Find('Center/InputField/Placeholder'):GetComponent("Text").text = string.format(data.GetString("ComplaintAgent"),GameData.BankInformation.DaiLiInfo[DaiLiIndex].ShopName)
    
    ComplaintText = "代理名："..GameData.BankInformation.DaiLiInfo[DaiLiIndex].ShopName
    if GameData.BankInformation.DaiLiInfo[DaiLiIndex].WeiXin ~= "" then
        ComplaintText = ComplaintText.."\n\n".."微信号："..GameData.BankInformation.DaiLiInfo[DaiLiIndex].WeiXin
    end
    if GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ ~= "" then
        ComplaintText = ComplaintText.."\n\n".."QQ："..GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ
    end
end

-- 获取联系客服信息
function GetContactCustomerText(mailContent)
    if string.len( mailContent) ~= 0 then
        ContactCustomerText= mailContent
    else
        ContactCustomerText = ""
    end
end

-- 重置联系客服信息
function ResetContactCustomerText()
    ComplaintText = ""
    ContactCustomerText = ""
    window_ServiceCenter.transform:Find('Center/InputField'):GetComponent("InputField").text = ContactCustomerText
end

--清除  空的 字符串
function trim (s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 

end

-- 提交客服
function SubmitCustomerText()
    local tses = trim(ContactCustomerText)
    if tses ~=""  then
        ContactCustomerText = ContactCustomerText .. ComplaintText
        NetMsgHandler.Send_CS_ComplaintAgent(ContactCustomerText)
        ResetContactCustomerText()
    else
        CS.BubblePrompt.Show(data.GetString("请输入有效信息"),"UIExtract")
        ResetContactCustomerText()
    end
end

function ReplicatingShearPlate(mType)
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    local input = ""
    if 3 == currentPlatform then
        -- ios 平台
        if mType == 1 then
            --GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ = "1455469239"
            input = ""..GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, input)
        else
            input = ""..GameData.BankInformation.DaiLiInfo[DaiLiIndex].WeiXin
            local currentPlatform = CS.Utility.GetCurrentPlatform()
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            CS.BubblePrompt.Show("复制成功", "UIExtract")
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_WXCHAT, input)
        end
    elseif 2 == currentPlatform then
        -- android 平台
        if mType == 1 then
            --GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ = "1455469239"
            local inputString = "mqqwpa://im/chat?chat_type=wpa&uin="..GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ
            input = ""..GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, inputString)
        elseif mType == 2 then
            input = ""..GameData.BankInformation.DaiLiInfo[DaiLiIndex].WeiXin
            local currentPlatform = CS.Utility.GetCurrentPlatform()
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            CS.BubblePrompt.Show("复制成功", "UIExtract")
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_WXCHAT, input)
        end
        
    else
        --window平台测试用
    end
end

-- 调用复制ID，举报专用微信剪切板
function ReplicatingShearPlateIDandReportWeChat(mIndex)
    local inputString = ""
    if mIndex == 1 then
        inputString = ""..GameData.RoleInfo.AccountID
        local currentPlatform = CS.Utility.GetCurrentPlatform()
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputString)
        CS.BubblePrompt.Show("复制成功", "UIExtract")
    elseif mIndex == 2 then
        inputString = GameData.BankInformation.RegionalTwoText
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputString)
        CS.BubblePrompt.Show("复制成功", "UIExtract")
    end
end

-- 点击绑定银行界面银行名称按钮
function ClickBaindBankInterfaceBankButton()
    if BankNameSelect.activeSelf == false then
        GameObjectSetActive(BankNameSelect,true)
        GameObjectSetActive(BankNameImage1,false)
        GameObjectSetActive(BankNameImage2,true)
        BankNameSelectDisplay()
    else
        GameObjectSetActive(BankNameSelect,false)
        GameObjectSetActive(BankNameImage2,false)
        GameObjectSetActive(BankNameImage1,true)
    end
end

-- 玩家请求打开充值界面
function PlayerRechargeInterfaceInfo()
    NetMsgHandler.Send_CS_Player_RechargeInterfaceInfo()
end
    
-- 反馈玩家请求打开充值界面
function ReceivedPlayerRechargeInterfaceInfo()
    GameObjectSetActive(OrdinaryRecharge,false)
    GameObjectSetActive(VIPCenter,true)
	GameObjectSetActive(VIPTitle,true)
	GameObjectSetActive(VIPPress,true)
    GameObjectSetActive(RechargeInterface,true)
    MyIdText.text = "".. GameData.RoleInfo.AccountID
    -- 初始化充值方式按钮 Start
    if RechargeTypeButtonItemPrint.transform.childCount > 0 then
        local count=RechargeTypeButtonItemPrint.transform.childCount
        for i=1,count,1 do
            if RechargeTypeButtonItemPrint.transform:Find("ButtonItem"..i)~=nil then
                local copy= RechargeTypeButtonItemPrint.transform:Find("ButtonItem"..i).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    for Index = 1, #GameData.BankInformation.RechargeTypeInfo, 1 do
        local tNewNode = CS.UnityEngine.Object.Instantiate(RechargeTypeButtonItem)
        CS.Utility.ReSetTransform(tNewNode.transform, RechargeTypeButtonItemPrint.transform)
        lua_Paste_Transform_Value(tNewNode.transform,RechargeTypeButtonItemPrint.transform)
        local rechargetypename = "sprite_recharge_"..GameData.BankInformation.RechargeTypeInfo[Index].RechargeType
        tNewNode.transform:GetComponent('Image'):ResetSpriteByName(rechargetypename)
        if GameData.BankInformation.RechargeTypeInfo[Index].Lable == 1 then
            tNewNode.transform:Find('Image').gameObject:SetActive(true)
        end
        tNewNode.name="ButtonItem"..Index
        tNewNode.transform:GetComponent('Button').onClick:AddListener(function ()
            OrdinaryRechargeTypeButoonOnClick(GameData.BankInformation.RechargeTypeInfo[Index].RechargeType,Index)
        end)
        GameObjectSetActive(tNewNode,true)
    end
    -- 初始化充值方式按钮 END
    DaiLiRechargeInfoDisplay()
end

function CloseReceivedPlayerRechargeInterfaceInfo()
    GameObjectSetActive(OrdinaryRecharge,false)
    GameObjectSetActive(VIPCenter,true)
    GameObjectSetActive(VIPTitle,true)
    GameObjectSetActive(RechargeInterface,false)
end

-- 点击VIP充值通道按钮
function VIPRechargeButtonOnClick()
    GameObjectSetActive(VIPCenter,true)
	GameObjectSetActive(VIPTitle,true)
	GameObjectSetActive(VIPPress,true)
    GameObjectSetActive(OrdinaryRecharge,false)
    GameObjectSetActive(OfficialContentObject,false)
	for Index = 1, #GameData.BankInformation.RechargeTypeInfo, 1 do
		RechargeTypeButtonItemPrint.transform:Find('ButtonItem'..Index..'/Press').gameObject:SetActive(false)
    end
    InputAmountObject.transform:Find('InputField'):GetComponent('InputField').text = ""
    OfficialInterface.RechargeInputFieldText.text = ""
    RechargeAmountValue = ""
    OfficialGoldValue = 0
    RechargeMode = -1
end

-- 点击普通充值类型按钮
function OrdinaryRechargeTypeButoonOnClick(mType,Index)
    if mType == 10 then
        CS.BubblePrompt.Show(string.format("暂未开放"), "UIStore")
        return 
    elseif mType == 11 then
        GameObjectSetActive(VIPCenter,false)
	    GameObjectSetActive(VIPTitle,false)
        GameObjectSetActive(VIPPress,false)
        GameObjectSetActive(OrdinaryRecharge,false)
        for k=1,11,1 do
            GameObjectSetActive(RechargeTypeName[k],false)
        end
        for k = 1, #GameData.BankInformation.RechargeTypeInfo, 1 do
            if k == Index then
                RechargeTypeButtonItemPrint.transform:Find('ButtonItem'..k..'/Press').gameObject:SetActive(true)
            else
                RechargeTypeButtonItemPrint.transform:Find('ButtonItem'..k..'/Press').gameObject:SetActive(false)
            end
        end
        GameObjectSetActive(RechargeTypeName[mType],true)
        Display9527Info(Index)
        return 
    end
    GameObjectSetActive(OfficialContentObject,false)
    GameObjectSetActive(VIPCenter,false)
	GameObjectSetActive(VIPTitle,false)
	GameObjectSetActive(VIPPress,false)
    GameObjectSetActive(OrdinaryRecharge,true)
    RechargeAmountValue = ""
    OfficialGoldValue = 0
    InputAmountObject.transform:Find('InputField'):GetComponent('InputField').text = ""
    OfficialInterface.RechargeInputFieldText.text = ""
    GameData.BankInformation.NowRechargeIndex = Index
    RechargeMode = GameData.BankInformation.RechargeTypeInfo[Index].RechargeType
    RechargeAmountValueMin = GameData.BankInformation.RechargeTypeInfo[Index].MinValue
    MaxValue = GameData.BankInformation.RechargeTypeInfo[Index].MaxValue
    
    for k=1,11,1 do
        GameObjectSetActive(RechargeTypeName[k],false)
	end
	for k = 1, #GameData.BankInformation.RechargeTypeInfo, 1 do
		if k == Index then
			RechargeTypeButtonItemPrint.transform:Find('ButtonItem'..k..'/Press').gameObject:SetActive(true)
		else
			RechargeTypeButtonItemPrint.transform:Find('ButtonItem'..k..'/Press').gameObject:SetActive(false)
		end
	end
    GameObjectSetActive(RechargeTypeName[mType],true)
	if mType < 8 then
		RechargePlaceholderText.text = "允许输入"..RechargeAmountValueMin.."-"..MaxValue.."元"
		RechargeInputFieldText.enabled = true
        GameObjectSetActive(ValueButtonObject,true)
        GameObjectSetActive(InputAmountObject,true)
		EightButtonDisplay(Index)
	elseif mType == 8 or mType == 9 then
		GameObjectSetActive(ValueButtonObject,true)
		GameObjectSetActive(InputAmountObject,true)
		RechargePlaceholderText.text = "请选择金额"
		RechargeInputFieldText.enabled = false
        EightButtonDisplay(Index)
    elseif mType == 11 then
        
    end
end

-- 显示八个按钮
function EightButtonDisplay(mIndex)
	for Index = 1, #GameData.BankInformation.RechargeTypeInfo[mIndex].RecommendedValue, 1 do
		if Index > 8 then
			return 
		end
        GameObjectSetActive(ValueButton[Index],true)
        ValueButtonText[Index].text = ""..GameData.BankInformation.RechargeTypeInfo[mIndex].RecommendedValue[Index]
    end
    if #GameData.BankInformation.RechargeTypeInfo[mIndex].RecommendedValue < 8 then
        for Index=#GameData.BankInformation.RechargeTypeInfo[mIndex].RecommendedValue+1,8,1 do
            GameObjectSetActive(ValueButton[Index],false)
        end
    end
end

-- 点击八个按钮
function EightButtonOnClick(Index)
    RechargeAmountValue = tonumber(GameData.BankInformation.RechargeTypeInfo[GameData.BankInformation.NowRechargeIndex].RecommendedValue[Index])
    InputAmountObject.transform:Find('InputField'):GetComponent('InputField').text = ""..RechargeAmountValue
    --RechargeInputFieldText.text = ""
    RechargePlaceholderText.text = ""
end

-- 获取充值金额
function GetRechargeAmount(mailContent)
    if mailContent == nil then
        return
    end
    if RechargeAmountValueMin == nil then
        return
    end
    if mailContent == "" then
        RechargeAmountValue = mailContent
        return 
    end
    local b = tonumber(mailContent)
    if b < RechargeAmountValueMin then
        --contact=false
        --contactText=mailContent
        RechargeAmountValue=mailContent
    else
        --contact=true
        if b>MaxValue then
            mailContent=MaxValue
            b = tonumber(mailContent)
            InputAmountObject.transform:Find('InputField'):GetComponent('InputField').text = ""..b
        end
        RechargeAmountValue=mailContent
    end
end

-- 获取官方充值金额
function GetOfficialRechargeAmount(mailContent)
    if mailContent == nil then
        return
    end
    if RechargeAmountValueMin == nil then
        return
    end
    if mailContent == "" then
        OfficialGoldValue = mailContent
        return 
    end
    local b = tonumber(mailContent)
    if b < RechargeAmountValueMin then
        OfficialGoldValue=mailContent
    else
        if b>MaxValue then
            mailContent=MaxValue
            b = tonumber(mailContent)
            OfficialInterface.RechargeInputFieldText.text = ""..b
        end
        OfficialGoldValue=mailContent
    end
end

-- 获取官方充值充值人姓名
function GetOfficeRechargeName( mailContent )
    -- body
    RechargeName = mailContent
end

local QRCodeName = {"支付宝","QQ钱包","微信","网银"}
local QRUrlInfo = 
{
    {"付款方式:","支付宝昵称:","支付宝账号:"},
    {"付款方式:","QQ昵称:","QQ号:"},
    {"付款方式:","微信昵称:","微信账号:"},
    {"银行:","开户行网点:","收款人:","卡号:"}
}
local QRButton2TextInfo = {"复制支付宝","复制QQ号","复制号码","复制卡号"}
local LinShiTable = {}
-- 显示9527充值信息界面
function Display9527Info(mIndex)
    GameObjectSetActive(OfficialContentObject,true)
    if OfficialItemParent.transform.childCount > 3 then
        local count=OfficialItemParent.transform.childCount-3
        for i=1,count,1 do
            if OfficialItemParent.transform:Find("ButtonItem"..i)~=nil then
                local copy= OfficialItemParent.transform:Find("ButtonItem"..i).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    LinShiTable = GameData.BankInformation.RechargeTypeInfo.QRCodeInfo
    for i = 1, #LinShiTable do
        local tNewNode = CS.UnityEngine.Object.Instantiate(OfficialItem[LinShiTable[i].RechargeType])
        CS.Utility.ReSetTransform(tNewNode.transform, OfficialItemParent.transform)
        lua_Paste_Transform_Value(tNewNode.transform,OfficialItemParent.transform)
        tNewNode.name="ButtonItem"..i
        tNewNode.transform:Find('Text'):GetComponent('Text').text = QRCodeName[LinShiTable[i].RechargeType]
        tNewNode.transform:Find('Text1'):GetComponent('Text').text = "" .. LinShiTable[i].RechargeTypeIndex
        tNewNode.transform:GetComponent('Button').onClick:AddListener(function ()
            RequestOrderInformation(i,GameData.BankInformation.RechargeTypeInfo.QRCodeInfo[i].RechargeType)
        end)
        GameObjectSetActive(tNewNode,true)
    end
end

-- 请求充值订单信息
function RequestOrderInformation( mIndex,mtype )
    -- body
    OfficialIndex = mIndex
    NetMsgHandler.Send_CS_Official_OrderInformation()
end

-- 打开9527扫码充值界面
function Open9527Store()
    local mIndex = OfficialIndex
    GameObjectSetActive(OfficialInterface.Object,true)
    OfficialInterface.OKButton.interactable = true
    OfficialGoldValue = 0
    RechargeName = ""
    RechargeInPut.text = ""
    OfficialInterface.RechargeInputFieldText.text = ""
    OfficePromptText.text = LinShiTable[mIndex].Prompt
    OfficialInterface.NameText.text = QRCodeName[LinShiTable[mIndex].RechargeType]..LinShiTable[mIndex].RechargeTypeIndex
    RechargeAmountValueMin = LinShiTable[mIndex].MinValue
    MaxValue = LinShiTable[mIndex].MaxValue
    OfficialInterface.RechargePlaceholderText.text = "允许输入金额"..RechargeAmountValueMin.."-"..MaxValue.."元"
    OrderNumberText.text = GameData.BankInformation.OrderInformation
    OrderTimeText.text = GameData.BankInformation.Time
    QRButton2Text.text = QRButton2TextInfo[LinShiTable[mIndex].RechargeType]
    if LinShiTable[mIndex].RechargeType == 1 or LinShiTable[mIndex].RechargeType == 4 then
        GameObjectSetActive(QRButton1,true)
    else
        GameObjectSetActive(QRButton1,false)
    end
    if LinShiTable[mIndex].RechargeType == 4 then
        GameObjectSetActive(RechargeInfoObject1,true)
        GameObjectSetActive(RechargeInfoObject2,false)
        GameObjectSetActive(TypeObject,true)
        RechargeType = 1
        for i = 1, #LinShiTable[mIndex].UrlInfo do
            RechargeInfo1[i].text = QRUrlInfo[LinShiTable[mIndex].RechargeType][i].."".. LinShiTable[mIndex].UrlInfo[i]
        end
        if #LinShiTable[mIndex].UrlInfo < 4 then
            for i = #LinShiTable[mIndex].UrlInfo+1, 4 do
                RechargeInfo1[i].text = ""
            end
        end
        for i = 1, 3 do
            if i == 1 then
                GameObjectSetActive(DuiHaoImage[i],true)
            else
                GameObjectSetActive(DuiHaoImage[i],false)
            end
        end
    else
        RechargeType = 0
        GameObjectSetActive(TypeObject,false)
        GameObjectSetActive(RechargeInfoObject2,true)
        GameObjectSetActive(RechargeInfoObject1,false)
        for i = 1, #LinShiTable[mIndex].UrlInfo do
            RechargeInfo2[i].text =QRUrlInfo[LinShiTable[mIndex].RechargeType][i].."".. LinShiTable[mIndex].UrlInfo[i]
        end
        if #LinShiTable[mIndex].UrlInfo < 3 then
            for i = #LinShiTable[mIndex].UrlInfo+1, 3 do
                RechargeInfo2[i].text = ""
            end
        end
    end
    if LinShiTable[mIndex].Url == "" then
        GameObjectSetActive(OfficialInterface.QRCodeObject[1],false)
    else
        GameObjectSetActive(OfficialInterface.QRCodeObject[1],true)
        CS.Utility.CreateBarcode(OfficialInterface.QRCodeImage[1], LinShiTable[mIndex].Url, 256, 256)
    end
end

-- 点击9527推荐金额
function Click9527RecommendGold(mIndex)
    OfficialGoldValue = LinShiTable[OfficialIndex].RecommendedValue[mIndex]
    OfficialInterface.RechargeInputFieldText.text = ""..OfficialGoldValue
end

-- 点击9527官方充值界面提交订单按钮
function Order9527ButtonOnClick()
    if OfficialGoldValue == 0 or OfficialGoldValue == "" then
        CS.BubblePrompt.Show(data.GetString("请输入充值金额" ), "UIExtract")
        return
    end
    if tonumber(OfficialGoldValue) < RechargeAmountValueMin then
        CS.BubblePrompt.Show(data.GetString("输入金额低于最小充值金额" ), "UIExtract")
        return
    end
    NetMsgHandler.Send_CS_Official_Recharge(LinShiTable[OfficialIndex].RechargeType,OfficialGoldValue,LinShiTable[OfficialIndex].UrlIndex,GameData.BankInformation.OrderInformation,RechargeName,RechargeType)
    OfficialInterface.OKButton.interactable = false
    this:DelayInvoke(1,function ()
        OfficialInterface.OKButton.interactable = true
    end)
end

-- 选择存款方式
function ChoiceOfDeposit(mIndex)
    RechargeType = mIndex
    for i = 1, 3 do
        if mIndex == i then
            GameObjectSetActive(DuiHaoImage[i],true)
        else
            GameObjectSetActive(DuiHaoImage[i],false)
        end
    end
    if RechargeType == 4 then
        GameObjectSetActive(DuiHaoImage[2],true)
    end
end

-- 关闭9527扫码充值界面
function Close9527Store()
    GameObjectSetActive(OfficialInterface.Object,false)
end

-- 复制收款人
function CopyPayee()
    local inputString = ""
    if LinShiTable[OfficialIndex].RechargeType == 4 then
        if #LinShiTable[OfficialIndex].UrlInfo < 3 then
            CS.BubblePrompt.Show("复制失败", "UIExtract")
            return 
        end
        inputString = LinShiTable[OfficialIndex].UrlInfo[3]
    else
        if #LinShiTable[OfficialIndex].UrlInfo < 2 then
            CS.BubblePrompt.Show("复制失败", "UIExtract")
            return 
        end
        inputString = LinShiTable[OfficialIndex].UrlInfo[2]
    end
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputString)
    CS.BubblePrompt.Show("复制成功", "UIExtract")
end

-- 复制联系方式
function CopyContactInformation()
    local inputString = ""
    if LinShiTable[OfficialIndex].RechargeType == 4 then
        if #LinShiTable[OfficialIndex].UrlInfo < 4 then
            CS.BubblePrompt.Show("复制失败", "UIExtract")
            return 
        end
        inputString = LinShiTable[OfficialIndex].UrlInfo[4]
    else
        if #LinShiTable[OfficialIndex].UrlInfo < 3 then
            CS.BubblePrompt.Show("复制失败", "UIExtract")
            return 
        end
        inputString = LinShiTable[OfficialIndex].UrlInfo[3]
    end
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputString)
    CS.BubblePrompt.Show("复制成功", "UIExtract")
end

-- 保存图片到手机
function ButtonStoreSaveOnClick()
    this:DelayInvoke(0.6 , function()
        CS.BubblePrompt.Show("二维码已保存至系统相册！", "QRCCodeUI")
    end)
    CS.Utility.SaveImg()
end