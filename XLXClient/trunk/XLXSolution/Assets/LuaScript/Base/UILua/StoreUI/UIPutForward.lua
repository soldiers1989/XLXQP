
local HomepageGameObject = nil      		-- 主页界面
local DetailedGameObject = nil				-- 明细界面
local PutForwardGameObject = nil			-- 提现界面
local BindingBankCardGameObject = nil		-- 绑定界面
local BindingZFBGameObject = nil            -- 绑定支付宝界面
local NamePromptText = nil					-- 绑定名字提示
local AccountPromptText = nil				-- 绑定账号提示
local NamePromptTextZFB = nil			    -- 支付宝绑定名字提示
local AccountPromptTextZFB = nil		    -- 支付宝绑定账号提示
local PromptText = nil 						-- 绑定界面温馨提示
local IsBindingBankCardGameObject = nil		-- 提现界面未绑定组件
local BillInfoTemplateGameObject = nil      -- 账单信息模板
local BillInfoTemplatePrintGameObject = nil -- 账单信息模板父节点
local BankNameSelect = nil					-- 银行名称选择界面
local BankNameImage1 = nil					-- 银行名称选择界面下拉图片
local BankNameImage2 = nil					-- 银行名称选择界面上拉图片


local WithdrawMoneyValueMin = nil				-- 提现额度最低
local WithdrawMoneyValueMax = nil				-- 提现额度最大

local BankNameIntem = nil						-- 银行名称模板
local BankNamePater = nil						-- 银行名称父节点

local WithdrawMoneyMode = 0 -- 提现方式(1银行卡 2支付宝)

local BindingInfo = 1 --绑定类型(1银行卡 2支付宝 3 微信)


-- 提现额度
local WithdrawMoneyValue = nil
-- 绑定人名字（必填）
local BindingName = ""
-- 绑定人卡号/支付宝账号（必填）
local BindingCardNumber = ""
-- 绑定人卡号银行名称（选填）
local BingdingCardName = ""
-- 绑定人开户省份（选填）
local BingdingOpenAnAccountProvince = ""
-- 绑定人开户城市（选填）
local BingdingOpenAnAccountCity = ""
-- 绑定人开户支行（选填）
local BindingOpenAnAccountSubbranch = ""

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
local ZhiFuBaoObject = nil;
--TUDOU
function GetObjects()

    --提现
    local tempPath = "Canvas/StoreWindow/PutForward/Window_Withdraw";
    mask_Window_Withdraw = this.transform:Find("Canvas/StoreWindow/PutForward/Mask_Window_Withdraw");
    window_Withdraw = this.transform:Find(tempPath);
    button_Close = this.transform:Find(tempPath.."/Title/Button_Close"):GetComponent("Button");
    text_Count_Withdraw = this.transform:Find(tempPath.."/Center/Count_Withdraw"):GetComponent("Text");
    text_Count_Charge = this.transform:Find(tempPath.."/Center/Count_Charge"):GetComponent("Text");
    button_Withdraw = this.transform:Find(tempPath.."/Button/Button_Withdraw"):GetComponent("Button");
    button_Cancel = this.transform:Find(tempPath.."/Button/Button_Cancel"):GetComponent("Button");
    mask_Window_Withdraw.gameObject:SetActive(false);
    window_Withdraw.gameObject:SetActive(false);
end

function Awake()
    WithdrawMoneyValueMin = data.PublicConfig.WITHDRAW_MONEY_VALUE_MIN
    WithdrawMoneyValueMax = data.PublicConfig.WITHDRAW_MONEY_VALUE_MAX
    --TUDOU
    --获取物体
    GetObjects();
    AddButtonHandlers()
    ResetStoreUI()
    NetMsgHandler.Send_CS_Player_BindingBankCard()
end

function WindowOpened()

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerBindingBankCard, RankHomepageInfoDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerBillDetailed, BillInfoDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerBindingBankCardOK, CloseBindingBankCardInterface)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerPutForwardInfo, OpenPutForwardInterface)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerBankiCardInfo, OpenBindingBankCardInterface)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPlayerRequestPutForward, PutForwardInterface)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyDaiLiRechargeInfo, OpenDaiLiRecharge)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRechargeInterfaceInfo, ReceivedPlayerRechargeInterfaceInfo)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerBindingBankCard, RankHomepageInfoDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerBillDetailed, BillInfoDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerBindingBankCardOK, CloseBindingBankCardInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerPutForwardInfo, OpenPutForwardInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerBankiCardInfo, OpenBindingBankCardInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPlayerRequestPutForward, PutForwardInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyDaiLiRechargeInfo, OpenDaiLiRecharge)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRechargeInterfaceInfo, ReceivedPlayerRechargeInterfaceInfo)
end

function ResetStoreUI()

    mValidationCD = this.transform:Find("Canvas/StoreWindow/BindingBankCard/MobilePhone/ValidationBtn/Text"):GetComponent("Text")
	MobilePhoneObject = this.transform:Find("Canvas/StoreWindow/BindingBankCard/MobilePhone").gameObject
    ZhiFuBaoObject = this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao').gameObject

    BindError = this.transform:Find('Canvas/StoreWindow/BindError').gameObject

    BindVerificationCode = this.transform:Find('Canvas/StoreWindow/BindingBankCard/MobilePhone/VerificationCode/InputFieldName'):GetComponent('InputField')
    BindMobilePhoneText = this.transform:Find('Canvas/StoreWindow/BindingBankCard/MobilePhone/Numbe/InputFieldName'):GetComponent('InputField')

    HomepageGameObject = this.transform:Find('Canvas/StoreWindow/Homepage').gameObject
    DetailedGameObject = this.transform:Find('Canvas/StoreWindow/Detailed').gameObject
    PutForwardGameObject = this.transform:Find('Canvas/StoreWindow/PutForward').gameObject
    PutForwardGameObject.transform:Find("Rule/Count1").gameObject:SetActive(true)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Checkmark').gameObject:SetActive(false)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Checkmark').gameObject:SetActive(false)

    BindingBankCardGameObject = this.transform:Find('Canvas/StoreWindow/BindingBankCard').gameObject
    BindingZFBGameObject = this.transform:Find('Canvas/StoreWindow/BindingZFB').gameObject

    --this.transform:Find('Canvas/StoreWindow/Homepage/Yuebao').gameObject:SetActive(false)

    BankNameSelect = this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/RankList').gameObject
    BankNameImage1 = this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/Button/Image1').gameObject
    BankNameImage2 = this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/Button/Image2').gameObject
    BankNameButton = this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/Button'):GetComponent('Button')

    BillInfoTemplateGameObject = DetailedGameObject.transform:Find('Content/RankList/Viewport/RankItem').gameObject
    BillInfoTemplatePrintGameObject = DetailedGameObject.transform:Find('Content/RankList/Viewport/Content').gameObject

    NamePromptText = BindingBankCardGameObject.transform:Find("Required/Name/InputFieldName/Placeholder"):GetComponent("Text")
    AccountPromptText = BindingBankCardGameObject.transform:Find("Required/Account/InputFieldAccount/Placeholder"):GetComponent("Text")
    PromptText = BindingBankCardGameObject.transform:Find("Required/Prompt"):GetComponent("Text")

    NamePromptTextZFB = BindingZFBGameObject.transform:Find("Required/Name/InputFieldName/Placeholder"):GetComponent("Text")
    AccountPromptTextZFB = BindingZFBGameObject.transform:Find("Required/Account/InputFieldAccount/Placeholder"):GetComponent("Text")

    BankNameIntem = BindingBankCardGameObject.transform:Find('Required/BankName/RankList/Viewport/Content/BankItem').gameObject
    BankNamePater = BindingBankCardGameObject.transform:Find('Required/BankName/RankList/Viewport/Content').gameObject

    IsBindingBankCardGameObject = this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Prompt').gameObject

    DetailedGameObject:SetActive(false)
    PutForwardGameObject:SetActive(false)
    BindingBankCardGameObject:SetActive(false)
    GameObjectSetActive(BindingZFB,false)
    if GameData.Exit_MoneyNotEnough == true then
        GameData.Exit_MoneyNotEnough = false;
        HomepageGameObject:SetActive(false);
        NetMsgHandler.Send_CS_Player_RechargeInterfaceInfo()
    elseif GameData.BankInformation.IsOpenBind == true then
        GameData.BankInformation.IsOpenBind = false
        OpenBindingBankCardInterface(1)
    else
        HomepageGameObject:SetActive(true);
    end

    mValidationCD.text = ""
end

-- 按钮响应事件绑定
function AddButtonHandlers()
    this.transform:Find('Canvas/StoreWindow/Homepage/Title/Close'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
    this.transform:Find('Canvas/StoreWindow/Detailed/Title/Close'):GetComponent("Button").onClick:AddListener(function() BackToHome(DetailedGameObject) end)
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Close'):GetComponent("Button").onClick:AddListener(function() BackToHome(BindingBankCardGameObject) end)
    this.transform:Find('Canvas/StoreWindow/BindingZFB/Close'):GetComponent("Button").onClick:AddListener(function() BackToHome(BindingZFBGameObject) end)
    this.transform:Find('Canvas/StoreWindow/Homepage/Quota/PutForwardButton'):GetComponent("Button").onClick:AddListener(RequestOpenPutForwardInterface)
    this.transform:Find('Canvas/StoreWindow/Homepage/Quota/YueBaoButton'):GetComponent("Button").onClick:AddListener(YueebaoButtonOnClick)
    
    this.transform:Find('Canvas/StoreWindow/PutForward/Close'):GetComponent("Button").onClick:AddListener(function() BackToHome(PutForwardGameObject) end)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Button'):GetComponent("Button").onClick:AddListener(function() selectPutType(2) end)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count2/Button'):GetComponent("Button").onClick:AddListener(function() selectPutType(3) end)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Button'):GetComponent("Button").onClick:AddListener(function() selectPutType(1) end)
    this.transform:Find('Canvas/StoreWindow/PutForward/Button'):GetComponent("Button").onClick:AddListener(ConfirmPutForwardButtonOnClick)
    this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetWithdrawMoneyValue)	-- 提现
    this.transform:Find('Canvas/StoreWindow/PutForward/Prompt'):GetComponent("Button").onClick:AddListener(OnPromptClick)
    this.transform:Find('Canvas/StoreWindow/PutForward/PromptInterface/Kuang/Title/Close'):GetComponent("Button").onClick:AddListener(OnPromptInterfaceHide)

    this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Button'):GetComponent("Button").onClick:AddListener(function() RequestOpenBindingBankCardInterface(1) end)
    this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Button'):GetComponent("Button").onClick:AddListener(function() RequestOpenBindingBankCardInterface(2) end)
    this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/WeiXi/Button'):GetComponent("Button").onClick:AddListener(function() RequestOpenBindingBankCardInterface(3) end)
    this.transform:Find('Canvas/StoreWindow/Homepage/MingXi'):GetComponent("Button").onClick:AddListener(OpenDetailedInterface)
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Button'):GetComponent("Button").onClick:AddListener(ConfirmBindingButtonOnClick)
    this.transform:Find('Canvas/StoreWindow/BindingZFB/Button'):GetComponent("Button").onClick:AddListener(ConfirmBindingButtonOnClick)

    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Name/InputFieldName'):GetComponent("InputField").onValueChanged:AddListener(GetBindingName) --绑定人名字
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").onValueChanged:AddListener(GetBingdingCardName) --绑定人卡号名称
    this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Name/InputFieldName'):GetComponent("InputField").onValueChanged:AddListener(GetBindingName) --绑定人名字
    this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Account/InputFieldAccount'):GetComponent("InputField").onValueChanged:AddListener(GetBindingCardNumber) --绑定人卡号名称
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").onValueChanged:AddListener(GetBindingCardNumber) --绑定人名字

    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/Button'):GetComponent('Button').onClick:AddListener(ClickBaindBankInterfaceBankButton)

    this.transform:Find('Canvas/StoreWindow/BindingBankCard/MobilePhone/ValidationBtn'):GetComponent("Button").onClick:AddListener(OnValidationBtnClick)

	this.transform:Find('Canvas/StoreWindow/BindError/Image/Button'):GetComponent('Button').onClick:AddListener(CloseBindError)
    this.transform:Find('Canvas/StoreWindow/Homepage/YueBao'):GetComponent("Button").onClick:AddListener(YueebaoButtonOnClick)

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
end

--TUDOU
function CloseWithdrawWindow()			--关闭提现提示界面
    mask_Window_Withdraw.gameObject:SetActive(false);
    window_Withdraw.gameObject:SetActive(false);
end
function OpenWithdrawWindow()
    text_Count_Withdraw.text = ""..GameData.BankInformation.AmountOfWithdraw;
    text_Count_Charge.text = ""..GameData.BankInformation.ChargeOfWithdraw;
    mask_Window_Withdraw.gameObject:SetActive(true);
    window_Withdraw.gameObject:SetActive(true);
end
function WithdrawWindowOk()
    NetMsgHandler.Send_CS_Player_Extract(WithdrawMoneyMode,WithdrawMoneyValue, 2);
end
function WithdrawWindowCancel()
    CloseWithdrawWindow();
end

-- 点击余额宝入口
function YueebaoButtonOnClick()
    NetMsgHandler.Send_CS_YuEBao_Info()
    this.transform:Find('Canvas/StoreWindow/Homepage/YueBao'):GetComponent('Button').enabled = false
    this:DelayInvoke(1,function ()
        this.transform:Find('Canvas/StoreWindow/Homepage/YueBao'):GetComponent('Button').enabled = true
    end)
end

-- 关闭商城界面
function CloseStoreButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('UIPutForward', false)
end

-- 返回直充直兑主页
function BackToHome(mCloseUI)
    HomepageGameObject:SetActive(true)
    mCloseUI:SetActive(false)
    ResetExtractData()
    --刷新數據后再打開界面
    NetMsgHandler.Send_CS_Player_BindingBankCard()
    --RankHomepageInfoDisplay()
end

-- 重置数据
function ResetExtractData()
    this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text=""
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Name/InputFieldName'):GetComponent("InputField").text=""
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").text=""
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").text=""

    WithdrawMoneyMode = 0
    WithdrawMoneyValue = nil
    BindingName = ""
    BindingCardNumber = ""
    BingdingCardName = ""
    BingdingOpenAnAccountProvince = ""
    BingdingOpenAnAccountCity = ""
    BindingOpenAnAccountSubbranch = ""
end

-- 银行主页信息显示

function RankHomepageInfoDisplay()
    this.transform:Find('Canvas/StoreWindow/Homepage/Quota/AvailableValue'):GetComponent("Text").text=""..lua_GetPreciseDecimal(GameData.BankInformation.AvailableCredit,2)
    this.transform:Find('Canvas/StoreWindow/Homepage/Quota/PutForwardValue'):GetComponent("Text").text=""..lua_GetPreciseDecimal(GameData.BankInformation.AmountExtraction,2)

    if GameData.RoleInfo.IsBindBank == true and GameData.BankInformation.ChangeBindFlag == 0 then
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Prompt'):GetComponent("Text").text ="已绑定"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Image1').gameObject:SetActive(false)
    elseif GameData.RoleInfo.IsBindBank == false then
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Prompt'):GetComponent("Text").text ="未绑定"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Image1').gameObject:SetActive(true)
    else
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Prompt'):GetComponent("Text").text ="更改"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/BankCard/Image1').gameObject:SetActive(true)
    end

    if GameData.BankInformation.ZhiFuBaoIsBinding == 1 and GameData.BankInformation.ChangeBindFlag == 0 then
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Prompt'):GetComponent("Text").text ="已绑定"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Image1').gameObject:SetActive(false)
    elseif GameData.BankInformation.ZhiFuBaoIsBinding == 0 then
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Prompt'):GetComponent("Text").text ="未绑定"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Image1').gameObject:SetActive(true)
    else
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Prompt'):GetComponent("Text").text ="更改"
        this.transform:Find('Canvas/StoreWindow/Homepage/GoldOption/Content/ZhiFuBao/Image1').gameObject:SetActive(true)
    end
end

-- 请求打开提现界面
function RequestOpenPutForwardInterface()
    if GameData.RoleInfo.IsBindAccount == false and GameData.GameState == GAME_STATE.HALL then
        HandleRegisterRewardUI(true)
        CS.WindowManager.Instance:CloseWindow('UIPutForward', false)
        --NetMsgHandler.Send_CS_Player_ExtractInfo()
        --OpenPutForwardInterface(true)
    else
        --OpenPutForwardInterface(true)
        NetMsgHandler.Send_CS_Player_ExtractInfo()
    end
end

--获取提现信息
function PutForwardInterface()
    --TUDOU
    if GameData.BankInformation.isGetData == 1 then
        OpenWithdrawWindow();
    elseif GameData.BankInformation.isGetData == 2 then
        CS.BubblePrompt.Show(string.format(data.GetString("Player_Extract_Erro_0"), lua_CommaSeperate(GameData.BankInformation.AmountOfWithdraw)),"UIExtract")
        PutForwardInterfaceDisplayInfo();
        CloseWithdrawWindow();
    end
    -- 重置可用额度
    this.transform:Find('Canvas/StoreWindow/Homepage/Quota/AvailableValue'):GetComponent("Text").text=""..lua_GetPreciseDecimal(GameData.BankInformation.AvailableCredit,2)
end

-- 提现界面显示信息
function PutForwardInterfaceDisplayInfo()
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Checkmark').gameObject:SetActive(false)
    this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Checkmark').gameObject:SetActive(false)
    PutForwardGameObject.transform:Find("PutForwardValue"):GetComponent("Text").text="可提现："..lua_GetPreciseDecimal(GameData.BankInformation.AmountExtraction,2).."元"
    PutForwardGameObject.transform:Find("ServiceCharge"):GetComponent("Text").text="手续费:0元"
    PutForwardGameObject.transform:Find("InputField/Placeholder"):GetComponent("Text").text="单次提现范围100元~10万元"--""..WithdrawMoneyValueMin.."<=提现金额>="..WithdrawMoneyValueMax
    PutForwardGameObject.transform:Find("InputField"):GetComponent("InputField").text=""
    WithdrawMoneyValue=nil
    if GameData.BankInformation.ZhiFuBaoIsBinding == 1 then
        PutForwardGameObject.transform:Find("Rule/Count1/Prompt").gameObject:SetActive(false)
        --PutForwardGameObject.transform:Find("Rule/Count1/Button").gameObject:SetActive(false)
        PutForwardGameObject.transform:Find("Rule/Count1/Name"):GetComponent("Text").text=""..GameData.BankInformation.ZhiFuBaoName
        PutForwardGameObject.transform:Find("Rule/Count1/CardNumber"):GetComponent("Text").text=""..GameData.BankInformation.ZhiFuBaoAccount
        PutForwardGameObject.transform:Find("Rule/Count1/Background").gameObject:SetActive(true)
        --PutForwardGameObject.transform:Find("Rule/Count1"):GetComponent("Toggle").enabled = true
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Background').gameObject:SetActive(true)

    else
        PutForwardGameObject.transform:Find("Rule/Count1/Background").gameObject:SetActive(false)
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Background').gameObject:SetActive(false)
    end

    if GameData.RoleInfo.IsBindBank == true then
        PutForwardGameObject.transform:Find("Rule/Count3/Prompt").gameObject:SetActive(false)
        --PutForwardGameObject.transform:Find("Rule/Count3/Button").gameObject:SetActive(false)
        PutForwardGameObject.transform:Find("Rule/Count3/Name"):GetComponent("Text").text=""..GameData.BankInformation.BankName
        PutForwardGameObject.transform:Find("Rule/Count3/CardNumber"):GetComponent("Text").text=""..GameData.BankInformation.BankNumber
        PutForwardGameObject.transform:Find("Rule/Count3/Background").gameObject:SetActive(true)
        --PutForwardGameObject.transform:Find("Rule/Count3"):GetComponent("Toggle").enabled = true
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Background').gameObject:SetActive(true)
    else
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Background').gameObject:SetActive(false)
    end
end

-- 打开提现界面
function OpenPutForwardInterface(mShow)
    if mShow then
        HomepageGameObject:SetActive(false)
        PutForwardGameObject:SetActive(true)
        PutForwardInterfaceDisplayInfo()
    end
end

function selectPutType(mIndex)
    if mIndex == 1 then
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Checkmark').gameObject:SetActive(false)
        if GameData.RoleInfo.IsBindBank then
            this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Checkmark').gameObject:SetActive(true)
        end

        -- 如果未绑定
        if GameData.RoleInfo.IsBindBank == false then
            BindingInfo=mIndex
            NetMsgHandler.Send_CS_Player_BankiCardInfo()
        end
    elseif mIndex == 2 then
        if GameData.BankInformation.ZhiFuBaoIsBinding == 1 then
            this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count1/Checkmark').gameObject:SetActive(true)
        end
        this.transform:Find('Canvas/StoreWindow/PutForward/Rule/Count3/Checkmark').gameObject:SetActive(false)
        -- 如果未绑定
        if GameData.BankInformation.ZhiFuBaoIsBinding == 0 then
            BindingInfo=mIndex
            NetMsgHandler.Send_CS_Player_ZFBInfo()
        end
    end

    WithdrawMoneyMode = mIndex;
end

-- 请求打开绑定银行卡界面界面
function RequestOpenBindingBankCardInterface(mIndex)
    BindingInfo=mIndex

    if GameData.RoleInfo.IsBindAccount == false and GameData.GameState ~= GAME_STATE.HALL then
        CS.BubblePrompt.Show(data.GetString("游戏房间内无法绑定"),"UIExtract")
        return
    end

    if mIndex == 1 then
        -- 如果未绑定或可更改
        if GameData.RoleInfo.IsBindBank == false or GameData.BankInformation.ChangeBindFlag == 1 then
            NetMsgHandler.Send_CS_Player_BankiCardInfo()
        end
    elseif mIndex == 2 then
        -- 如果未绑定或可更改;
        if GameData.BankInformation.ZhiFuBaoIsBinding == 0 or GameData.BankInformation.ChangeBindFlag == 1 then
            NetMsgHandler.Send_CS_Player_ZFBInfo()
        end
    end
end

-- 打开绑定界面
function OpenBindingBankCardInterface(mIndex)
    HomepageGameObject:SetActive(false)
    PutForwardGameObject:SetActive(false)
    if mIndex == 2 then
        OpenBindingZFBInterface(mIndex)
        return
    end
    BindingBankCardGameObject:SetActive(true)
    GameObjectSetActive(BankNameSelect,false)
    GameObjectSetActive(BankNameImage1,true)
    GameObjectSetActive(BankNameImage2,false)
    if mIndex == 1 then
        this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").contentType = 2;
        BindingBankCardGameObject.transform:Find("Required/Account/CardNumer"):GetComponent("Text").text="卡号："
        BindingBankCardGameObject.transform:Find("Required/BankName").gameObject:SetActive(true)
        if GameData.RoleInfo.IsBindBank == false then
            NamePromptText.text = "持卡人姓名"
            AccountPromptText.text = "银行卡号"
            PromptText.text = "姓名须与你银行卡账户名称相同,否则不能出款!"
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Button/Text'):GetComponent("Text").text="绑定"
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").text=""
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Name/InputFieldName'):GetComponent("InputField").text=""
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").text=""
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").enabled=true
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Name/InputFieldName'):GetComponent("InputField").enabled=true
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").enabled=false
            --GameObjectSetActive(MobilePhoneObject,true)
            --BindMobilePhoneText.enabled = true
            --BindVerificationCode.enabled = true
            BankNameButton.interactable = true
        else
            NamePromptText.text = ""
            AccountPromptText.text = ""
            PromptText.text = ""
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").text=GameData.BankInformation.BankCardNumber
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Name/InputFieldName'):GetComponent("InputField").text=GameData.BankInformation.BankPlayerName
            this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").text=GameData.BankInformation.BankName
            --GameObjectSetActive(MobilePhoneObject,false)
            BankNameButton.enabled = false
            BindMobilePhoneText.enabled = false
            BindVerificationCode.enabled = false
        end
    elseif mIndex == 2 then
        this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/Account/InputFieldAccount'):GetComponent("InputField").contentType = 0;
        BindingBankCardGameObject.transform:Find("Required/Account/CardNumer"):GetComponent("Text").text="账号："
        ZhiFuBaoBindingInfoDisplay()
    elseif mIndex == 3 then
        NamePromptText.text = "微信账号实名制姓名"
        AccountPromptText.text = "微信账号信息"
        PromptText.text = "请输入正确的微信账号信息，否则会导致兑换失败哦~~"
    end

    --如果没有绑定手机号才显示手机验证
    --[[if GameData.RoleInfo.IsBindAccount == false then
        MobilePhoneObject:SetActive(true)
    else
        MobilePhoneObject:SetActive(false)
    end--]]
end

function OpenBindingZFBInterface(mIndex)
    GameObjectSetActive(BindingZFBGameObject,true)
    this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Account/InputFieldAccount'):GetComponent("InputField").contentType = 0;
    BindingBankCardGameObject.transform:Find("Required/Account/CardNumer"):GetComponent("Text").text="账号："
    ZhiFuBaoBindingInfoDisplay()
end

-- 支付宝绑定界面显示信息
function ZhiFuBaoBindingInfoDisplay()
    if GameData.BankInformation.ZhiFuBaoIsBinding == 0 then
        NamePromptTextZFB.text = "支付宝账号实名制姓名"
        AccountPromptText.text = "支付宝账号信息"
        this.transform:Find('Canvas/StoreWindow/BindingZFB/Button/Text'):GetComponent("Text").text="绑定"
        this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Account/InputFieldAccount'):GetComponent("InputField").text=""
        this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Name/InputFieldName'):GetComponent("InputField").text=""
    else
        NamePromptTextZFB.text = ""
        AccountPromptText.text = ""
        --this.transform:Find('Canvas/StoreWindow/BindingBankCard/Button/Text'):GetComponent("Text").text="更换支付宝"
        this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Account/InputFieldAccount'):GetComponent("InputField").text=""..GameData.BankInformation.ZhiFuBaoAccount
        this.transform:Find('Canvas/StoreWindow/BindingZFB/Required/Name/InputFieldName'):GetComponent("InputField").text=""..GameData.BankInformation.ZhiFuBaoName
    end
end

-- 关闭绑定界面
function CloseBindingBankCardInterface(resultType)
    if resultType == 0 then
        BackToHome(BindingBankCardGameObject)
        BackToHome(BindingZFBGameObject)
        CS.BubblePrompt.Show(data.GetString("BindingBankError_"..resultType),"UIExtract")
    elseif resultType ~=6 and resultType ~= 7 then
        GameObjectSetActive(BindError,true)
    else
        CS.BubblePrompt.Show(data.GetString("BindingBankError_"..resultType),"UIExtract")
    end
end

-- 关闭绑定失败界面
function CloseBindError()
    GameObjectSetActive(BindError,false)
end

function OpenYuebao()
    CS.WindowManager.Instance:OpenWindow("UIYuebao")
end

-- 打开明细界面
function OpenDetailedInterface()
    
    HomepageGameObject:SetActive(false)
    DetailedGameObject:SetActive(true)
    
    NetMsgHandler.Send_CS_Player_BillDetailed()
end

-- 获取提现金额
function GetWithdrawMoneyValue(mailContent)
    if string.len( mailContent) ~= 0 then
        local b = tonumber(mailContent)
        if b then
            if b < WithdrawMoneyValueMin then
                --contact=false
                WithdrawMoneyValue=mailContent
                PutForwardGameObject.transform:Find("ServiceCharge"):GetComponent("Text").text="手续费:0元"
            else
                --contact=true
                if b>GameData.BankInformation.AmountExtraction then
                    mailContent=GameData.BankInformation.AmountExtraction
                    b = tonumber(mailContent)
                    b= math.floor(b)
                    if b >WithdrawMoneyValueMax then
                        mailContent=WithdrawMoneyValueMax
                        b = tonumber(mailContent)
                        b= math.floor(b)
                    end
                    this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text=""..lua_GetPreciseDecimal(b,2)
                    
                end
                WithdrawMoneyValue=b
                --local ServiceCharge = b*0.02
                --PutForwardGameObject.transform:Find("ServiceCharge"):GetComponent("Text").text="手续费:"..lua_GetPreciseDecimal(ServiceCharge,2).."元"
            end
        else
            --contact=false
            if string.len( mailContent) > 1 then
                local NewStr = string.sub(mailContent, 1, -2)
                this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text =NewStr
                WithdrawMoneyValue=NewStr
            else
                WithdrawMoneyValue=nil
                this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text=""
            end
        end
    else
        if string.len( mailContent) > 1 then
            local NewStr = string.sub(mailContent, 1, -2)
            this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text =NewStr
            WithdrawMoneyValue=NewStr
        else
            WithdrawMoneyValue=nil
            this.transform:Find('Canvas/StoreWindow/PutForward/InputField'):GetComponent("InputField").text=""
        end
    end
end

-- 获取绑定人名字（必填）
function GetBindingName(mailContent)
    if string.len( mailContent) ~= 0 then
        BindingName = mailContent
    else
        BindingName = ""
    end
end
-- 获取绑定人卡号（必填）
function GetBindingCardNumber(mailContent)
    if string.len( mailContent) ~= 0 then
        BindingCardNumber= mailContent
    else
        BindingCardNumber = ""
    end
end
-- 获取绑定人卡号名称（选填）
function GetBingdingCardName(mailContent)
    if string.len( mailContent) ~= 0 then
        BingdingCardName = mailContent
    else
        BingdingCardName = ""
    end
end

-- 确认绑定
function ConfirmBindingButtonOnClick()
    local NumberLen = string.len(BindingCardNumber)
    local accountText = tostring(BindMobilePhoneText.text)
    local tmpLength = SubStringGetTotalCount(accountText)

    if BindingName == "" then
        CS.BubblePrompt.Show('请输入名字', "UIExtract")
        return
    end

    if BindingInfo == 1 then
        if NumberLen < 16 then
            CS.BubblePrompt.Show('请输入正确的银行卡号', "UIExtract")
            return
        end

        if BingdingCardName == "" then
            CS.BubblePrompt.Show('请输入正确的银行名称', "UIExtract")
            return
        end

        if GameData.RoleInfo.IsBindAccount == true then
            NetMsgHandler.Send_CS_Player_BindingBankCardok(BindingName,BindingCardNumber,BingdingCardName,
                    BingdingOpenAnAccountProvince,BingdingOpenAnAccountCity,BindingOpenAnAccountSubbranch,"")
            return
        end

        --[[if tmpLength ~= 11 then
            CS.BubblePrompt.Show('请输入正确的手机号码', "UIExtract")
            return
        end--]]

        -- TODO 验证码效验
        --[[local codeText = BindVerificationCode.text
        tmpLength = SubStringGetTotalCount(codeText)
        if  codeText =="" or tmpLength ~= 6 or
                CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or
                CS.SMSManager.Instance().LastSMSCode ~= codeText then
            CS.BubblePrompt.Show('验证码无效!', "UIExtract")
            return
        end--]]

        -- 当前号码是否是接受验证码的手机好吗
        --[[if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
            CS.BubblePrompt.Show('前后输入的手机号不一致...', "UIExtract")
            return
        end--]]

        NetMsgHandler.Send_CS_Player_BindingBankCardok(BindingName,BindingCardNumber,BingdingCardName,
                BingdingOpenAnAccountProvince,BingdingOpenAnAccountCity,BindingOpenAnAccountSubbranch,accountText)
    elseif BindingInfo == 2 then
        if NumberLen == 0 then
            CS.BubblePrompt.Show('请输入支付宝账号', "UIExtract")
            return
        end

        if GameData.RoleInfo.IsBindAccount == true then
            NetMsgHandler.Send_CS_Player_BindingZhiFuBao(BindingName, BindingCardNumber, "")
        else
            --[[if tmpLength ~= 11 then
                CS.BubblePrompt.Show('请输入正确的手机号码', "UIExtract")
                return
            end--]]
            -- TODO 验证码效验
            --[[local codeText = BindVerificationCode.text
            tmpLength = SubStringGetTotalCount(codeText)
            if  codeText =="" or tmpLength ~= 6 or
                    CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or
                    CS.SMSManager.Instance().LastSMSCode ~= codeText then
                CS.BubblePrompt.Show('验证码无效!', "UIExtract")
                return
            end--]]

            -- 当前号码是否是接受验证码的手机好吗
            --[[if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
                CS.BubblePrompt.Show('前后输入的手机号不一致...', "UIExtract")
                return
            end--]]
            NetMsgHandler.Send_CS_Player_BindingZhiFuBao(BindingName, BindingCardNumber)
        end
    end
end

--TUDOU

function OnPromptClick()
    -- body
    local tNode = this.transform:Find('Canvas/StoreWindow/PutForward/PromptInterface')
    GameObjectSetActive(tNode.gameObject, true)
end

function OnPromptInterfaceHide()
    -- body
    local tNode = this.transform:Find('Canvas/StoreWindow/PutForward/PromptInterface')
    GameObjectSetActive(tNode.gameObject, false)
end

-- 确定提现
function ConfirmPutForwardButtonOnClick()
    if GameData.RoleInfo.IsBindAccount == false then
        CS.BubblePrompt.Show(data.GetString("请绑定银行卡" ), "UIExtract")
        return
	end
    if WithdrawMoneyMode == 0 then
        CS.BubblePrompt.Show(data.GetString("请选择提现方式" ), "UIExtract")
        return
    end
    if WithdrawMoneyValue == nil then
        CS.BubblePrompt.Show(data.GetString("请输入提现金额" ), "UIExtract")
        return
    end
    -- if WithdrawMoneyValue < 100 then
    -- 	CS.BubblePrompt.Show(data.GetString("提现金额必须>=100" ), "UIExtract")
    -- 	return
    -- end
    if WithdrawMoneyMode ~= 0 and WithdrawMoneyValue ~= nil then
        WithdrawMoneyValue = tonumber(WithdrawMoneyValue)
        if WithdrawMoneyValue >= WithdrawMoneyValueMin then
            -- mask_Window_Withdraw.gameObject:SetActive(true);
            -- window_Withdraw.gameObject:SetActive(true);
            NetMsgHandler.Send_CS_Player_Extract(WithdrawMoneyMode,WithdrawMoneyValue, 1);
            --OpenWithdrawWindow();
        else
            CS.BubblePrompt.Show(data.GetString("提现金额必须>=100" ), "UIExtract")
            return;
        end
    end
end

local BillTypeTable = {[0]="充值",[1]="提现",[2]="退款"}
local BillModeTable = {[1]="支付宝",[2]="QQ",[3]='微信',[4]='银行卡',[5]='支付宝扫码',[6]='QQ扫码',[7]='微信扫码',[8]='支付宝扫码',[9]='微信定额',[10]='点卡',[11]='官方扫码',[100]='VIP充值'}
local BillPutModeTable = {[1]="银行卡",[2]="支付宝"}
local Refund = {[1] = "官方"}

-- 账单信息显示
function BillInfoDisplay()
    local rankItemParent = DetailedGameObject.transform:Find('Content/RankList/Viewport/Content')
    if BillInfoTemplatePrintGameObject.transform.childCount > 0 then
        local count=BillInfoTemplatePrintGameObject.transform.childCount
        for Index=1,count,1 do
            if BillInfoTemplatePrintGameObject.transform:Find("RankItem"..Index)~=nil then
                local copy= BillInfoTemplatePrintGameObject.transform:Find("RankItem"..Index).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    if GameData.BankInformation.BillCount == 0 then
        DetailedGameObject.transform:Find('Prompt').gameObject:SetActive(true)
    else
        DetailedGameObject.transform:Find('Prompt').gameObject:SetActive(false)
    end
    for Index=1, GameData.BankInformation.BillCount, 1 do
        local copy = CS.UnityEngine.Object.Instantiate(BillInfoTemplateGameObject)
        copy.transform.name="RankItem"..Index
        CS.Utility.ReSetTransform(copy.transform,BillInfoTemplatePrintGameObject.transform)
        copy:SetActive(true)
        copy.transform:Find('Type'):GetComponent("Text").text ="".. BillTypeTable[GameData.BankInformation.BillInfo[Index].BillType]
        if GameData.BankInformation.BillInfo[Index].BillType == 0 then
            copy.transform:Find('Source'):GetComponent("Text").text ="".. BillModeTable[GameData.BankInformation.BillInfo[Index].BillMode]
            copy.transform:Find('Gold'):GetComponent("Text").text ="<color=#00FF56FF>+".. GameData.BankInformation.BillInfo[Index].BillGold.."</color>"
        elseif GameData.BankInformation.BillInfo[Index].BillType == 1 then
            copy.transform:Find('Source'):GetComponent("Text").text ="".. BillPutModeTable[GameData.BankInformation.BillInfo[Index].BillMode]
            copy.transform:Find('Gold'):GetComponent("Text").text ="<color=red>-".. GameData.BankInformation.BillInfo[Index].BillGold.."</color>"
        elseif GameData.BankInformation.BillInfo[Index].BillType == 2 then
            copy.transform:Find('Source'):GetComponent("Text").text ="".. Refund[GameData.BankInformation.BillInfo[Index].BillMode]
            copy.transform:Find('Gold'):GetComponent("Text").text ="<color=#00FF56FF>+".. GameData.BankInformation.BillInfo[Index].BillGold.."</color>"
        end	
        --copy.transform:Find('Time1'):GetComponent("Text").text ="".. GameData.BankInformation.BillInfo[Index].BilltDate
        copy.transform:Find('Time2'):GetComponent("Text").text ="".. GameData.BankInformation.BillInfo[Index].BillTime
    end
end

--清除  空的 字符串
function trim (s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 

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

-- 绑定界面模板显示
function BankNameSelectDisplay()
    local Print = BankNameSelect.transform:Find('Viewport/Content').gameObject
    local count=Print.transform.childCount
    if count == 1 then
        local length = #data.BankConfig
        for Index=1, length, 1 do
            local Copy=CS.UnityEngine.Object.Instantiate(BankNameIntem)
            CS.Utility.ReSetTransform(Copy.transform,BankNamePater.transform)
            Copy:SetActive(true)
            Copy.transform:Find('Text'):GetComponent('Text').text = data.BankConfig[Index].Name
            Copy.transform:GetComponent('Button').onClick:AddListener(function() BankNameSelecOk(Index) end)
        end
    end
end

-- 选择银行名称
function BankNameSelecOk(Index)
    BingdingCardName = data.BankConfig[Index].Name
    this.transform:Find('Canvas/StoreWindow/BindingBankCard/Required/BankName/InputField1BankName'):GetComponent("InputField").text=""..BingdingCardName
    GameObjectSetActive(BankNameSelect,false)
    GameObjectSetActive(BankNameImage2,false)
    GameObjectSetActive(BankNameImage1,true)
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
        CS.BubblePrompt.Show('获取验证码太频繁,请稍等:'..(90 - passTime), "WXLogin")
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = (90 -passTime) * 1.0
        isUpdateCodeCountDown = true
        return
    elseif passTime < 3600 then
        -- 重复过滤 建议减少每小时发送数量
        if tLastErrorCode == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "WXLogin")
            return
        end
    elseif passTime < 86400 then
        if tLastErrorCode == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "WXLogin")
            return 
        end
    end

    local strAccount = BindMobilePhoneText.text
    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "WXLogin")
        return
    end

    local tCode = CS.SMSManager.Instance():SMSRandomCode()

    CS.SMSManager.Instance().LastSendSMSTime = tostring(tNowTime)
    CS.SMSManager.Instance().LastSMSCode = tostring(tCode)
    CS.SMSManager.Instance().LastPhoneNumber = strAccount
    isUpdateCodeCountDown = true

    local code = string.format("{\"code\":\"%s\"}", tostring(tCode))

    local tdata = CS.SMSManager.SendSms(strAccount, "SMS_135270123", code,"")
    if tdata ~= nil then
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = 90
        
        if tdata.Code == "OK" then
            -- TODO 验证码发送成功
            CS.BubblePrompt.Show("验证码获取成功", "WXLogin")
        elseif tdata.Code == "isv.MOBILE_NUMBER_ILLEGAL" then
            -- 非法手机号 建议使用正确的手机号
        elseif tdata.Code == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "WXLogin")
        elseif tdata.Code == "VALVE::H_MC" then
            -- 重复过滤 建议减少每小时发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "WXLogin")
        elseif tdata.Code == "VALVE::M_MC" then
            -- 重复过滤 建议减少每分钟发送数量()
            CS.BubblePrompt.Show('获取验证码太频繁,请等90秒再获取', "WXLogin")
        else
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "WXLogin")
        end
        CS.SMSManager.Instance().LastSendSMSErrorCode = tdata.Code
        -- print("Send SMS Code:", tdata.Code, tdata.Message)
        -- print("Send SMS BizId", tdata.BizId, tdata.RequestId)
    else
        CS.SMSManager.Instance().LastSendSMSErrorCode = "1"
        CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "WXLogin")
    end

end

function Update()
    UpdateCodeCD()
end

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